import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/staff_controller.dart';

class StaffView extends StatelessWidget {
  const StaffView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final c = Get.put(StaffController());
    return SsPage(
      title: l.staff,
      actions: [
        IconButton(onPressed: c.invite, icon: const Icon(Icons.person_add_outlined)),
      ],
      body: Obx(() {
        if (c.loading.value) return const SsLoading();
        if (c.error.value != null) {
          return SsError(onRetry: c.load, message: c.error.value);
        }
        if (c.items.isEmpty) return SsEmpty(message: l.empty);
        return ListView.separated(
          padding: SsLayout.listPadding,
          itemCount: c.items.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
          itemBuilder: (_, i) {
            final m = c.items[i] as Map;
            final user = m['user'] as Map? ?? m;
            return SsListTile(
              leading: const SsPrimaryIconBox(Icons.badge_outlined),
              title: '${user['fullName'] ?? m['fullName'] ?? ''}',
              subtitle:
                  '${m['role']} · ${user['email'] ?? user['phone'] ?? ''}',
              trailing: m['isActive'] == false
                  ? Text(
                      l.archived,
                      style: TextStyle(color: SsLayout.muted(scheme)),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.block,
                        color: SsLayout.body(scheme),
                      ),
                      onPressed: () => c.deactivate('${m['id']}'),
                    ),
            );
          },
        );
      }),
    );
  }
}
