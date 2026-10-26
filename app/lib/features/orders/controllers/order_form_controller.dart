import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ss_feedback.dart';

class OrderLineDraft {
  OrderLineDraft({String? name, String? qty, String? price, this.templateId})
      : name = TextEditingController(text: name ?? ''),
        qty = TextEditingController(text: qty ?? '1'),
        price = TextEditingController(text: price ?? '500');

  String? templateId;
  final TextEditingController name;
  final TextEditingController qty;
  final TextEditingController price;

  void dispose() {
    name.dispose();
    qty.dispose();
    price.dispose();
  }
}

class OrderFormController extends GetxController {
  final api = Get.find<ApiClient>();

  final customers = <dynamic>[].obs;
  final templates = <dynamic>[].obs;
  final customerId = RxnString();
  final lines = <OrderLineDraft>[OrderLineDraft()].obs;
  final notes = TextEditingController();
  final advance = TextEditingController();
  final trial = Rxn<DateTime>();
  final delivery = Rxn<DateTime>();
  final loading = true.obs;
  final saving = false.obs;
  final error = RxnString();
  late final String idempotencyKey;

  @override
  void onInit() {
    super.onInit();
    idempotencyKey = _uuid();
    final args = Get.arguments;
    if (args is Map && args['customerId'] != null) {
      customerId.value = '${args['customerId']}';
    }
    bootstrap();
  }

  @override
  void onClose() {
    notes.dispose();
    advance.dispose();
    for (final line in lines) {
      line.dispose();
    }
    super.onClose();
  }

  String _uuid() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String h(int i) => b[i].toRadixString(16).padLeft(2, '0');
    return '${h(0)}${h(1)}${h(2)}${h(3)}-${h(4)}${h(5)}-${h(6)}${h(7)}-${h(8)}${h(9)}-${h(10)}${h(11)}${h(12)}${h(13)}${h(14)}${h(15)}';
  }

  Future<void> bootstrap() async {
    loading.value = true;
    error.value = null;
    try {
      final results = await Future.wait([
        api.dio.get('/customers', queryParameters: {'pageSize': 100}),
        api.dio.get('/garment-templates'),
      ]);
      customers.assignAll((results[0].data as Map)['items'] as List? ?? []);
      final tData = results[1].data;
      templates.assignAll(
        tData is List
            ? tData
            : ((tData as Map?)?['items'] as List? ?? []),
      );
      loading.value = false;
    } catch (e) {
      error.value = '$e';
      loading.value = false;
    }
  }

  void addLine({String? name, String? templateId}) {
    lines.add(OrderLineDraft(name: name, templateId: templateId));
  }

  void removeLine(int index) {
    if (lines.length <= 1) return;
    lines.removeAt(index).dispose();
  }

  Future<void> pickDate(BuildContext context, bool isTrial) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d == null) return;
    if (isTrial) {
      trial.value = d;
    } else {
      delivery.value = d;
    }
  }

  String? templateIdForHint(String name) {
    final n = name.toLowerCase();
    for (final t in templates) {
      if (t is! Map) continue;
      final code = '${t['code'] ?? ''}'.toLowerCase();
      final tn = '${t['name'] ?? ''}'.toLowerCase();
      if (n.contains('pant') || n.contains('trouser')) {
        if (code.contains('trouser') ||
            tn.contains('trouser') ||
            tn.contains('pant')) {
          return '${t['id']}';
        }
      }
      if (n.contains('shirt') &&
          !n.contains('t-shirt') &&
          !n.contains('tshirt')) {
        if (code == 'shirt' || tn == 'shirt') return '${t['id']}';
      }
      if (n.contains('kurta') &&
          (code.contains('kurta') || tn.contains('kurta'))) {
        return '${t['id']}';
      }
      if (n.contains('blouse') &&
          (code.contains('blouse') || tn.contains('blouse'))) {
        return '${t['id']}';
      }
    }
    return templates.isNotEmpty && templates.first is Map
        ? '${(templates.first as Map)['id']}'
        : null;
  }

  void fillDebug() {
    if (customers.isNotEmpty) {
      customerId.value = '${(customers.first as Map)['id']}';
    }
    for (final line in lines) {
      line.dispose();
    }
    lines
      ..clear()
      ..add(OrderLineDraft(
        name: 'Green Shirt',
        price: '850',
        templateId: templateIdForHint('shirt'),
      ))
      ..add(OrderLineDraft(
        name: 'White Pant',
        price: '650',
        templateId: templateIdForHint('pant'),
      ));
    advance.text = '200';
    notes.text = 'Debug sample order';
    final now = DateTime.now();
    trial.value = now.add(const Duration(days: 5));
    delivery.value = now.add(const Duration(days: 10));
  }

  Future<void> save(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    if (customerId.value == null) {
      SsSnack.error(l.requiredField, title: l.newOrder, context: context);
      return;
    }
    final items = <Map<String, dynamic>>[];
    for (final line in lines) {
      final name = line.name.text.trim();
      if (name.isEmpty) continue;
      items.add({
        if (line.templateId != null) 'garmentTemplateId': line.templateId,
        'garmentName': name,
        'quantity': int.tryParse(line.qty.text) ?? 1,
        'unitPrice':
            line.price.text.trim().isEmpty ? '0' : line.price.text.trim(),
      });
    }
    if (items.isEmpty) {
      SsSnack.error(l.garmentNameRequired, title: l.newOrder, context: context);
      return;
    }
    saving.value = true;
    try {
      final trialDate = trial.value;
      final deliveryDate = delivery.value;
      final res = await api.dio.post('/orders', data: {
        'customerId': customerId.value,
        'items': items,
        if (trialDate != null)
          'trialDate': trialDate.toIso8601String().substring(0, 10),
        if (deliveryDate != null)
          'deliveryDate': deliveryDate.toIso8601String().substring(0, 10),
        if (notes.text.trim().isNotEmpty) 'notes': notes.text.trim(),
        if (advance.text.trim().isNotEmpty) 'advanceAmount': advance.text.trim(),
        if (advance.text.trim().isNotEmpty) 'advanceMethod': 'CASH',
        'idempotencyKey': idempotencyKey,
      });
      Get.offNamed('/orders/${res.data['id']}');
    } on DioException catch (e) {
      SsSnack.fromError(e, title: l.newOrder, context: context);
    } finally {
      saving.value = false;
    }
  }
}
