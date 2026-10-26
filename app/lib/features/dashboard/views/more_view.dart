import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_page.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../settings/views/settings_view.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = Get.find<AuthController>();
    final scheme = Theme.of(context).colorScheme;

    return SsPage(
      title: l.more,
      body: ListView(
        padding: SsLayout.pagePaddingBottom(),
        children: [
          Text(l.manageShopHint, style: SsLayout.bodyStyle(context)),
          const SizedBox(height: SsLayout.section),
          Text(l.quickActions, style: SsLayout.titleStyle(context)),
          const SizedBox(height: SsLayout.tight),
          _QuickGrid(items: [
            _QuickItem(Icons.straighten, l.measurements, '/measurements'),
            _QuickItem(
                Icons.person_add_outlined, l.addCustomer, '/customers/new'),
            _QuickItem(
                Icons.receipt_long_outlined, l.newOrder, '/orders/new'),
          ]),
          const SizedBox(height: SsLayout.section),
          _SectionCard(
            title: l.sectionWork,
            children: [
              _MenuTile(Icons.straighten, l.measurements, l.measurementsHint,
                  '/measurements'),
              _MenuTile(Icons.checkroom_outlined, l.garmentTemplates,
                  l.templatesHint, '/templates'),
              _MenuTile(Icons.badge_outlined, l.staff, l.staffHint, '/staff'),
            ],
          ),
          _SectionCard(
            title: l.sectionInsights,
            children: [
              _MenuTile(Icons.calendar_month_outlined, l.calendar,
                  l.calendarHint, '/calendar'),
              _MenuTile(
                  Icons.bar_chart_outlined, l.reports, l.reportsHint, '/reports'),
              _MenuTile(Icons.notifications_outlined, l.notifications,
                  l.notificationsHint, '/notifications'),
            ],
          ),
          _SectionCard(
            title: l.sectionAccount,
            children: [
              _MenuTile(Icons.storefront_outlined, l.shopSettings,
                  l.shopSettingsHint, '/shop-settings'),
              _MenuTile(Icons.person_outline, l.profile, l.profileHint,
                  '/profile'),
              SsListTile(
                leading: Icon(Icons.settings_outlined,
                    color: SsLayout.title(scheme)),
                title: l.settings,
                subtitle: l.settingsHint,
                trailing: Icon(Icons.chevron_right,
                    color: SsLayout.muted(scheme)),
                onTap: () => Get.to(() => const SettingsView()),
              ),
              SsListTile(
                leading: Icon(Icons.logout, color: SsLayout.title(scheme)),
                title: l.logout,
                onTap: () async {
                  final ok = await Get.dialog<bool>(
                    AlertDialog(
                      title: Text(l.logout),
                      content: Text(l.logoutConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: Text(l.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Get.back(result: true),
                          child: Text(l.logout),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) await auth.logout();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickItem {
  const _QuickItem(this.icon, this.label, this.route);
  final IconData icon;
  final String label;
  final String route;
}

class _QuickGrid extends StatelessWidget {
  const _QuickGrid({required this.items});
  final List<_QuickItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: SsLayout.item,
      crossAxisSpacing: SsLayout.item,
      childAspectRatio: 1.7,
      children: items
          .map(
            (item) => Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(SsLayout.radius),
                onTap: () => Get.toNamed(item.route),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: context.gradients.accentCard,
                    borderRadius: BorderRadius.circular(SsLayout.radius),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, color: SsLayout.onInk, size: 22),
                        const SizedBox(height: SsLayout.tight),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: SsLayout.onInk,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: SsLayout.item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: SsLayout.tight, left: 4),
            child: Text(title, style: SsLayout.titleStyle(context)),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: context.gradients.card,
              borderRadius: BorderRadius.circular(SsLayout.radius),
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile(this.icon, this.title, this.subtitle, this.route);
  final IconData icon;
  final String title;
  final String? subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SsListTile(
      leading: Icon(icon, color: SsLayout.title(scheme)),
      title: title,
      subtitle: subtitle,
      trailing: Icon(Icons.chevron_right, color: SsLayout.muted(scheme)),
      onTap: () => Get.toNamed(route),
    );
  }
}
