import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_debug_fill_button.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/order_form_controller.dart';

class OrderFormView extends StatelessWidget {
  const OrderFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final c = Get.put(OrderFormController());

    return SsPage(
      title: l.newOrder,
      body: Obx(() {
        if (c.loading.value) return const SsLoading();
        if (c.error.value != null) {
          return SsError(onRetry: c.bootstrap, message: c.error.value);
        }
        return ListView(
          padding: SsLayout.formPadding,
          children: [
            SsDebugFillButton(onPressed: c.fillDebug),
            DropdownButtonFormField<String>(
              value: c.customerId.value,
              decoration: InputDecoration(labelText: l.customer),
              items: c.customers
                  .map((cust) => DropdownMenuItem(
                        value: '${(cust as Map)['id']}',
                        child: Text('${cust['fullName']} · ${cust['phone']}'),
                      ))
                  .toList(),
              onChanged: (v) => c.customerId.value = v,
            ),
            const SizedBox(height: SsLayout.section),
            Text(l.orderGarments, style: SsLayout.titleStyle(context)),
            Text(l.garmentNameHint, style: SsLayout.captionStyle(context)),
            const SizedBox(height: SsLayout.item),
            for (var i = 0; i < c.lines.length; i++) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.1),
                  ),
                  borderRadius: BorderRadius.circular(SsLayout.radiusSm),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${l.garmentName} ${i + 1}',
                              style: SsLayout.titleStyle(context),
                            ),
                          ),
                          if (c.lines.length > 1)
                            IconButton(
                              onPressed: () => c.removeLine(i),
                              icon: Icon(
                                Icons.delete_outline,
                                color: scheme.error,
                              ),
                            ),
                        ],
                      ),
                      TextField(
                        controller: c.lines[i].name,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l.garmentName,
                          hintText: l.garmentNameHint,
                        ),
                        onChanged: (v) {
                          c.lines[i].templateId = c.templateIdForHint(v);
                        },
                      ),
                      const SizedBox(height: SsLayout.item),
                      if (c.templates.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: c.lines[i].templateId,
                          decoration: InputDecoration(
                            labelText: l.garmentTemplates,
                          ),
                          items: [
                            ...c.templates.map((t) => DropdownMenuItem(
                                  value: '${(t as Map)['id']}',
                                  child: Text('${t['name']}'),
                                )),
                          ],
                          onChanged: (v) {
                            c.lines[i].templateId = v;
                            c.lines.refresh();
                          },
                        ),
                      const SizedBox(height: SsLayout.item),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: c.lines[i].qty,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l.quantity,
                              ),
                            ),
                          ),
                          const SizedBox(width: SsLayout.item),
                          Expanded(
                            child: TextField(
                              controller: c.lines[i].price,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l.unitPrice,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SsLayout.item),
            ],
            OutlinedButton.icon(
              onPressed: () => c.addLine(),
              icon: const Icon(Icons.add),
              label: Text(l.addGarment),
            ),
            const SizedBox(height: SsLayout.section),
            SsListTile(
              title: l.trialDate,
              subtitle:
                  c.trial.value?.toIso8601String().substring(0, 10) ?? '—',
              trailing: Icon(
                Icons.event,
                color: SsLayout.body(scheme),
              ),
              onTap: () => c.pickDate(context, true),
            ),
            SsListTile(
              title: l.deliveryDate,
              subtitle:
                  c.delivery.value?.toIso8601String().substring(0, 10) ?? '—',
              trailing: Icon(
                Icons.local_shipping_outlined,
                color: SsLayout.body(scheme),
              ),
              onTap: () => c.pickDate(context, false),
            ),
            TextField(
              controller: c.advance,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.advancePayment),
            ),
            const SizedBox(height: SsLayout.item),
            TextField(
              controller: c.notes,
              maxLines: 3,
              decoration: InputDecoration(labelText: l.notes),
            ),
            SsFormActions(
              child: FilledButton(
                onPressed: c.saving.value ? null : () => c.save(context),
                child: Text(c.saving.value ? l.loading : l.save),
              ),
            ),
          ],
        );
      }),
    );
  }
}
