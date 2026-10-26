import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ss_feedback.dart';

class ReceivePaymentController extends GetxController {
  final api = Get.find<ApiClient>();
  final amount = TextEditingController();
  final notes = TextEditingController();
  final orderId = RxnString();
  final method = 'CASH'.obs;
  final kind = 'PARTIAL'.obs;
  final saving = false.obs;
  late final String idempotencyKey =
      '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) orderId.value = '${args['orderId']}';
  }

  @override
  void onClose() {
    amount.dispose();
    notes.dispose();
    super.onClose();
  }

  Future<void> save() async {
    final l = AppLocalizations.of(Get.context!)!;
    if (orderId.value == null || amount.text.trim().isEmpty) {
      SsSnack.error(l.requiredField, title: l.receivePayment);
      return;
    }
    saving.value = true;
    try {
      await api.dio.post('/payments', data: {
        'orderId': orderId.value,
        'amount': amount.text.trim(),
        'kind': kind.value,
        'method': method.value,
        if (notes.text.trim().isNotEmpty) 'notes': notes.text.trim(),
        'idempotencyKey': idempotencyKey,
      });
      Get.back();
      SsSnack.success(l.save, title: l.receivePayment);
    } on DioException catch (e) {
      SsSnack.fromError(e, title: l.receivePayment);
    } finally {
      saving.value = false;
    }
  }
}
