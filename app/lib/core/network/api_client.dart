import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiClient extends GetxService {
  late final Dio dio;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );

  static const _accessKey = 'ss_access';
  static const _refreshKey = 'ss_refresh';
  static const _shopKey = 'ss_shop';
  static const _userKey = 'ss_user_cache';

  String? _accessToken;
  String? _refreshToken;
  String? _shopId;
  Map<String, dynamic>? _cachedUser;

  /// Called when session is fully expired (refresh failed / revoked).
  void Function()? onSessionExpired;

  bool _handlingExpiry = false;
  Completer<bool>? _refreshCompleter;

  String? get shopId => _shopId;
  Map<String, dynamic>? get cachedUser => _cachedUser;

  Future<ApiClient> init() async {
    final prefs = await SharedPreferences.getInstance();
    _shopId = prefs.getString(_shopKey);
    _accessToken = prefs.getString(_accessKey);
    _refreshToken = prefs.getString(_refreshKey);
    final rawUser = prefs.getString(_userKey);
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        _cachedUser = Map<String, dynamic>.from(jsonDecode(rawUser) as Map);
      } catch (_) {}
    }

    try {
      final secAccess = await _storage.read(key: _accessKey);
      final secRefresh = await _storage.read(key: _refreshKey);
      final shop = await _storage.read(key: _shopKey);
      if (secAccess != null && secAccess.isNotEmpty) _accessToken = secAccess;
      if (secRefresh != null && secRefresh.isNotEmpty) {
        _refreshToken = secRefresh;
      }
      if (shop != null && shop.isNotEmpty) _shopId = shop;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Secure storage read failed, using prefs fallback: $e');
      }
      try {
        await _storage.deleteAll();
      } catch (_) {}
    }

    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _accessToken;
        final shop = _shopId;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (shop != null && shop.isNotEmpty) {
          options.headers['X-Shop-Id'] = shop;
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        if (kDebugMode) {
          debugPrint(
            'API ${err.requestOptions.method} ${err.requestOptions.uri} '
            '→ ${err.response?.statusCode} ${err.message}',
          );
        }

        final status = err.response?.statusCode;
        final path = err.requestOptions.path;
        final isAuthPublic = path.contains('/auth/login') ||
            path.contains('/auth/register') ||
            path.contains('/auth/refresh') ||
            path.contains('/auth/forgot') ||
            path.contains('/auth/reset');

        final alreadyRetried = err.requestOptions.extra['ss_retried'] == true;
        final code = err.response?.data is Map
            ? '${(err.response!.data as Map)['code'] ?? ''}'
            : '';

        // Stale JWT after onboarding: memberships missing → 403.
        // Refresh rebuilds claims from DB, then retry once.
        final shopContextForbidden =
            status == 403 && code == 'SHOP_CONTEXT_REQUIRED';

        if (((status == 401) || shopContextForbidden) &&
            !isAuthPublic &&
            hasSession) {
          if (!alreadyRetried) {
            final ok = await tryRefresh();
            if (ok) {
              try {
                final req = err.requestOptions;
                req.extra['ss_retried'] = true;
                req.headers['Authorization'] = 'Bearer $_accessToken';
                if (_shopId != null && _shopId!.isNotEmpty) {
                  req.headers['X-Shop-Id'] = _shopId;
                }
                final response = await dio.fetch(req);
                return handler.resolve(response);
              } catch (e) {
                if (e is DioException) return handler.next(e);
              }
            }
          }
          if (status == 401) await _emitSessionExpired();
        }

        handler.next(err);
      },
    ));
    return this;
  }

  Future<void> _emitSessionExpired() async {
    if (_handlingExpiry) return;
    _handlingExpiry = true;
    await clear();
    try {
      onSessionExpired?.call();
    } finally {
      // Allow future logins to trigger again after navigation settles.
      Future<void>.delayed(const Duration(seconds: 2), () {
        _handlingExpiry = false;
      });
    }
  }

  /// Public entry for hydrate / manual expiry handling.
  Future<void> forceSessionExpired() => _emitSessionExpired();

  Future<void> persistAuth({
    required String accessToken,
    String? refreshToken,
    String? shopId,
  }) async {
    _accessToken = accessToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _refreshToken = refreshToken;
    }
    if (shopId != null) await setShopId(shopId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, accessToken);
    if (_refreshToken != null && _refreshToken!.isNotEmpty) {
      await prefs.setString(_refreshKey, _refreshToken!);
    }

    try {
      await _storage.write(key: _accessKey, value: accessToken);
      if (_refreshToken != null && _refreshToken!.isNotEmpty) {
        await _storage.write(key: _refreshKey, value: _refreshToken!);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Secure storage write failed: $e');
    }
  }

  Future<void> cacheUser(Map<String, dynamic> user) async {
    _cachedUser = Map<String, dynamic>.from(user);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_cachedUser));
  }

  Future<void> setShopId(String shopId) async {
    _shopId = shopId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shopKey, shopId);
    try {
      await _storage.write(key: _shopKey, value: shopId);
    } catch (_) {}
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _shopId = null;
    _cachedUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shopKey);
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_userKey);
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }

  Future<String?> get accessToken async => _accessToken;
  Future<String?> get refreshToken async => _refreshToken;

  bool get hasSession =>
      _accessToken != null && _accessToken!.isNotEmpty;

  /// Try refresh token when access token is expired. Returns true if renewed.
  Future<bool> tryRefresh() async {
    if (_refreshCompleter != null) return _refreshCompleter!.future;
    final refresh = _refreshToken;
    if (refresh == null || refresh.isEmpty) return false;

    _refreshCompleter = Completer<bool>();
    try {
      final res = await Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      )).post('/auth/refresh', data: {'refreshToken': refresh});
      final data = res.data as Map;
      final access = data['accessToken'] as String?;
      final nextRefresh = data['refreshToken'] as String?;
      if (access == null || access.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }
      await persistAuth(
        accessToken: access,
        refreshToken: nextRefresh ?? refresh,
        shopId: _shopId,
      );
      _refreshCompleter!.complete(true);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Token refresh failed: $e');
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<bool> ensureShopFromMemberships(List memberships) async {
    if (_shopId != null && _shopId!.isNotEmpty) {
      final stillValid = memberships.any(
        (m) => (m as Map)['shop']?['id'] == _shopId,
      );
      if (stillValid || memberships.isEmpty) return _shopId!.isNotEmpty;
    }
    if (memberships.isEmpty) return false;
    final first = memberships.first as Map;
    final id = first['shop']?['id'] as String?;
    if (id == null || id.isEmpty) return false;
    await setShopId(id);
    return true;
  }
}
