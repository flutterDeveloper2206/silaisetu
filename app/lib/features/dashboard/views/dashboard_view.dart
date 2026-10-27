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
            if (c.loading.value) return const SsLoading();
            if (c.error.value != null) {
              return SsError(onRetry: c.load, message: c.error.value);
            }
            final summary = c.summary.value;
            final calendar = c.calendar.value;
            final recentOrders = c.recentOrders;
            final recentCustomers = c.recentCustomers;
            final firstName = _firstName(
              '${c.auth.user.value?['fullName'] ?? Brand.name}',
            );
            final shopName = _shopName(c);

            return RefreshIndicator(
              onRefresh: c.load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _WelcomeHeader(
                      greeting: _dayGreeting(l),
                      name: firstName,
                      shopName: shopName,
                      filterLabel: c.presetLabel(l),
                      onFilter: c.setPreset,
                    ),
                  ),
                  SliverPadding(
                    padding: SsLayout.pagePaddingBottom(),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SsSectionTitle(l.quickActions),
                        _QuickActionsRow(l: l),
                        SsSectionTitle(l.todaysFocus),
                        Row(
                          children: [
                            Expanded(
                              child: _FocusCard(
                                label: l.todayDeliveries,
                                value: '${calendar?['todayDeliveries'] ?? 0}',
                                icon: Icons.local_shipping_outlined,
                                tone: _FocusTone.info,
                                onTap: () => Get.toNamed('/calendar'),
                              ),
                            ),
                            const SizedBox(width: SsLayout.item),
                            Expanded(
                              child: _FocusCard(
                                label: l.overdue,
                                value: '${calendar?['overdue'] ?? 0}',
                                icon: Icons.warning_amber_rounded,
                                tone: _FocusTone.alert,
                                onTap: () => Get.to(() => const OrdersListView(
                                      mode: OrdersListMode.overdue,
                                      embedded: false,
                                    )),
                              ),
                            ),
                            const SizedBox(width: SsLayout.item),
                            Expanded(
                              child: _FocusCard(
                                label: l.statusReady,
                                value: '${c.statusCount('READY')}',
                                icon: Icons.check_circle_outline,
                                tone: _FocusTone.success,
                                onTap: () => Get.to(() => const OrdersListView(
                                      mode: OrdersListMode.status,
                                      status: 'READY',
                                      embedded: false,
                                    )),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: SsLayout.section),
                        _MoneyStrip(
                          collections: '₹${summary?['revenueReceived'] ?? 0}',
                          outstanding:
                              '₹${summary?['outstandingBalance'] ?? 0}',
                          orders: '${summary?['ordersCount'] ?? 0}',
                          collectionsLabel: l.collections,
                          outstandingLabel: l.outstanding,
                          ordersLabel: l.ordersThisPeriod,
                          onOutstanding: () => Get.to(() => const OrdersListView(
                                mode: OrdersListMode.pendingPayment,
                                embedded: false,
                              )),
                          onOrders: () => Get.to(() => const OrdersListView(
                                mode: OrdersListMode.total,
                                embedded: false,
                              )),
                        ),
                        SsSectionTitle(l.workInProgress),
                        _PipelineRow(
                          items: [
                            _PipelineItem(
                              label: l.statusCutting,
                              count: c.statusCount('CUTTING'),
                              icon: Icons.content_cut,
                              onTap: () => Get.to(() => const OrdersListView(
                                    mode: OrdersListMode.status,
                                    status: 'CUTTING',
                                    embedded: false,
                                  )),
                            ),
                            _PipelineItem(
                              label: l.statusStitching,
                              count: c.statusCount('STITCHING'),
                              icon: Icons.straighten,
                              onTap: () => Get.to(() => const OrdersListView(
                                    mode: OrdersListMode.status,
                                    status: 'STITCHING',
                                    embedded: false,
                                  )),
                            ),
                            _PipelineItem(
                              label: l.statusTrial,
                              count: c.statusCount('TRIAL'),
                              icon: Icons.accessibility_new_outlined,
                              onTap: () => Get.to(() => const OrdersListView(
                                    mode: OrdersListMode.status,
                                    status: 'TRIAL',
                                    embedded: false,
                                  )),
                            ),
                            _PipelineItem(
                              label: l.statusReady,
                              count: c.statusCount('READY'),
                              icon: Icons.checkroom_outlined,
                              onTap: () => Get.to(() => const OrdersListView(
                                    mode: OrdersListMode.status,
                                    status: 'READY',
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
                            child: Text(l.seeAll),
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
                                  _OrderRow(order: recentOrders[i] as Map),
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
                        SsSectionTitle(
                          l.recentCustomers,
                          trailing: TextButton(
                            onPressed: () => Get.toNamed('/customers'),
                            child: Text(l.seeAll),
                          ),
                        ),
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
                            height: 104,
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

  static String _dayGreeting(AppLocalizations l) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l.greetingMorning;
    if (hour < 17) return l.greetingAfternoon;
    return l.greetingEvening;
  }

  static String _firstName(String full) {
    final parts = full.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? Brand.name : parts.first;
  }

  static String _shopName(DashboardController c) {
    final memberships = c.auth.memberships;
    final shopId = c.api.shopId;
    for (final m in memberships) {
      if (m is! Map) continue;
      final shop = m['shop'];
      if (shop is! Map) continue;
      if (shopId == null || '${shop['id']}' == shopId) {
        return '${shop['name'] ?? Brand.name}';
      }
    }
    return Brand.name;
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.greeting,
    required this.name,
    required this.shopName,
    required this.filterLabel,
    required this.onFilter,
  });

  final String greeting;
  final String name;
  final String shopName;
  final String filterLabel;
  final ValueChanged<DatePreset> onFilter;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SsLayout.pageH,
        SsLayout.pageV,
        SsLayout.pageH,
        SsLayout.tight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SsProfileAvatar(size: 52, borderWidth: 2),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: SsLayout.captionStyle(context).copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fraunces(
                    color: SsLayout.title(scheme),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shopName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SsLayout.bodyStyle(context),
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
                  value: DatePreset.thisWeek, child: Text(l.rangeThisWeek)),
              PopupMenuItem(
                  value: DatePreset.thisMonth, child: Text(l.rangeThisMonth)),
              PopupMenuItem(
                  value: DatePreset.previousMonth,
                  child: Text(l.rangePreviousMonth)),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: SsLayout.body(scheme)),
                  const SizedBox(width: 6),
                  Text(
                    filterLabel,
                    style: TextStyle(
                      color: SsLayout.title(scheme),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.expand_more,
                      size: 18, color: SsLayout.body(scheme)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.receipt_long_outlined,
            label: l.newOrder,
            onTap: () => Get.toNamed('/orders/new'),
            primary: true,
          ),
        ),
        const SizedBox(width: SsLayout.item),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.person_add_outlined,
            label: l.addCustomer,
            onTap: () => Get.toNamed('/customers/new'),
          ),
        ),
        const SizedBox(width: SsLayout.item),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.payments_outlined,
            label: l.receivePayment,
            onTap: () => Get.toNamed('/payments/receive'),
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = primary ? scheme.primary : scheme.surface;
    final fg = primary ? scheme.onPrimary : SsLayout.title(scheme);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 92,
          decoration: BoxDecoration(
            color: bg,
            gradient: primary ? context.gradients.accentCard : null,
            borderRadius: BorderRadius.circular(18),
            border: primary
                ? null
                : Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: primary ? 0.18 : 0.05),
                blurRadius: primary ? 16 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 22, color: fg),
                const Spacer(),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _FocusTone { info, alert, success }

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final _FocusTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = switch (tone) {
      _FocusTone.info => AppColors.accentCool,
      _FocusTone.alert => const Color(0xFFB45309),
      _FocusTone.success => const Color(0xFF3F6B4A),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: TextStyle(
                  color: SsLayout.title(scheme),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: SsLayout.body(scheme),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoneyStrip extends StatelessWidget {
  const _MoneyStrip({
    required this.collections,
    required this.outstanding,
    required this.orders,
    required this.collectionsLabel,
    required this.outstandingLabel,
    required this.ordersLabel,
    required this.onOutstanding,
    required this.onOrders,
  });

  final String collections;
  final String outstanding;
  final String orders;
  final String collectionsLabel;
  final String outstandingLabel;
  final String ordersLabel;
  final VoidCallback onOutstanding;
  final VoidCallback onOrders;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SsGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: _MoneyCell(
              label: collectionsLabel,
              value: collections,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
          Expanded(
            child: InkWell(
              onTap: onOrders,
              borderRadius: BorderRadius.circular(12),
              child: _MoneyCell(label: ordersLabel, value: orders),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
          Expanded(
            child: InkWell(
              onTap: onOutstanding,
              borderRadius: BorderRadius.circular(12),
              child: _MoneyCell(label: outstandingLabel, value: outstanding),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyCell extends StatelessWidget {
  const _MoneyCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SsLayout.muted(scheme),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SsLayout.title(scheme),
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineItem {
  const _PipelineItem({
    required this.label,
    required this.count,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final int count;
  final IconData icon;
  final VoidCallback onTap;
}

class _PipelineRow extends StatelessWidget {
  const _PipelineRow({required this.items});
  final List<_PipelineItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = items[i];
          final scheme = Theme.of(context).colorScheme;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                width: 118,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: context.gradients.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(item.icon, size: 16, color: SsLayout.body(scheme)),
                        const Spacer(),
                        Text(
                          '${item.count}',
                          style: TextStyle(
                            color: SsLayout.title(scheme),
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SsLayout.body(scheme),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
    final status = '${order['status'] ?? ''}';
    return ListTile(
      contentPadding: SsLayout.tilePadding,
      onTap: () => Get.toNamed('/orders/${order['id']}'),
      leading: const SsPrimaryIconBox(Icons.receipt_long_outlined),
      title: Text(
        '${order['orderNumber']}',
        style: TextStyle(
          color: SsLayout.title(scheme),
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        '${cust['fullName'] ?? ''}',
        style: SsLayout.bodyStyle(context),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '₹${order['balanceDue']}',
            style: TextStyle(
              color: SsLayout.title(scheme),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          _StatusChip(status: status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'READY' => const Color(0xFF3F6B4A),
      'OVERDUE' || 'CANCELLED' => const Color(0xFFB45309),
      'STITCHING' || 'CUTTING' => AppColors.accentCool,
      _ => AppColors.charcoal,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.isEmpty ? '—' : status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
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
