import 'package:flutter/material.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_page.dart';
import '../../auth/controllers/auth_controller.dart';

class SettingsController extends GetxController {
  final locale = const Locale('gu').obs;
  final themeMode = ThemeMode.system.obs;
  final introSeen = false.obs;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    locale.value = Locale(p.getString('ss_lang') ?? 'gu');
    introSeen.value = p.getBool('ss_intro_seen') ?? false;
    final t = p.getString('ss_theme') ?? 'system';
    themeMode.value = switch (t) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setIntroSeen() async {
    introSeen.value = true;
    final p = await SharedPreferences.getInstance();
    await p.setBool('ss_intro_seen', true);
  }

  Future<void> setLocale(Locale value) async {
    locale.value = value;
    Get.updateLocale(value);
    final p = await SharedPreferences.getInstance();
    await p.setString('ss_lang', value.languageCode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'ss_theme',
      mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system',
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = Get.find<SettingsController>();
    final scheme = Theme.of(context).colorScheme;
    return SsPage(
      title: l.settings,
      body: Obx(() {
        return ListView(
          padding: SsLayout.pagePaddingBottom(),
          children: [
            SsListTile(
              title: l.language,
              subtitle: settings.locale.value.languageCode,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SsLayout.pageH),
              child: Wrap(
                spacing: SsLayout.tight,
                children: [
                  ChoiceChip(
                    label: const Text('ગુજરાતી'),
                    selected: settings.locale.value.languageCode == 'gu',
                    onSelected: (_) => settings.setLocale(const Locale('gu')),
                  ),
                  ChoiceChip(
                    label: const Text('हिन्दी'),
                    selected: settings.locale.value.languageCode == 'hi',
                    onSelected: (_) => settings.setLocale(const Locale('hi')),
                  ),
                  ChoiceChip(
                    label: const Text('English'),
                    selected: settings.locale.value.languageCode == 'en',
                    onSelected: (_) => settings.setLocale(const Locale('en')),
                  ),
                ],
              ),
            ),
            Divider(color: scheme.onSurface.withValues(alpha: 0.08)),
            SsListTile(title: l.theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SsLayout.pageH),
              child: Wrap(
                spacing: SsLayout.tight,
                children: [
                  ChoiceChip(
                    label: Text(l.system),
                    selected: settings.themeMode.value == ThemeMode.system,
                    onSelected: (_) => settings.setTheme(ThemeMode.system),
                  ),
                  ChoiceChip(
                    label: Text(l.light),
                    selected: settings.themeMode.value == ThemeMode.light,
                    onSelected: (_) => settings.setTheme(ThemeMode.light),
                  ),
                  ChoiceChip(
                    label: Text(l.dark),
                    selected: settings.themeMode.value == ThemeMode.dark,
                    onSelected: (_) => settings.setTheme(ThemeMode.dark),
                  ),
                ],
              ),
            ),
            Divider(color: scheme.onSurface.withValues(alpha: 0.08)),
            SsListTile(
              leading: Icon(Icons.person_outline, color: SsLayout.title(scheme)),
              title: l.profile,
              trailing: Icon(Icons.chevron_right, color: SsLayout.muted(scheme)),
              onTap: () => Get.toNamed('/profile'),
            ),
            SsListTile(
              leading:
                  Icon(Icons.storefront_outlined, color: SsLayout.title(scheme)),
              title: l.shopSettings,
              trailing: Icon(Icons.chevron_right, color: SsLayout.muted(scheme)),
              onTap: () => Get.toNamed('/shop-settings'),
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
                if (ok == true) {
                  await Get.find<AuthController>().logout();
                }
              },
            ),
          ],
        );
      }),
    );
  }
}
