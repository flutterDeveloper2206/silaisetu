import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/localization/ss_labels.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ss_feedback.dart';
import '../../../core/utils/ss_invoice_pdf.dart';
import '../../../core/utils/ss_whatsapp.dart';

class ReceiptController extends GetxController {
  ReceiptController(this.orderId);

  final String orderId;
  final api = Get.find<ApiClient>();
  final payments = <dynamic>[].obs;
  final order = Rxn<Map>();
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
        api.dio.get('/orders/$orderId'),
        api.dio.get('/payments/order/$orderId'),
      ]);
      order.value = results[0].data as Map;
      payments.assignAll(
        results[1].data is List
            ? results[1].data as List
            : ((results[1].data as Map?)?['items'] as List? ?? []),
      );
      loading.value = false;
    } catch (e) {
      error.value = ssErrorMessage(e);
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
}
