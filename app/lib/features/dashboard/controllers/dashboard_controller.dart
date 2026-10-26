import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/date_range.dart';
import '../../auth/controllers/auth_controller.dart';

class DashboardController extends GetxController {
  final api = Get.find<ApiClient>();
  final auth = Get.find<AuthController>();

  final preset = DatePreset.thisMonth.obs;
  final summary = Rxn<Map<String, dynamic>>();
  final calendar = Rxn<Map<String, dynamic>>();
  final recentOrders = <dynamic>[].obs;
  final recentCustomers = <dynamic>[].obs;
  final loading = true.obs;
  final error = RxnString();

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
      final range = DateRange.forPreset(preset.value);
      final results = await Future.wait([
        api.dio.get('/reports/summary', queryParameters: {
          'from': range.fromIso,
          'to': range.toIso,
        }),
        api.dio.get('/calendar', queryParameters: {
          'from': range.fromIso,
          'to': range.toIso,
        }),
        api.dio.get('/orders', queryParameters: {'pageSize': 5}),
        api.dio.get('/customers', queryParameters: {'pageSize': 5}),
      ]);
      summary.value = results[0].data as Map<String, dynamic>;
      calendar.value =
          (results[1].data as Map)['summary'] as Map<String, dynamic>?;
      recentOrders.assignAll(
          (results[2].data as Map)['items'] as List? ?? []);
      recentCustomers.assignAll(
          (results[3].data as Map)['items'] as List? ?? []);
      loading.value = false;
    } on DioException catch (e) {
      error.value = e.type == DioExceptionType.connectionError
          ? 'offline'
          : (e.response?.data is Map
              ? '${(e.response!.data as Map)['message'] ?? e.message}'
              : e.message);
      loading.value = false;
    } catch (e) {
      error.value = '$e';
      loading.value = false;
    }
  }

  void setPreset(DatePreset p) {
    preset.value = p;
    load();
  }

  int statusCount(String status) {
    final list = summary.value?['ordersByStatus'] as List? ?? [];
    for (final row in list) {
      if (row is Map && '${row['status']}' == status) {
        return (row['_count'] as num?)?.toInt() ?? 0;
      }
    }
    return 0;
  }

  String presetLabel(AppLocalizations l) => switch (preset.value) {
        DatePreset.today => l.rangeToday,
        DatePreset.yesterday => l.rangeYesterday,
        DatePreset.thisWeek => l.rangeThisWeek,
        DatePreset.thisMonth => l.rangeThisMonth,
        DatePreset.previousMonth => l.rangePreviousMonth,
        DatePreset.custom => l.dateFilter,
      };
}
