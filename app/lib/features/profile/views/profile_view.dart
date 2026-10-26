import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_profile_avatar.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfileController());
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return SsPage(
      title: l.profile,
      body: ListView(
        padding: SsLayout.formPadding,
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: c.changePhoto,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const SsProfileAvatar(size: 104),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: scheme.onSurface,
                          shape: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.photo_camera_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SsLayout.tight),
                TextButton(
                  onPressed: c.changePhoto,
                  child: Text(l.changePhoto),
                ),
                Text(
                  l.uploadLogoHint,
                  textAlign: TextAlign.center,
                  style: SsLayout.captionStyle(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: SsLayout.section),
          TextField(
            controller: c.name,
            decoration: InputDecoration(labelText: l.fullName),
          ),
          const SizedBox(height: SsLayout.item),
          TextField(
            controller: c.phone,
            decoration: InputDecoration(labelText: l.phone),
          ),
          const SizedBox(height: SsLayout.item),
          Obx(
            () => SsListTile(
              title: l.email,
              subtitle: '${c.auth.user.value?['email'] ?? '—'}',
            ),
          ),
          SsFormActions(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => FilledButton(
                    onPressed: c.saving.value ? null : c.save,
                    child: Text(l.save),
                  ),
                ),
                const SizedBox(height: SsLayout.item),
                OutlinedButton(
                  onPressed: () => Get.toNamed('/change-password'),
                  child: Text(l.changePassword),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ChangePasswordController());
    final l = AppLocalizations.of(context)!;
    return SsPage(
      title: l.changePassword,
      padding: SsLayout.formPadding,
      body: Column(
        children: [
          TextField(
            controller: c.current,
            obscureText: true,
            decoration: InputDecoration(labelText: l.password),
          ),
          const SizedBox(height: SsLayout.item),
          TextField(
            controller: c.next,
            obscureText: true,
            decoration: InputDecoration(labelText: l.newPassword),
          ),
          const SizedBox(height: SsLayout.item),
          TextField(
            controller: c.confirm,
            obscureText: true,
            decoration: InputDecoration(labelText: l.confirmPassword),
          ),
          SsFormActions(
            child: SizedBox(
              width: double.infinity,
              child: Obx(
                () => FilledButton(
                  onPressed: c.saving.value ? null : c.save,
                  child: Text(l.save),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
