import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_scaffold.dart';

class SelectShopView extends StatelessWidget {
  const SelectShopView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = Get.find<AuthController>();
    final shops = auth.memberships;
    final scheme = Theme.of(context).colorScheme;

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrandHeader(subtitle: l.selectShop),
          const SizedBox(height: SsLayout.section),
          ...shops.map((m) {
            final shop = m['shop'] as Map? ?? {};
            return Padding(
              padding: const EdgeInsets.only(bottom: SsLayout.tight),
              child: SsGlassCard(
                child: SsListTile(
                  leading: const SsPrimaryIconBox(Icons.storefront_outlined),
                  title: '${shop['name']}',
                  subtitle: '${m['role']} · ${shop['status']}',
                  trailing: Icon(
                    Icons.chevron_right,
                    color: SsLayout.muted(scheme),
                  ),
                  onTap: () async {
                    await auth.selectShop('${shop['id']}');
                    Get.offAllNamed(await auth.routeAfterAuthAsync());
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
