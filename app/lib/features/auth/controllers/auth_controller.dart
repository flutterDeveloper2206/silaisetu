import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';

class AuthController extends GetxController {
  final api = Get.find<ApiClient>();
  final user = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final error = ''.obs;
  bool _sessionDialogOpen = false;

  @override
  void onInit() {
    super.onInit();
    api.onSessionExpired = () {
      // Fire-and-forget; interceptor must not await the dialog.
      handleSessionExpired();
    };
    api.onSubscriptionRequired = () {
      if (Get.currentRoute == '/subscription') return;
      Get.offAllNamed('/subscription');
    };
  }

  bool get onboardingComplete =>
      user.value?['onboardingComplete'] == true ||
      ((user.value?['memberships'] as List?)?.isNotEmpty ?? false);

  bool get requiresVerification => user.value?['requiresVerification'] == true;

  List get memberships => (user.value?['memberships'] as List?) ?? [];

  Future<bool> register({
    required String fullName,
    required String password,
    String? email,
    String? phone,
    String? altPhone,
    String? languagePref,
  }) async {
    loading.value = true;
    error.value = '';
    try {
      final res = await api.dio.post('/auth/register', data: {
        'fullName': fullName,
        'password': password,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (altPhone != null && altPhone.isNotEmpty) 'altPhone': altPhone,
        if (languagePref != null) 'languagePref': languagePref,
      });
      await _persist(res.data as Map<String, dynamic>);
      return true;
    } on DioException catch (e) {
      error.value = _msg(e);
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<bool> login(String identifier, String password) async {
    loading.value = true;
    error.value = '';
    try {
      final res = await api.dio.post('/auth/login', data: {
        'identifier': identifier.trim(),
        'password': password,
      });
      await _persist(res.data as Map<String, dynamic>);
      return true;
    } on DioException catch (e) {
      error.value = _msg(e, fallback: 'invalid');
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<Map<String, dynamic>?> forgotPassword(String identifier) async {
    loading.value = true;
    error.value = '';
    try {
      final res = await api.dio.post('/auth/forgot-password', data: {
        'identifier': identifier.trim(),
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      error.value = _msg(e);
      return null;
    } finally {
      loading.value = false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    loading.value = true;
    error.value = '';
    try {
      await api.dio.post('/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
      return true;
    } on DioException catch (e) {
      error.value = _msg(e);
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<Map<String, dynamic>?> requestVerify({String? channel}) async {
    try {
      final res = await api.dio.post('/auth/verify/request', data: {
        if (channel != null) 'channel': channel,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      error.value = _msg(e);
      return null;
    }
  }

  Future<bool> confirmVerify(String code) async {
    loading.value = true;
    try {
      final res = await api.dio.post('/auth/verify/confirm', data: {
        'identifier': user.value?['email'] ?? user.value?['phone'] ?? '',
        'code': code,
      });
      user.value = res.data as Map<String, dynamic>;
      return true;
    } on DioException catch (e) {
      error.value = _msg(e);
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> hydrate() async {
    // Restore cached profile immediately so cold start skips login UI.
    if (api.hasSession && api.cachedUser != null) {
      user.value = Map<String, dynamic>.from(api.cachedUser!);
    }

    if (!api.hasSession) {
      user.value = null;
      return;
    }

    Future<bool> fetchMe() async {
      final res = await api.dio.get('/auth/me');
      final data = Map<String, dynamic>.from(res.data as Map);
      user.value = data;
      await api.cacheUser(data);
      await api.ensureShopFromMemberships(memberships);
      return true;
    }

    try {
      await fetchMe();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Access expired → try refresh once, then /me again.
      if (status == 401) {
        final renewed = await api.tryRefresh();
        if (renewed) {
          try {
            await fetchMe();
            return;
          } on DioException catch (e2) {
            if (e2.response?.statusCode == 401) {
              await handleSessionExpired();
            }
            // Keep cached session on other errors after refresh.
            return;
          }
        }
        await handleSessionExpired();
        return;
      }
      // Offline / server down: keep token + cached user so login is not shown.
      if (kDebugMode) {
        // ignore: avoid_print
        print('hydrate soft-fail (${e.type}): keeping local session');
      }
    } catch (_) {
      // Keep local session on unexpected errors.
    }
  }

  Future<void> selectShop(String shopId) async {
    await api.setShopId(shopId);
  }

  /// Call before shop-scoped screens load data.
  Future<void> ensureShopContext() async {
    if (user.value == null) await hydrate();
    await api.ensureShopFromMemberships(memberships);
  }

  Future<void> logout() async {
    try {
      await api.dio.post('/auth/logout');
    } catch (_) {}
    await api.clear();
    user.value = null;
    Get.offAllNamed('/welcome');
  }

  /// Token fully expired — clear session, show popup, go to sign-in.
  Future<void> handleSessionExpired() async {
    user.value = null;
    await api.clear();
    if (_sessionDialogOpen) {
      Get.offAllNamed('/sign-in');
      return;
    }
    _sessionDialogOpen = true;
    try {
      final ctx = Get.overlayContext ?? Get.context;
      final l = ctx != null ? AppLocalizations.of(ctx) : null;
      final title = l?.sessionExpiredTitle ?? 'Session expired';
      final body = l?.sessionExpiredBody ??
          'Your login has expired. Please sign in again.';
      final ok = l?.sessionExpiredOk ?? 'Sign in';
      if (ctx != null) {
        await Get.dialog<void>(
          barrierDismissible: false,
          AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              FilledButton(
                onPressed: () => Get.back(),
                child: Text(ok),
              ),
            ],
          ),
        );
      }
    } catch (_) {
      // Fall through to navigation.
    } finally {
      _sessionDialogOpen = false;
      Get.offAllNamed('/sign-in');
    }
  }

  String routeAfterAuth() {
    if (requiresVerification) return '/verify';
    if (!onboardingComplete) return '/onboarding';
    if (memberships.length > 1) return '/select-shop';
    return '/home';
  }

  /// After shop context is ready, send unpaid shops to the paywall.
  Future<String> routeAfterAuthAsync() async {
    final base = routeAfterAuth();
    if (base != '/home') return base;
    try {
      await ensureShopContext();
      if (api.shopId == null || api.shopId!.isEmpty) return base;
      final res = await api.dio.get('/billing/subscription');
      final data = res.data;
      if (data is Map && data['required'] == true) {
        return '/subscription';
      }
    } catch (_) {
      // Offline / API error: let home load; interceptor will gate later.
    }
    return base;
  }

  Future<void> _persist(Map<String, dynamic> data) async {
    final memberships = (data['user']?['memberships'] as List?) ?? [];
    String? shopId;
    if (memberships.length == 1) {
      shopId = memberships.first['shop']?['id'] as String?;
    }
    await api.persistAuth(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String?,
      shopId: shopId,
    );
    final u = Map<String, dynamic>.from(data['user'] as Map);
    if (data['requiresVerification'] == true) {
      u['requiresVerification'] = true;
    }
    user.value = u;
    await api.cacheUser(u);
  }

  String _msg(DioException e, {String fallback = 'error'}) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    if (e.type == DioExceptionType.connectionError) return 'offline';
    return fallback;
  }
}
