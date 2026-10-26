import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  final api = Get.find<ApiClient>();
  final auth = Get.find<AuthController>();

  final summary = Rxn<Map<String, dynamic>>();
  final error = RxnString();
  final loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      await auth.ensureShopContext();
      if (api.shopId == null || api.shopId!.isEmpty) {
        error.value = 'no-shop';
        loading.value = false;
        return;
      }
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, 1);
      final to = DateTime(now.year, now.month + 1, 0);
      final res = await api.dio.get('/calendar', queryParameters: {
        'from': from.toIso8601String().substring(0, 10),
        'to': to.toIso8601String().substring(0, 10),
      });
      summary.value = (res.data as Map)['summary'] as Map<String, dynamic>?;
      loading.value = false;
    } on DioException catch (e) {
      error.value = _dioError(e);
      loading.value = false;
    } catch (_) {
      error.value = 'error';
      loading.value = false;
    }
  }

  String _dioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'offline';
    }
    final code = e.response?.statusCode;
    if (code == 401) return 'auth';
    if (code == 403) return 'shop';
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return 'error';
  }

  String errorText(AppLocalizations l) {
    return switch (error.value) {
      'offline' => l.errorGeneric,
      'auth' => l.invalidCredentials,
      'shop' || 'no-shop' => l.selectShop,
      _ when error.value != null && error.value != 'error' => error.value!,
      _ => l.errorGeneric,
    };
  }
}
