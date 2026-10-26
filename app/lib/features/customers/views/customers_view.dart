import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/ss_labels.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/utils/ss_whatsapp.dart';
import '../../../core/widgets/ss_debug_fill_button.dart';
import '../../../core/widgets/ss_measurement_values.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/customer_detail_controller.dart';
import '../controllers/customer_form_controller.dart';
import '../controllers/customers_controller.dart';

class CustomersView extends StatelessWidget {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CustomersController());
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final body = Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SsLayout.pageH,
              SsLayout.tight,
              SsLayout.pageH,
              SsLayout.tight,
            ),
            child: SsSearchField(
              controller: c.search,
              hint: l.searchCustomers,
              onSubmitted: (_) => c.load(),
              onRefresh: c.load,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SsLayout.pageH),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed('/measurements'),
                    icon: const Icon(Icons.straighten, size: 18),
                    label: Text(l.measurements),
                  ),
                ),
                const SizedBox(width: SsLayout.tight),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed('/orders/new'),
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: Text(l.newOrder),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SsLayout.tight),
          Expanded(
            child: c.loading.value
                ? const SsLoading()
                : c.error.value != null
                    ? SsError(onRetry: c.load, message: c.error.value)
                    : c.items.isEmpty
                        ? ListView(
                            padding: SsLayout.pagePadding,
                            children: [
                              const SizedBox(height: 48),
                              Icon(
                                Icons.people_outline,
                                size: 56,
                                color: SsLayout.muted(scheme),
                              ),
                              const SizedBox(height: SsLayout.item),
                              Center(
                                child: Text(
                                  l.noCustomersYet,
                                  style: SsLayout.bodyStyle(context),
                                ),
                              ),
                              const SizedBox(height: SsLayout.tight),
                              Center(
                                child: FilledButton(
                                  onPressed: () async {
                                    await Get.toNamed('/customers/new');
                                    c.load();
                                  },
                                  child: Text(l.addCustomer),
                                ),
                              ),
                            ],
                          )
                        : RefreshIndicator(
                            onRefresh: c.load,
                            child: ListView.separated(
                              padding: SsLayout.listPadding,
                              itemCount: c.items.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: scheme.onSurface.withValues(alpha: 0.08),
                              ),
                              itemBuilder: (_, i) {
                                final item = c.items[i] as Map;
                                return SsListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: scheme.onSurface,
                                    foregroundColor: scheme.surface,
                                    child: Text(
                                      '${item['fullName']}'.isNotEmpty
                                          ? '${item['fullName']}'[0]
                                              .toUpperCase()
                                          : '?',
                                    ),
                                  ),
                                  title: '${item['fullName']}',
                                  subtitle: '${item['phone']}',
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: l.shareWhatsApp,
                                        icon: Icon(
                                          Icons.chat_outlined,
                                          color: SsLayout.body(scheme),
                                        ),
                                        onPressed: () => ssOpenWhatsApp(
                                          context: context,
                                          phone: '${item['phone']}',
                                          title: l.shareWhatsApp,
                                          message:
                                              'Hello ${item['fullName']},\n\n— ${l.appName}',
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: l.phone,
                                        icon: Icon(
                                          Icons.call_outlined,
                                          color: SsLayout.body(scheme),
                                        ),
                                        onPressed: () async {
                                          final uri = Uri(
                                            scheme: 'tel',
                                            path: '${item['phone']}',
                                          );
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri);
                                          }
                                        },
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: SsLayout.muted(scheme),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    await Get.toNamed(
                                      '/customers/${item['id']}',
                                    );
                                    c.load();
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      );

      return SsPage(
        title: l.customers,
        actions: [
          IconButton(
            tooltip: c.showArchived.value ? l.active : l.archived,
            onPressed: c.toggleArchived,
            icon: Icon(
              c.showArchived.value
                  ? Icons.unarchive
                  : Icons.archive_outlined,
              color: SsLayout.title(scheme),
            ),
          ),
        ],
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'customers_add_fab',
          onPressed: () async {
            await Get.toNamed('/customers/new');
            c.load();
          },
          icon: const Icon(Icons.person_add_outlined),
          label: Text(l.addCustomer),
        ),
        body: body,
      );
    });
  }
}

class CustomerFormView extends StatelessWidget {
  const CustomerFormView({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CustomerFormController(id: id), tag: id ?? 'new');
    final l = AppLocalizations.of(context)!;

    return Obx(() => SsPage(
          title: c.isNew ? l.addCustomer : l.editCustomer,
          body: c.fetching.value
              ? const SsLoading()
              : Form(
                  key: c.formKey,
                  child: ListView(
                    padding: SsLayout.formPadding,
                    children: [
                      if (c.isNew)
                        SsDebugFillButton(onPressed: c.debugFill),
                      TextFormField(
                        controller: c.name,
                        decoration: InputDecoration(labelText: l.fullName),
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? l.requiredField
                            : null,
                      ),
                      const SizedBox(height: SsLayout.item),
                      TextFormField(
                        controller: c.phone,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(labelText: l.phone),
                        validator: (v) => (v == null || v.trim().length < 8)
                            ? l.invalidPhone
                            : null,
                      ),
                      const SizedBox(height: SsLayout.item),
                      TextFormField(
                        controller: c.alt,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(labelText: l.altMobile),
                      ),
                      const SizedBox(height: SsLayout.item),
                      TextFormField(
                        controller: c.email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: l.email),
                      ),
                      const SizedBox(height: SsLayout.item),
                      TextFormField(
                        controller: c.address,
                        decoration: InputDecoration(labelText: l.address1),
                        maxLines: 2,
                      ),
                      const SizedBox(height: SsLayout.item),
                      TextFormField(
                        controller: c.notes,
                        decoration: InputDecoration(labelText: l.notes),
                        maxLines: 3,
                      ),
                      const SsFormActions(
                        child: SizedBox.shrink(),
                      ),
                      FilledButton(
                        onPressed: c.loading.value ? null : c.save,
                        child: Text(c.loading.value ? l.loading : l.save),
                      ),
                    ],
                  ),
                ),
        ));
  }
}

