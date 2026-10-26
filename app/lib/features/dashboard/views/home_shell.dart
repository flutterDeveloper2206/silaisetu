import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../customers/views/customers_view.dart';
import '../../orders/views/orders_list_view.dart';
import '../../settings/views/settings_view.dart';
import '../controllers/home_shell_controller.dart';
import 'dashboard_view.dart';
import 'more_view.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(HomeShellController());
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final pages = [
      const DashboardView(),
      const OrdersListView(mode: OrdersListMode.total),
      const OrdersListView(mode: OrdersListMode.pending),
      const CustomersView(),
      const MoreView(),
    ];

    return Obx(() {
      final index = c.tabIndex.value;
      return Scaffold(
        body: pages[index],
        extendBody: true,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.96),
            border: Border(
              top: BorderSide(color: scheme.onSurface.withValues(alpha: 0.1)),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: c.selectTab,
            indicatorColor: scheme.onSurface.withValues(alpha: 0.1),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: l.dashboard,
              ),
              NavigationDestination(
                icon: const Icon(Icons.list_alt_outlined),
                selectedIcon: const Icon(Icons.list_alt),
                label: l.navTotal,
              ),
              NavigationDestination(
                icon: const Icon(Icons.pending_actions_outlined),
                selectedIcon: const Icon(Icons.pending_actions),
                label: l.navPending,
              ),
              NavigationDestination(
                icon: const Icon(Icons.people_outline),
                selectedIcon: const Icon(Icons.people),
                label: l.customers,
              ),
              NavigationDestination(
                icon: const Icon(Icons.more_horiz),
                selectedIcon: const Icon(Icons.more_horiz),
                label: l.more,
              ),
            ],
          ),
        ),
        // Hide on Customers (has its own FAB) and More — avoids duplicate hero tags.
        floatingActionButton: (index == 3 || index == 4)
            ? null
            : FloatingActionButton.extended(
                heroTag: 'home_shell_quick_fab',
                onPressed: () => _quickActions(context, l),
                icon: const Icon(Icons.add),
                label: Text(l.quickActions),
              ),
      );
    });
  }

  Future<void> _quickActions(BuildContext context, AppLocalizations l) async {
    final scheme = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: _qaIcon(Icons.person_add_outlined, scheme),
                title: Text(l.addCustomer),
                onTap: () {
                  Navigator.pop(ctx);
                  Get.toNamed('/customers/new');
                },
              ),
              ListTile(
                leading: _qaIcon(Icons.receipt_long_outlined, scheme),
                title: Text(l.newOrder),
                onTap: () {
                  Navigator.pop(ctx);
                  Get.toNamed('/orders/new');
                },
              ),
              ListTile(
                leading: _qaIcon(Icons.straighten, scheme),
                title: Text(l.addMeasurement),
                onTap: () {
                  Navigator.pop(ctx);
                  Get.toNamed('/measurements/new');
                },
              ),
              ListTile(
                leading: _qaIcon(Icons.payments_outlined, scheme),
                title: Text(l.receivePayment),
                onTap: () {
                  Navigator.pop(ctx);
                  Get.toNamed('/payments/receive');
                },
              ),
              ListTile(
                leading: _qaIcon(Icons.settings_outlined, scheme),
                title: Text(l.settings),
                onTap: () {
                  Navigator.pop(ctx);
                  Get.to(() => const SettingsView());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qaIcon(IconData icon, ColorScheme scheme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20),
    );
  }
}
