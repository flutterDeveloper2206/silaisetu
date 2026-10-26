import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_debug_fill_button.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/measurement_form_controller.dart';
import '../controllers/measurements_list_controller.dart';
import '../data/measurement_catalog.dart';
import '../data/measurement_l10n.dart';
import '../widgets/measurement_part_guide.dart';

class MeasurementsListView extends StatelessWidget {
  const MeasurementsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MeasurementsListController(), tag: 'list');
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return SsPage(
      title: l.measurements,
      actions: [
        IconButton(
          onPressed: () async {
            await Get.toNamed('/measurements/new',
                arguments: {'customerId': c.customerId.value});
            c.load();
          },
          icon: const Icon(Icons.add),
        ),
      ],
      body: Obx(() {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SsLayout.pageH,
                SsLayout.tight,
                SsLayout.pageH,
                SsLayout.tight,
              ),
              child: DropdownButtonFormField<String>(
                key: ValueKey('list_customer_${c.customerId.value}'),
                initialValue: c.customerId.value,
                decoration: InputDecoration(labelText: l.customer),
                items: c.customers
                    .map((cust) => DropdownMenuItem(
                          value: '${(cust as Map)['id']}',
                          child: Text('${cust['fullName']}'),
                        ))
                    .toList(),
                onChanged: c.onCustomerChanged,
              ),
            ),
            Expanded(
              child: c.loading.value
                  ? const SsLoading()
                  : c.error.value != null
                      ? SsError(onRetry: c.load, message: c.error.value)
                      : c.items.isEmpty
                          ? SsEmpty(message: l.empty)
                          : ListView.separated(
                              padding: SsLayout.listPadding,
                              itemCount: c.items.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.08),
                              ),
                              itemBuilder: (_, i) {
                                final m = c.items[i] as Map;
                                return SsListTile(
                                  leading: const SsPrimaryIconBox(
                                    Icons.straighten,
                                  ),
                                  title:
                                      '${m['garmentTemplate']?['name'] ?? l.measurements} v${m['version'] ?? ''}',
                                  subtitle:
                                      '${m['unit']} · ${m['createdAt'] ?? ''}',
                                );
                              },
                            ),
            ),
          ],
        );
      }),
    );
  }
}

class MeasurementFormView extends StatelessWidget {
  const MeasurementFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MeasurementFormController(), tag: 'form');
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final unitLabel =
          c.unit.value == 'CM' ? l.unitCm : l.unitInches;
      return SsPage(
        title: l.addMeasurement,
        body: c.loading.value
            ? const SsLoading()
            : ListView(
                padding: SsLayout.formPadding,
                children: [
                  if (c.garmentNameHint.value != null &&
                      c.garmentNameHint.value!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SsLayout.item),
                      child: Text(
                        '${l.garmentName}: ${c.garmentNameHint.value}',
                        style: SsLayout.titleStyle(context),
                      ),
                    ),
                  SsDebugFillButton(onPressed: c.debugFill),
                  DropdownButtonFormField<String>(
                    key: ValueKey('form_customer_${c.customerId.value}'),
                    initialValue: c.customerId.value,
                    decoration: InputDecoration(labelText: l.customer),
                    items: c.customers
                        .map((cust) => DropdownMenuItem(
                              value: '${(cust as Map)['id']}',
                              child: Text('${cust['fullName']}'),
                            ))
                        .toList(),
                    onChanged: (v) => c.customerId.value = v,
                  ),
                  const SizedBox(height: SsLayout.section),
                  Text(l.measurementCategory,
                      style: SsLayout.titleStyle(context)),
                  const SizedBox(height: 4),
                  Text(
                    l.measurementCategoryHint,
                    style: SsLayout.captionStyle(context),
                  ),
                  const SizedBox(height: SsLayout.item),
                  Wrap(
                    spacing: SsLayout.tight,
                    runSpacing: SsLayout.tight,
                    children: [
                      for (final cat in MeasurementCatalog.categories)
                        ChoiceChip(
                          avatar: Icon(c.iconFor(cat), size: 18),
                          label: Text(l.measurementCategoryLabel(cat.id)),
                          selected: c.categoryId.value == cat.id,
                          onSelected: (_) => c.selectCategory(cat.id),
                        ),
                    ],
                  ),
                  if (c.categoryId.value != null) ...[
                    const SizedBox(height: SsLayout.section),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                            value: 'INCH', label: Text(l.unitInches)),
                        ButtonSegment(value: 'CM', label: Text(l.unitCm)),
                      ],
                      selected: {c.unit.value},
                      onSelectionChanged: (s) => c.unit.value = s.first,
                    ),
                    const SizedBox(height: SsLayout.section),
                    MeasurementOverviewCard(
                      hint:
                          '${l.measurementCategoryLabel(c.categoryId.value!)} — ${l.measurementsHint}',
                    ),
                    const SizedBox(height: SsLayout.section),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l.measurementCategoryLabel(c.categoryId.value!)} (${c.fieldDefs.length})',
                            style: SsLayout.titleStyle(context),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => c.addComponent(context),
                          icon: Icon(Icons.add, color: SsLayout.title(scheme)),
                          label: Text(
                            l.addComponent,
                            style: TextStyle(color: SsLayout.title(scheme)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SsLayout.tight),
                    ...c.fieldDefs.map(
                      (def) => MeasurementFieldCard(
                        fieldId: def.id,
                        label: def.custom
                            ? def.name
                            : l.measurementPomLabel(def.id,
                                fallback: def.name),
                        code: def.code,
                        controller: c.fields[def.id]!,
                        unitLabel: unitLabel,
                        required: def.required,
                        helpText: def.helpText,
                        onRemove:
                            def.custom ? () => c.removeField(def) : null,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => c.addComponent(context),
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(l.addComponent),
                    ),
                    const SizedBox(height: SsLayout.section),
                    TextField(
                      controller: c.notes,
                      maxLines: 2,
                      decoration: InputDecoration(labelText: l.notes),
                    ),
                    SsFormActions(
                      child: FilledButton(
                        onPressed:
                            c.saving.value ? null : () => c.save(context),
                        child: Text(c.saving.value ? l.loading : l.save),
                      ),
                    ),
                  ],
                ],
              ),
      );
    });
  }
}
