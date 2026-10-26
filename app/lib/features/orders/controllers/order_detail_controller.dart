import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/localization/ss_labels.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ss_feedback.dart';
import '../../../core/utils/ss_invoice_pdf.dart';
import '../../../core/utils/ss_whatsapp.dart';

class OrderDetailController extends GetxController {
  OrderDetailController(this.id);

  final String id;
  final api = Get.find<ApiClient>();

  final order = Rxn<Map<String, dynamic>>();
  final payments = <dynamic>[].obs;
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
        api.dio.get('/orders/$id'),
        api.dio.get('/payments/order/$id'),
      ]);
      order.value = results[0].data as Map<String, dynamic>;
      final payData = results[1].data;
      payments.assignAll(
        payData is List
            ? payData
            : ((payData as Map?)?['items'] as List? ?? []),
      );
      loading.value = false;
    } catch (e) {
      error.value = ssErrorMessage(e, context: Get.context);
      loading.value = false;
    }
  }

  SsInvoiceData invoiceData(AppLocalizations l) {
    final o = order.value ?? {};
    final shop = o['shop'] as Map?;
    final settings = shop?['settings'] as Map?;
    return ssInvoiceFromOrder(
      order: o,
      payments: payments,
      statusLabel: l.orderStatusLabel('${o['status']}'),
      kindLabel: l.paymentKindLabel,
      methodLabel: l.paymentMethodLabel,
      shop: shop,
      settings: settings,
    );
  }

  Future<void> shareWhatsApp(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final o = order.value;
    if (o == null) return;
    final customer = o['customer'] as Map? ?? {};
    final shop = o['shop'] as Map? ?? {};
    final delivery = o['deliveryDate'] == null
        ? null
        : '${o['deliveryDate']}'.substring(0, 10);
    await ssOpenWhatsApp(
      context: context,
      phone: '${customer['phone']}',
      title: l.whatsAppOrder,
      message: ssOrderWhatsAppMessage(
        shopName: '${shop['name'] ?? l.appName}',
        orderNumber: '${o['orderNumber']}',
        customerName: '${customer['fullName'] ?? ''}',
        statusLabel: l.orderStatusLabel('${o['status']}'),
        deliveryDate: delivery,
        total: '${o['totalAmount']}',
        paid: '${o['amountPaid']}',
        balance: '${o['balanceDue']}',
      ),
    );
  }

  Future<void> setStatus(String status) async {
    final ctx = Get.context;
    final l = ctx != null ? AppLocalizations.of(ctx) : null;
    try {
      await api.dio.patch('/orders/$id/status', data: {
        'status': status,
      });
      await load();
      if (l != null) {
        SsSnack.success(
          l.orderStatusLabel(status),
          title: l.statusUpdated,
          context: ctx,
        );
      }
    } on DioException catch (e) {
      if (l != null) {
        SsSnack.fromError(e, title: l.orders, context: ctx);
      }
    }
  }

  Future<void> cancel() async {
    final ctx = Get.context;
    final l = ctx != null ? AppLocalizations.of(ctx) : null;
    if (l == null) return;
    final reason = TextEditingController();
    try {
      final ok = await Get.dialog<bool>(
        AlertDialog(
          title: Text(l.cancelOrder),
          content: TextField(
            controller: reason,
            decoration: InputDecoration(labelText: l.reason),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: Text(l.continueLabel),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await api.dio.patch('/orders/$id/status', data: {
        'status': 'CANCELLED',
        'note': reason.text.trim(),
      });
      await load();
    } on DioException catch (e) {
      SsSnack.fromError(e, title: l.cancelOrder, context: ctx);
    } finally {
      reason.dispose();
    }
  }

  Future<void> addMeasurement(Map item) async {
    final customer = order.value?['customer'] as Map? ?? {};
    final customerId = '${customer['id'] ?? ''}';
    if (customerId.isEmpty) return;
    await Get.toNamed('/measurements/new', arguments: {
      'customerId': customerId,
      'orderId': id,
      'orderItemId': '${item['id']}',
      'garmentName': '${item['garmentName'] ?? ''}',
      'garmentTemplateId': item['garmentTemplateId'],
    });
    await load();
  }

  Map? snapshot(Map item) {
    final s = item['measurementSnapshot'];
    return s is Map ? s : null;
  }
}
