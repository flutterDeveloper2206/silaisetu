import 'package:flutter/material.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, this.embedded = false});

  /// When true, omit redundant app-bar actions (used inside [HomeShell]).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(HomeController());
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.dashboard),
        actions: embedded
            ? null
            : [
                IconButton(
                  onPressed: () => Get.toNamed('/customers'),
                  icon: const Icon(Icons.people_outline),
                ),
                IconButton(
                  onPressed: () => Get.toNamed('/orders'),
                  icon: const Icon(Icons.receipt_long_outlined),
                ),
                IconButton(
                  onPressed: () => Get.toNamed('/settings'),
                  icon: const Icon(Icons.settings_outlined),
                ),
                IconButton(
                  onPressed: () => Get.find<AuthController>().logout(),
                  icon: const Icon(Icons.logout),
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: c.load,
        child: Obx(() {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (c.loading.value) Center(child: Text(l.loading)),
              if (c.error.value != null)
                Column(
                  children: [
                    Text(c.errorText(l)),
                    TextButton(onPressed: c.load, child: Text(l.retry)),
                    if (c.error.value == 'shop' || c.error.value == 'no-shop')
                      TextButton(
                        onPressed: () => Get.toNamed('/select-shop'),
                        child: Text(l.selectShop),
                      ),
                    if (c.error.value == 'auth')
                      TextButton(
                        onPressed: () => c.auth.logout(),
                        child: Text(l.signIn),
                      ),
                  ],
                ),
              if (!c.loading.value && c.error.value == null) ...[
                _StatCard(
                    label: l.todayDeliveries,
                    value: '${c.summary.value?['todayDeliveries'] ?? 0}'),
                const SizedBox(height: 12),
                _StatCard(
                    label: l.overdue,
                    value: '${c.summary.value?['overdue'] ?? 0}'),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.displaySmall),
          ],
        ),
      ),
    );
  }
}
