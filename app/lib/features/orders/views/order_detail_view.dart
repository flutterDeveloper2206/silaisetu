import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/localization/ss_labels.dart';
import '../../../core/theme/ss_layout.dart';
// ignore: unused_import — kept for feature-local PDF/WhatsApp/feedback surface
import '../../../core/utils/ss_feedback.dart';
import '../../../core/utils/ss_invoice_pdf.dart';
// ignore: unused_import — kept for feature-local PDF/WhatsApp/feedback surface
import '../../../core/utils/ss_whatsapp.dart';
import '../../../core/widgets/ss_measurement_values.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/order_detail_controller.dart';

const workflow = [
  'NEW',
  'CUTTING',
  'STITCHING',
  'TRIAL',
  'READY',
  'DELIVERED',
];

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final c = Get.put(OrderDetailController(id), tag: id);

    return Obx(() {
      final o = c.order.value;
      final customer = o?['customer'] as Map? ?? {};
      final items = o?['items'] as List? ?? [];
      final status = '${o?['status'] ?? ''}';
      final loading = c.loading.value;
      final error = c.error.value;

      return SsPage(
        title: '${o?['orderNumber'] ?? l.orders}',
        actions: [
          if (!loading && error == null) ...[
            IconButton(
              tooltip: l.whatsAppOrder,
              onPressed: () => c.shareWhatsApp(context),
              icon: const Icon(Icons.chat_outlined),
            ),
            IconButton(
              tooltip: l.sharePdf,
              onPressed: () => ssShareInvoicePdf(
                context,
                c.invoiceData(l),
                title: l.sharePdf,
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),
          ],
          IconButton(
            tooltip: l.receivePayment,
            onPressed: () async {
              await Get.toNamed('/payments/receive', arguments: {
                'orderId': id,
              });
              c.load();
            },
            icon: const Icon(Icons.payments_outlined),
          ),
        ],
        body: loading
            ? const SsLoading()
            : error != null
                ? SsError(onRetry: c.load, message: error)
                : ListView(
                    padding: SsLayout.formPadding,
                    children: [
                      Text(
                        '${customer['fullName']}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: SsLayout.title(scheme),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '${customer['phone']}',
                        style: SsLayout.bodyStyle(context),
                      ),
                      const SizedBox(height: SsLayout.section),
                      Text(l.orderSummary, style: SsLayout.titleStyle(context)),
                      const SizedBox(height: SsLayout.tight),
                      Text(
                        '${l.status}: ${l.orderStatusLabel(status)}',
                        style: SsLayout.bodyStyle(context),
                      ),
                      Text(
                        '${l.total}: ₹${o?['totalAmount']}',
                        style: SsLayout.bodyStyle(context),
                      ),
                      Text(
                        '${l.paid}: ₹${o?['amountPaid']}',
                        style: SsLayout.bodyStyle(context),
                      ),
                      Text(
                        '${l.balanceDue}: ₹${o?['balanceDue']}',
                        style: TextStyle(
                          color: SsLayout.title(scheme),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (o?['trialDate'] != null)
                        Text(
                          '${l.trialDate}: ${'${o?['trialDate']}'.substring(0, 10)}',
                          style: SsLayout.bodyStyle(context),
                        ),
                      if (o?['deliveryDate'] != null)
                        Text(
                          '${l.deliveryDate}: ${'${o?['deliveryDate']}'.substring(0, 10)}',
                          style: SsLayout.bodyStyle(context),
                        ),
                      SsSectionTitle(l.orderGarments),
                      ...items.map((it) {
                        final m = it as Map;
                        final snap = c.snapshot(m);
                        final values = snap?['values'];
                        final unit = l.unitLabel('${snap?['unit'] ?? ''}');
                        final hasMeas = values is Map && values.isNotEmpty;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: SsLayout.item),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: scheme.onSurface.withValues(alpha: 0.1),
                              ),
                              borderRadius:
                                  BorderRadius.circular(SsLayout.radiusSm),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          l.garmentLineTitle(
                                            '${m['garmentName']}',
                                            '${m['quantity']}',
                                          ),
                                          style: SsLayout.titleStyle(context),
                                        ),
                                      ),
                                      Text(
                                        '₹${m['lineTotal'] ?? m['unitPrice']}',
                                        style: TextStyle(
                                          color: SsLayout.title(scheme),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ('${m['styleNotes'] ?? ''}'.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${m['styleNotes']}',
                                        style: SsLayout.captionStyle(context),
                                      ),
                                    ),
                                  const SizedBox(height: SsLayout.item),
                                  Text(
                                    l.measurements,
                                    style: TextStyle(
                                      color: SsLayout.body(scheme),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (hasMeas)
                                    SsMeasurementValues(
                                      values: values,
                                      unit: unit,
                                    )
                                  else
                                    Text(
                                      l.noMeasurementYet,
                                      style: SsLayout.captionStyle(context),
                                    ),
                                  const SizedBox(height: SsLayout.item),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: hasMeas
                                        ? OutlinedButton.icon(
                                            onPressed: () =>
                                                c.addMeasurement(m),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                            ),
                                            label: Text(l.updateMeasurement),
                                          )
                                        : FilledButton.icon(
                                            onPressed: () =>
                                                c.addMeasurement(m),
                                            icon: const Icon(
                                              Icons.straighten,
                                              size: 18,
                                            ),
                                            label: Text(l.addMeasurement),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      SsSectionTitle(l.workflow),
                      Wrap(
                        spacing: SsLayout.tight,
                        runSpacing: SsLayout.tight,
                        children: [
                          for (final s in workflow)
                            if (s != status)
                              ActionChip(
                                label: Text(l.orderStatusLabel(s)),
                                onPressed: () => c.setStatus(s),
                              ),
                          ActionChip(
                            label: Text(l.cancelOrder),
                            onPressed:
                                status == 'CANCELLED' || status == 'DELIVERED'
                                    ? null
                                    : c.cancel,
                          ),
                        ],
                      ),
                      SsSectionTitle(l.payments),
                      if (c.payments.isEmpty)
                        Text(l.noPaymentsYet,
                            style: SsLayout.bodyStyle(context))
                      else
                        ...c.payments.map((p) {
                          final m = p as Map;
                          return SsListTile(
                            title:
                                '₹${m['amount']} · ${l.paymentKindLabel('${m['kind']}')}',
                            subtitle:
                                l.paymentMethodLabel('${m['method'] ?? ''}'),
                            trailing: m['isReversed'] == true
                                ? Text(
                                    l.reversed,
                                    style: TextStyle(
                                        color: SsLayout.muted(scheme)),
                                  )
                                : null,
                          );
                        }),
                      const SizedBox(height: SsLayout.item),
                      FilledButton(
                        onPressed: () async {
                          await Get.toNamed('/payments/receive', arguments: {
                            'orderId': id,
                          });
                          c.load();
                        },
                        child: Text(l.receivePayment),
                      ),
                      const SizedBox(height: SsLayout.tight),
                      OutlinedButton(
                        onPressed: () =>
                            Get.toNamed('/payments/$id/receipt'),
                        child: Text(l.viewReceipt),
                      ),
                      const SizedBox(height: SsLayout.tight),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => ssPreviewInvoicePdf(
                                context,
                                c.invoiceData(l),
                                title: l.previewPdf,
                              ),
                              icon: const Icon(Icons.visibility_outlined,
                                  size: 18),
                              label: Text(l.previewPdf),
                            ),
                          ),
                          const SizedBox(width: SsLayout.tight),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => c.shareWhatsApp(context),
                              icon: const Icon(Icons.chat_outlined, size: 18),
                              label: Text(l.shareWhatsApp),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      );
    });
  }
}
