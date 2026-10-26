import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ss_feedback.dart';
import '../../../core/utils/ss_whatsapp.dart';

class CustomerDetailController extends GetxController {
  CustomerDetailController(this.id);

  final String id;
  final api = Get.find<ApiClient>();

  final customer = Rxn<Map<String, dynamic>>();
  final orders = <dynamic>[].obs;
  final measurements = <dynamic>[].obs;
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
      final results = await Future.wait([
        api.dio.get('/customers/$id'),
        api.dio.get('/orders', queryParameters: {
          'customerId': id,
          'pageSize': 20,
        }),
        api.dio.get('/measurements', queryParameters: {
          'customerId': id,
        }),
      ]);
      customer.value = results[0].data as Map<String, dynamic>;
      orders.assignAll((results[1].data as Map)['items'] as List? ?? []);
      final measData = results[2].data;
      measurements.assignAll(
        measData is List
            ? measData
            : ((measData as Map?)?['items'] as List? ?? []),
      );
    } catch (e) {
      error.value = ssErrorMessage(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> openWhatsApp() async {
    final ctx = Get.context;
    if (ctx == null) return;
    final l = AppLocalizations.of(ctx)!;
    final c = customer.value;
    if (c == null) return;
    await ssOpenWhatsApp(
      context: ctx,
      phone: '${c['phone']}',
      title: l.shareWhatsApp,
      message: 'Hello ${c['fullName']},\n\n— ${l.appName}',
    );
  }

  Future<void> archive(bool doArchive) async {
    final ctx = Get.context;
    final l = ctx != null ? AppLocalizations.of(ctx)! : null;
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          doArchive ? (l?.archive ?? 'Archive') : (l?.restore ?? 'Restore'),
        ),
        content: Text(
          doArchive
              ? (l?.confirmArchive ?? 'Archive this customer?')
              : (l?.confirmRestore ?? 'Restore this customer?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(l?.continueLabel ?? 'Continue'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await api.dio.post(
        doArchive ? '/customers/$id/archive' : '/customers/$id/restore',
      );
      await load();
    } on DioException catch (e) {
      SsSnack.fromError(
        e,
        title: doArchive ? (l?.archive ?? 'Archive') : (l?.restore ?? 'Restore'),
        context: Get.context,
      );
    }
  }
}
