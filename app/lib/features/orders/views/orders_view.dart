import 'package:flutter/material.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import 'package:get/get.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final c = Get.put(OrdersController());

    return SsPage(
      title: l.orders,
      body: Obx(() {
        if (c.loading.value) return const SsLoading();
        if (c.error.value != null) {
          return SsError(onRetry: c.load, message: l.errorGeneric);
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
            final o = c.items[i] as Map;
            final customer = o['customer'] as Map? ?? {};
            return SsListTile(
              leading: const SsPrimaryIconBox(
                Icons.receipt_long_outlined,
              ),
              title: '${o['orderNumber']} · ${customer['fullName'] ?? ''}',
              subtitle: '${o['status']} · ₹${o['balanceDue']}',
            );
          },
        );
      }),
    );
  }
}