class CustomerDetailView extends StatelessWidget {
  const CustomerDetailView({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CustomerDetailController(id), tag: id);
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final customer = c.customer.value;
      return SsPage(
        title: l.customerDetails,
        actions: [
          if (customer != null) ...[
            IconButton(
              tooltip: l.shareWhatsApp,
              onPressed: c.openWhatsApp,
              icon: Icon(Icons.chat_outlined, color: SsLayout.title(scheme)),
            ),
            IconButton(
              onPressed: () async {
                await Get.toNamed('/customers/$id/edit');
                c.load();
              },
              icon: Icon(Icons.edit_outlined, color: SsLayout.title(scheme)),
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
                        '${customer?['fullName']}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: SsLayout.title(scheme),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: SsLayout.item),
                      Text(l.customerInfo, style: SsLayout.titleStyle(context)),
                      const SizedBox(height: SsLayout.tight),
                      SsListTile(
                        title: l.phone,
                        subtitle: '${customer?['phone'] ?? '—'}',
                      ),
                      if ('${customer?['email'] ?? ''}'.isNotEmpty)
                        SsListTile(
                          title: l.email,
                          subtitle: '${customer?['email']}',
                        ),
                      if ('${customer?['address'] ?? ''}'.isNotEmpty)
                        SsListTile(
                          title: l.address1,
                          subtitle: '${customer?['address']}',
                        ),
                      if ('${customer?['notes'] ?? ''}'.isNotEmpty)
                        SsListTile(
                          title: l.notes,
                          subtitle: '${customer?['notes']}',
                        ),
                      const SizedBox(height: SsLayout.section),
                      FilledButton.icon(
                        onPressed: () async {
                          await Get.toNamed(
                            '/orders/new',
                            arguments: {'customerId': id},
                          );
                          c.load();
                        },
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: Text(l.newOrder),
                      ),
                      const SizedBox(height: SsLayout.tight),
                      OutlinedButton.icon(
                        onPressed: c.openWhatsApp,
                        icon: const Icon(Icons.chat_outlined, size: 18),
                        label: Text(l.shareWhatsApp),
                      ),
                      const SizedBox(height: SsLayout.tight),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await Get.toNamed(
                                  '/measurements/new',
                                  arguments: {'customerId': id},
                                );
                                c.load();
                              },
                              icon: const Icon(Icons.straighten, size: 18),
                              label: Text(l.addMeasurement),
                            ),
                          ),
                          const SizedBox(width: SsLayout.tight),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  c.archive(customer?['archivedAt'] == null),
                              child: Text(
                                customer?['archivedAt'] == null
                                    ? l.archive
                                    : l.restore,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SsSectionTitle(l.orders),
                      if (c.orders.isEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: SsLayout.item),
                          child: Text(
                            l.noOrdersYet,
                            style: SsLayout.bodyStyle(context),
                          ),
                        )
                      else
                        ...c.orders.map((o) {
                          final m = o as Map;
                          final items = m['items'] as List? ?? [];
                          final names = items
                              .whereType<Map>()
                              .map((it) => '${it['garmentName']}')
                              .where((n) => n.isNotEmpty)
                              .join(', ');
                          final hasMeas = items.whereType<Map>().any((it) {
                            final snap = it['measurementSnapshot'];
                            return snap is Map && snap['values'] is Map;
                          });
                          final statusLabel =
                              l.orderStatusLabel('${m['status']}');
                          return SsListTile(
                            leading: SsPrimaryIconBox(
                              hasMeas
                                  ? Icons.checkroom
                                  : Icons.receipt_long_outlined,
                            ),
                            title: '${m['orderNumber']}',
                            subtitle: [
                              if (names.isNotEmpty) names,
                              '${l.status}: $statusLabel',
                            ].join('\n'),
                            trailing: Text(
                              '₹${m['balanceDue']}',
                              style: TextStyle(
                                color: SsLayout.title(scheme),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onTap: () async {
                              await Get.toNamed('/orders/${m['id']}');
                              c.load();
                            },
                          );
                        }),
                      SsSectionTitle(l.measurements),
                      if (c.measurements.isEmpty)
                        Text(
                          l.noMeasurementYet,
                          style: SsLayout.bodyStyle(context),
                        )
                      else
                        ...c.measurements.map((m) {
                          final row = m as Map;
                          final values = row['values'];
                          final unit = l.unitLabel('${row['unit'] ?? ''}');
                          final title = l.measurementVersionLabel(
                            '${row['garmentTemplate']?['name'] ?? l.measurements}',
                            '${row['version'] ?? ''}',
                          );
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: SsLayout.item),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: scheme.onSurface
                                      .withValues(alpha: 0.1),
                                ),
                                borderRadius: BorderRadius.circular(
                                  SsLayout.radiusSm,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: SsLayout.titleStyle(context),
                                    ),
                                    const SizedBox(height: 8),
                                    if (values is Map)
                                      SsMeasurementValues(
                                        values: values,
                                        unit: unit,
                                      )
                                    else
                                      Text(
                                        unit,
                                        style: SsLayout.captionStyle(context),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
      );
    });
  }
}
