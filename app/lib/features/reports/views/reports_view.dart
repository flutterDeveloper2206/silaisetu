import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/localization/ss_labels.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/utils/date_range.dart';
import '../../../core/widgets/ss_charts.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ReportsController());
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final byStatus = c.summary.value?['ordersByStatus'] as List? ?? [];
      final slices = byStatus.map((row) {
        final m = row as Map;
        final status = '${m['status']}';
        return (
          status: status,
          label: l.orderStatusLabel(status),
          count: c.countOf(m['_count']),
        );
      }).toList();

      return SsPage(
        title: l.reports,
        actions: [
          PopupMenuButton<DatePreset>(
            tooltip: c.presetLabel(l),
            onSelected: c.setPreset,
            itemBuilder: (_) => [
              PopupMenuItem(value: DatePreset.today, child: Text(l.rangeToday)),
              PopupMenuItem(
                  value: DatePreset.thisWeek, child: Text(l.rangeThisWeek)),
              PopupMenuItem(
                  value: DatePreset.thisMonth, child: Text(l.rangeThisMonth)),
              PopupMenuItem(
                  value: DatePreset.previousMonth,
                  child: Text(l.rangePreviousMonth)),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text(
                    c.presetLabel(l),
                    style: TextStyle(color: SsLayout.title(scheme)),
                  ),
                  Icon(Icons.expand_more, color: SsLayout.title(scheme)),
                ],
              ),
            ),
          ),
        ],
        body: c.loading.value
            ? const SsLoading()
            : c.error.value != null
                ? SsError(onRetry: c.load, message: c.error.value)
                : RefreshIndicator(
                    onRefresh: c.load,
                    child: ListView(
                      padding: SsLayout.pagePaddingBottom(),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SsStatTile(
                                label: l.ordersThisPeriod,
                                value: '${c.summary.value?['ordersCount'] ?? 0}',
                                icon: Icons.receipt_long_outlined,
                              ),
                            ),
                            const SizedBox(width: SsLayout.tight),
                            Expanded(
                              child: SsStatTile(
                                label: l.orderValue,
                                value:
                                    '₹${c.summary.value?['orderValue'] ?? 0}',
                                icon: Icons.shopping_bag_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: SsLayout.tight),
                        Row(
                          children: [
                            Expanded(
                              child: SsStatTile(
                                label: l.collections,
                                value:
                                    '₹${c.summary.value?['revenueReceived'] ?? 0}',
                                icon: Icons.payments_outlined,
                                emphasized: true,
                              ),
                            ),
                            const SizedBox(width: SsLayout.tight),
                            Expanded(
                              child: SsStatTile(
                                label: l.outstanding,
                                value:
                                    '₹${c.summary.value?['outstandingBalance'] ?? 0}',
                                icon: Icons.account_balance_wallet_outlined,
                              ),
                            ),
                          ],
                        ),
                        SsSectionTitle(l.revenueOverview),
                        SsMoneyBarChart(
                          orderValue: c.numOf(c.summary.value?['orderValue']),
                          collections:
                              c.numOf(c.summary.value?['revenueReceived']),
                          outstanding:
                              c.numOf(c.summary.value?['outstandingBalance']),
                          orderValueLabel: l.orderValue,
                          collectionsLabel: l.collections,
                          outstandingLabel: l.outstanding,
                        ),
                        SsSectionTitle(l.statusChart),
                        SsStatusPieChart(
                          slices: slices,
                          emptyLabel: l.empty,
                        ),
                        SsSectionTitle(l.ordersByStatus),
                        if (byStatus.isEmpty)
                          Text(l.empty, style: SsLayout.bodyStyle(context))
                        else
                          ...byStatus.map((row) {
                            final m = row as Map;
                            final status = '${m['status']}';
                            return Column(
                              children: [
                                SsListTile(
                                  leading: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: ssStatusColor(status, scheme),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  title: l.orderStatusLabel(status),
                                  trailing: Text(
                                    '${c.countOf(m['_count'])}',
                                    style: TextStyle(
                                      color: SsLayout.title(scheme),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  color: scheme.onSurface
                                      .withValues(alpha: 0.08),
                                ),
                              ],
                            );
                          }),
                      ],
                    ),
                  ),
      );
    });
  }
}
