import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/shop_settings_controller.dart';

class ShopSettingsView extends StatelessWidget {
  const ShopSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ShopSettingsController());
    final l = AppLocalizations.of(context)!;
    return SsPage(
      title: l.shopSettings,
      body: Obx(() {
        if (c.loading.value) return const SsLoading();
        return ListView(
          padding: SsLayout.formPadding,
          children: [
            if (c.error.value != null)
              Padding(
                padding: const EdgeInsets.only(bottom: SsLayout.item),
                child: Text(
                  l.errorGeneric,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            TextField(
              controller: c.name,
              decoration: InputDecoration(labelText: l.shopName),
            ),
            const SizedBox(height: SsLayout.item),
            TextField(
              controller: c.phone,
              decoration: InputDecoration(labelText: l.shopPhone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: SsLayout.item),
            TextField(
              controller: c.email,
              decoration: InputDecoration(labelText: l.shopEmail),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: SsLayout.item),
            TextField(
              controller: c.address,
              decoration: InputDecoration(labelText: l.address1),
            ),
            const SizedBox(height: SsLayout.item),
            TextField(
              controller: c.city,
              decoration: InputDecoration(labelText: l.city),
            ),
            SsFormActions(
              child: FilledButton(
                onPressed: c.loading.value ? null : c.save,
                child: Text(l.save),
              ),
            ),
          ],
        );
      }),
    );
  }
}
