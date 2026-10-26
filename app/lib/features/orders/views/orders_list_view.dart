import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/orders_list_controller.dart';

export '../controllers/orders_list_controller.dart' show OrdersListMode;

class OrdersListView extends StatelessWidget {
  const OrdersListView({
    super.key,
    required this.mode,
    this.status,
    this.embedded = true,
  });

  final OrdersListMode mode;
  final String? status;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final tag = OrdersListController.tagFor(mode, status);
    final c = Get.put(
      OrdersListController(mode: mode, status: status),
      tag: tag,
    );

    return SsPage(
      title: c.title(l),
      actions: [
        IconButton(
          onPressed: () async {
            await Get.toNamed('/orders/new');
            c.load();
          },
          icon: Icon(Icons.add, color: SsLayout.title(scheme)),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'orders_add_fab_$mode',
        onPressed: () async {
          await Get.toNamed('/orders/new');
          c.load();
        },
        icon: const Icon(Icons.add),
        label: Text(l.newOrder),
      ),
      body: Obx(() {
        if (c.loading.value) return const SsLoading();
        if (c.error.value != null) {
          return SsError(onRetry: c.load, message: c.error.value);
        }
        return Column(
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
                hint: l.searchOrders,
                onSubmitted: (_) => c.load(),
                onRefresh: c.load,
              ),
            ),
            Expanded(
              child: c.items.isEmpty
                  ? SsEmpty(message: l.empty)
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
                          final o = c.items[i] as Map;
                          final cust = o['customer'] as Map? ?? {};
                          final orderItems = o['items'] as List? ?? [];
                          final names = orderItems
                              .whereType<Map>()
                              .map((it) => '${it['garmentName']}')
                              .where((n) => n.isNotEmpty)
                              .join(', ');
                          return SsListTile(
                            leading: const SsPrimaryIconBox(
                              Icons.receipt_long_outlined,
                            ),
                            title: '${o['orderNumber']}',
                            subtitle: [
                              '${cust['fullName'] ?? ''} · ${o['status']}',
                              if (names.isNotEmpty) names,
                            ].join('\n'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${o['totalAmount']}',
                                  style: TextStyle(
                                    color: SsLayout.title(scheme),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Due ₹${o['balanceDue']}',
                                  style: SsLayout.captionStyle(context),
                                ),
                              ],
                            ),
                            onTap: () async {
                              await Get.toNamed('/orders/${o['id']}');
                              c.load();
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
