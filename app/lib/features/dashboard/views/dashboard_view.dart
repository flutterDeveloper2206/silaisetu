import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/config/brand.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/utils/date_range.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_profile_avatar.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../../orders/views/orders_list_view.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DashboardController());
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return SsScaffoldWash(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Obx(() {
            final name =
                '${c.auth.user.value?['fullName'] ?? Brand.name}';
            if (c.loading.value) return const SsLoading();
            if (c.error.value != null) {
              return SsError(onRetry: c.load, message: c.error.value);
            }
            final summary = c.summary.value;
            final calendar = c.calendar.value;
            final recentOrders = c.recentOrders;
            final recentCustomers = c.recentCustomers;
            return RefreshIndicator(
              onRefresh: c.load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                      child: _HeroHeader(
                    greeting: name,
                    filterLabel: c.presetLabel(l),
                    onFilter: c.setPreset,
                    collections: '₹${summary?['revenueReceived'] ?? 0}',
                    orders: '${summary?['ordersCount'] ?? 0}',
                    outstanding: '₹${summary?['outstandingBalance'] ?? 0}',
                  )),
                  SliverPadding(
                    padding: SsLayout.pagePaddingBottom(),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SsSectionTitle(l.overview),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: SsLayout.item,
                          crossAxisSpacing: SsLayout.item,
                          childAspectRatio: 1.35,
                          padding: EdgeInsets.zero,
                          children: [
                            SsStatTile(
                              label: l.todayDeliveries,
                              value: '${calendar?['todayDeliveries'] ?? 0}',
                              icon: Icons.local_shipping_outlined,
                              onTap: () => Get.toNamed('/calendar'),
                            ),
                            SsStatTile(
                              label: l.overdue,
                              value: '${calendar?['overdue'] ?? 0}',
                              icon: Icons.warning_amber_rounded,
                              onTap: () => Get.to(() => const OrdersListView(
                                    mode: OrdersListMode.overdue,
                                    embedded: false,
                                  )),
                            ),
                            SsStatTile(
                              label: l.statusCutting,
                              value: '${c.statusCount('CUTTING')}',
                              icon: Icons.content_cut,
                              onTap: () => Get.to(() => const OrdersListView(
                                    mode: OrdersListMode.status,
                                    status: 'CUTTING',
                                    embedded: false,
                                  )),
                            ),
                            SsStatTile(
                              label: l.statusStitching,
                              value: '${c.statusCount('STITCHING')}',
                              icon: Icons.straighten,
                              onTap: () => Get.to(() => const OrdersListView(
                                    mode: OrdersListMode.status,
                                    status: 'STITCHING',
                                    embedded: false,
                                  )),
                            ),
                            SsStatTile(
                              label: l.statusReady,
                              value: '${c.statusCount('READY')}',
                              icon: Icons.check_circle_outline,
                              emphasized: true,
                              onTap: () => Get.to(() => const OrdersListView(
                                    mode: OrdersListMode.status,
                                    status: 'READY',
                                    embedded: false,
                                  )),
                            ),
                            SsStatTile(
                              label: l.outstanding,
                              value:
                                  '₹${summary?['outstandingBalance'] ?? 0}',
                              icon: Icons.account_balance_wallet_outlined,
                              onTap: () => Get.to(() => const OrdersListView(
                                    mode: OrdersListMode.pendingPayment,
                                    embedded: false,
                                  )),
                            ),
                          ],
                        ),
                        SsSectionTitle(
                          l.recentOrders,
                          trailing: TextButton(
                            onPressed: () => Get.to(() => const OrdersListView(
                                  mode: OrdersListMode.total,
                                  embedded: false,
                                )),
                            child: Text(l.continueLabel),
                          ),
                        ),
                        if (recentOrders.isEmpty)
                          SsGlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              l.empty,
                              style: SsLayout.bodyStyle(context),
                            ),
                          )
                        else
                          SsGlassCard(
                            child: Column(
                              children: [
                                for (var i = 0;
                                    i < recentOrders.length;
                                    i++) ...[
                                  _OrderRow(
                                      order: recentOrders[i] as Map),
                                  if (i < recentOrders.length - 1)
                                    Divider(
                                      height: 1,
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.06),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        SsSectionTitle(l.recentCustomers),
                        if (recentCustomers.isEmpty)
                          SsGlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              l.empty,
                              style: SsLayout.bodyStyle(context),
                            ),
                          )
                        else
                          SizedBox(
                            height: 108,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: recentCustomers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (_, i) {
                                final cust = recentCustomers[i] as Map;
                                return _CustomerChip(customer: cust);
                              },
                            ),
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.greeting,
    required this.filterLabel,
    required this.onFilter,
    required this.collections,
    required this.orders,
    required this.outstanding,
  });

  final String greeting;
  final String filterLabel;
  final ValueChanged<DatePreset> onFilter;
  final String collections;
  final String orders;
  final String outstanding;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        SsLayout.pageH,
        SsLayout.pageV,
        SsLayout.pageH,
        SsLayout.tight,
      ),
      decoration: BoxDecoration(
        gradient: context.gradients.hero,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentWarm.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SsProfileAvatar(
                      size: 52,
                      borderWidth: 2,
                      onInk: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Brand.name,
                            style: GoogleFonts.fraunces(
                              color: SsLayout.onInkBody,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            greeting,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.fraunces(
                              color: SsLayout.onInk,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<DatePreset>(
                      onSelected: onFilter,
                      color: scheme.surface,
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: DatePreset.today, child: Text(l.rangeToday)),
                        PopupMenuItem(
                            value: DatePreset.thisWeek,
                            child: Text(l.rangeThisWeek)),
                        PopupMenuItem(
                            value: DatePreset.thisMonth,
                            child: Text(l.rangeThisMonth)),
                        PopupMenuItem(
                            value: DatePreset.previousMonth,
                            child: Text(l.rangePreviousMonth)),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filterLabel,
                              style: TextStyle(
                                color: SsLayout.onInk,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.expand_more,
                              size: 18,
                              color: SsLayout.onInkBody,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _HeroMetric(
                        label: l.collections,
                        value: collections,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 42,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                    Expanded(
                      child: _HeroMetric(
                        label: l.ordersThisPeriod,
                        value: orders,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 42,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                    Expanded(
                      child: _HeroMetric(
                        label: l.outstanding,
                        value: outstanding,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: SsLayout.onInkMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: SsLayout.onInk,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final Map order;

  @override
  Widget build(BuildContext context) {
    final cust = order['customer'] as Map? ?? {};
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: SsLayout.tilePadding,
      onTap: () => Get.toNamed('/orders/${order['id']}'),
      leading: const SsPrimaryIconBox(Icons.receipt_long_outlined),
      title: Text(
        '${order['orderNumber']}',
        style: TextStyle(
          color: SsLayout.title(scheme),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${cust['fullName'] ?? ''} · ${order['status']}',
        style: SsLayout.bodyStyle(context),
      ),
      trailing: Text(
        '₹${order['balanceDue']}',
        style: TextStyle(
          color: SsLayout.title(scheme),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CustomerChip extends StatelessWidget {
  const _CustomerChip({required this.customer});
  final Map customer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = '${customer['fullName'] ?? ''}';
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Get.toNamed('/customers/${customer['id']}'),
      child: Ink(
        width: 148,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: context.gradients.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.onSurface.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
            ),
            const Spacer(),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: SsLayout.title(scheme),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${customer['phone'] ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SsLayout.captionStyle(context),
            ),
          ],
        ),
      ),
    );
  }
}
