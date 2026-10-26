import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final c = Get.put(NotificationsController());
    return SsPage(
      title: l.notifications,
      actions: [
        TextButton(
          onPressed: c.markAllRead,
          child: Text(l.markAllRead),
        ),
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
            final n = c.items[i] as Map;
            final type = '${n['type'] ?? ''}';
            return SsListTile(
              leading: SsPrimaryIconBox(c.iconFor(type)),
              title: '${n['title'] ?? type}',
              subtitle: '${n['body'] ?? n['message'] ?? ''}',
              trailing: c.isUnread(n)
                  ? Icon(
                      Icons.circle,
                      size: 10,
                      color: scheme.primary,
                    )
                  : null,
              onTap: () => c.onTap(n),
            );
          },
        );
      }),
    );
  }
}
