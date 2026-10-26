import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/localization/ss_labels.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/utils/ss_invoice_pdf.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/payments_hub_controller.dart';
import '../controllers/receipt_controller.dart';
import '../controllers/receive_payment_controller.dart';

class PaymentsHubView extends StatelessWidget {
  const PaymentsHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final c = Get.put(PaymentsHubController());
    return SsPage(
      title: l.payments,
      actions: [
        IconButton(
          onPressed: () => Get.toNamed('/payments/receive'),
          icon: const Icon(Icons.add),
        ),
      ],
      body: Obx(() {
        if (c.loading.value) return const SsLoading();
        if (c.error.value != null) {
          return SsError(onRetry: c.load, message: c.error.value);
        }
        if (c.orders.isEmpty) return SsEmpty(message: l.empty);
        return ListView.separated(
          padding: SsLayout.listPadding,
          itemCount: c.orders.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
          itemBuilder: (_, i) {
            final o = c.orders[i] as Map;
            final customer = o['customer'] as Map? ?? {};
            return SsListTile(
              leading: const SsPrimaryIconBox(
                Icons.payments_outlined,
              ),
              title: '${o['orderNumber']}',
              subtitle: '${customer['fullName']}',
              trailing: Text(
                'Due ₹${o['balanceDue']}',
                style: TextStyle(
                  color: SsLayout.title(scheme),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                await Get.toNamed('/payments/receive', arguments: {
                  'orderId': o['id'],
                });
                c.load();
              },
            );
          },
        );
      }),
    );
  }
}

class ReceivePaymentView extends StatelessWidget {
  const ReceivePaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = Get.put(ReceivePaymentController());
    final args = Get.arguments;
    if (args is Map) c.orderId.value = '${args['orderId']}';
    return SsPage(
      title: l.receivePayment,
      body: Obx(() {
        return ListView(
          padding: SsLayout.formPadding,
          children: [
            Text(
              '${l.orders}: ${c.orderId.value ?? '—'}',
              style: SsLayout.bodyStyle(context),
            ),
            const SizedBox(height: SsLayout.item),
            TextField(
              controller: c.amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.amount),
            ),
            const SizedBox(height: SsLayout.item),
            DropdownButtonFormField<String>(
              value: c.kind.value,
              decoration: InputDecoration(labelText: l.paymentKind),
              items: const [
                DropdownMenuItem(value: 'ADVANCE', child: Text('ADVANCE')),
                DropdownMenuItem(value: 'PARTIAL', child: Text('PARTIAL')),
                DropdownMenuItem(value: 'FINAL', child: Text('FINAL')),
              ],
              onChanged: (v) => c.kind.value = v ?? 'PARTIAL',
            ),
            const SizedBox(height: SsLayout.item),
            DropdownButtonFormField<String>(
              value: c.method.value,
              decoration: InputDecoration(labelText: l.paymentMethod),
              items: const [
                DropdownMenuItem(value: 'CASH', child: Text('CASH')),
                DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                DropdownMenuItem(value: 'CARD', child: Text('CARD')),
                DropdownMenuItem(value: 'BANK', child: Text('BANK')),
                DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
              ],
              onChanged: (v) => c.method.value = v ?? 'CASH',
            ),
            const SizedBox(height: SsLayout.item),
            TextField(
              controller: c.notes,
              decoration: InputDecoration(labelText: l.notes),
            ),
            SsFormActions(
              child: FilledButton(
                onPressed: c.saving.value ? null : c.save,
                child: Text(c.saving.value ? l.loading : l.save),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class ReceiptView extends StatelessWidget {
  const ReceiptView({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final c = Get.put(ReceiptController(orderId), tag: orderId);
    return Obx(() {
      return SsPage(
        title: l.viewReceipt,
        actions: [
          if (!c.loading.value && c.error.value == null && c.order.value != null) ...[
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
        ],
        body: c.loading.value
            ? const SsLoading()
            : c.error.value != null
                ? SsError(onRetry: c.load, message: c.error.value)
                : ListView(
                    padding: SsLayout.formPadding,
                    children: [
                      Text(
                        '${c.order.value?['shop'] is Map ? (c.order.value!['shop'] as Map)['name'] : l.appName}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: SsLayout.title(scheme),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '${c.order.value?['orderNumber']}',
                        style: SsLayout.titleStyle(context),
                      ),
                      Text(
                        '${l.total}: ₹${c.order.value?['totalAmount']}',
                        style: SsLayout.bodyStyle(context),
                      ),
                      Text(
                        '${l.paid}: ₹${c.order.value?['amountPaid']}',
                        style: SsLayout.bodyStyle(context),
                      ),
                      Text(
                        '${l.balanceDue}: ₹${c.order.value?['balanceDue']}',
                        style: SsLayout.bodyStyle(context),
                      ),
                      Divider(
                        color: scheme.onSurface.withValues(alpha: 0.08),
                      ),
                      ...c.payments.map((p) {
                        final m = p as Map;
                        return SsListTile(
                          title:
                              '₹${m['amount']} · ${l.paymentKindLabel('${m['kind']}')}',
                          subtitle:
                              '${l.paymentMethodLabel('${m['method']}')} · ${m['createdAt'] ?? ''}',
                        );
                      }),
                      const SizedBox(height: SsLayout.item),
                      FilledButton.icon(
                        onPressed: () => ssShareInvoicePdf(
                          context,
                          c.invoiceData(l),
                          title: l.sharePdf,
                        ),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: Text(l.sharePdf),
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
                              icon: const Icon(Icons.visibility_outlined, size: 18),
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
