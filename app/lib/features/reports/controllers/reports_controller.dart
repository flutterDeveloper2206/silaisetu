import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/date_range.dart';
import '../../auth/controllers/auth_controller.dart';

class ReportsController extends GetxController {
  final api = Get.find<ApiClient>();
  final auth = Get.find<AuthController>();

  final preset = DatePreset.thisMonth.obs;
  final summary = Rxn<Map<String, dynamic>>();
  final loading = true.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  int countOf(dynamic count) {
    if (count is int) return count;
    if (count is num) return count.toInt();
    if (count is Map) {
      final all = count['_all'] ?? count.values.firstOrNull;
      if (all is num) return all.toInt();
    }
    return int.tryParse('$count') ?? 0;
  }

  double numOf(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      await auth.ensureShopContext();
      final range = DateRange.forPreset(preset.value);
      final res = await api.dio.get('/reports/summary', queryParameters: {
        'from': range.fromIso,
        'to': range.toIso,
      });
      summary.value = res.data as Map<String, dynamic>;
      loading.value = false;
    } on DioException catch (e) {
      error.value = e.response?.data is Map
          ? '${(e.response!.data as Map)['message'] ?? e.message}'
          : (e.type == DioExceptionType.connectionError
              ? 'offline'
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

  String presetLabel(AppLocalizations l) => switch (preset.value) {
        DatePreset.today => l.rangeToday,
        DatePreset.yesterday => l.rangeYesterday,
        DatePreset.thisWeek => l.rangeThisWeek,
        DatePreset.thisMonth => l.rangeThisMonth,
        DatePreset.previousMonth => l.rangePreviousMonth,
        DatePreset.custom => l.dateFilter,
      };
}
