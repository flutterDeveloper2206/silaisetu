import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_debug_fill_button.dart';
import '../../settings/views/settings_view.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sign_up_ui_controller.dart';
import '../widgets/auth_scaffold.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final lang = Get.find<SettingsController>().locale.value.languageCode;
    final auth = Get.find<AuthController>();
    final ui = Get.put(SignUpUiController());

    return AuthScaffold(
      showBack: true,
      child: Form(
        key: ui.formKey,
        child: Obx(() {
          final strength = ui.passwordStrength;
          final photoPath = ui.photo.path.value;
          final hasPhoto =
              photoPath != null && File(photoPath).existsSync();
          final usePhone = ui.usePhone.value;
          final obscure = ui.obscurePassword.value;
          final obscure2 = ui.obscureConfirm.value;
          final picking = ui.pickingPhoto.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.createAccount,
                style: GoogleFonts.fraunces(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: SsLayout.title(scheme),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l.signUpSubtitle,
                style: SsLayout.bodyStyle(context),
              ),
              const SizedBox(height: SsLayout.section),
              SsDebugFillButton(onPressed: ui.debugFill),
              Center(
                child: GestureDetector(
                  onTap: picking ? null : () => ui.pickPhoto(context),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.onSurface.withValues(alpha: 0.06),
                              border: Border.all(
                                color: scheme.onSurface.withValues(alpha: 0.12),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.onSurface.withValues(alpha: 0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: hasPhoto
                                ? Image.file(
                                    File(photoPath),
                                    key: ValueKey(photoPath),
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.storefront_outlined,
                                    size: 42,
                                    color: SsLayout.muted(scheme),
                                  ),
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Material(
                              color: scheme.onSurface,
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: picking ? null : () => ui.pickPhoto(context),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: picking
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: scheme.surface,
                                          ),
                                        )
                                      : Icon(
                                          Icons.photo_camera_outlined,
                                          size: 18,
                                          color: scheme.surface,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SsLayout.tight),
                      Text(
                        l.uploadLogoOrPhoto,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: SsLayout.title(scheme),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.uploadLogoHint,
                        textAlign: TextAlign.center,
                        style: SsLayout.captionStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SsLayout.section),
              TextFormField(
                controller: ui.name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l.fullName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? l.requiredField : null,
              ),
              const SizedBox(height: SsLayout.item),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(l.email),
                    icon: const Icon(Icons.mail_outline, size: 18),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(l.mobile),
                    icon: const Icon(Icons.phone_outlined, size: 18),
                  ),
                ],
                selected: {usePhone},
                onSelectionChanged: (s) => ui.usePhone.value = s.first,
              ),
              const SizedBox(height: SsLayout.item),
              if (!usePhone)
                TextFormField(
                  controller: ui.email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l.email,
                    prefixIcon: const Icon(Icons.mail_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l.requiredField;
                    if (!v.contains('@')) return l.invalidEmail;
                    return null;
                  },
                )
              else
                TextFormField(
                  controller: ui.phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l.mobile,
                    prefixText: '+91 ',
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    if (d.length < 10) return l.invalidPhone;
                    return null;
                  },
                ),
              const SizedBox(height: SsLayout.item),
              TextFormField(
                controller: ui.altPhone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l.altMobile,
                  prefixIcon: const Icon(Icons.phone_forwarded_outlined),
                ),
              ),
              const SizedBox(height: SsLayout.item),
              TextFormField(
                controller: ui.password,
                obscureText: obscure,
                onChanged: ui.onPasswordChanged,
                decoration: InputDecoration(
                  labelText: l.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: ui.toggleObscurePassword,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.length < 8) ? l.weakPassword : null,
              ),
              const SizedBox(height: 6),
              Text(
                '${l.passwordStrength}: ${strength < 2 ? l.strengthWeak : strength < 3 ? l.strengthFair : l.strengthStrong}',
                style: SsLayout.captionStyle(context),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (strength / 4).clamp(0.1, 1),
                  minHeight: 6,
                  backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(height: SsLayout.item),
              TextFormField(
                controller: ui.confirm,
                obscureText: obscure2,
                decoration: InputDecoration(
                  labelText: l.confirmPassword,
                  prefixIcon: const Icon(Icons.lock_person_outlined),
                  suffixIcon: IconButton(
                    onPressed: ui.toggleObscureConfirm,
                    icon: Icon(
                      obscure2
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (v) =>
                    v != ui.password.text ? l.passwordMismatch : null,
              ),
              const SizedBox(height: SsLayout.section),
              if (auth.error.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: SsLayout.tight),
                  child: Text(
                    auth.error.value,
                    style: TextStyle(color: scheme.error),
                  ),
                ),
              FilledButton(
                onPressed: auth.loading.value
                    ? null
                    : () async {
                        if (!ui.formKey.currentState!.validate()) return;
                        final ok = await auth.register(
                          fullName: ui.name.text.trim(),
                          password: ui.password.text,
                          email: usePhone ? null : ui.email.text.trim(),
                          phone: usePhone ? ui.phone.text.trim() : null,
                          altPhone: ui.altPhone.text.trim().isEmpty
                              ? null
                              : ui.altPhone.text.trim(),
                          languagePref: lang,
                        );
                        if (ok) Get.offAllNamed(auth.routeAfterAuth());
                      },
                child: Text(auth.loading.value ? l.loading : l.createAccount),
              ),
              TextButton(
                onPressed: () => Get.offNamed('/sign-in'),
                child: Text('${l.alreadyHaveAccount} ${l.signIn}'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
