import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../controllers/auth_controller.dart';
import '../controllers/forgot_password_ui_controller.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = Get.find<AuthController>();
    final ui = Get.put(ForgotPasswordUiController());

    return AuthScaffold(
      showBack: true,
      child: Obx(() {
        final message = ui.message.value;
        final token = ui.devToken.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrandHeader(subtitle: l.forgotPassword),
            const SizedBox(height: SsLayout.section),
            TextFormField(
              controller: ui.identifier,
              decoration: InputDecoration(labelText: l.emailOrMobile),
            ),
            const SizedBox(height: SsLayout.section),
            if (message != null)
              Text(message, style: SsLayout.bodyStyle(context)),
            if (token != null) ...[
              const SizedBox(height: SsLayout.tight),
              Text(
                '${l.devCodeHint}: $token',
                style: SsLayout.captionStyle(context),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/reset-password', arguments: token),
                child: Text(l.resetPassword),
              ),
            ],
            const SizedBox(height: SsLayout.item),
            FilledButton(
              onPressed: auth.loading.value
                  ? null
                  : () => ui.submit(l.resetSent),
              child: Text(auth.loading.value ? l.loading : l.sendReset),
            ),
          ],
        );
      }),
    );
  }
}

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = Get.find<AuthController>();
    final ui = Get.put(ResetPasswordUiController());

    return AuthScaffold(
      showBack: true,
      child: Form(
        key: ui.formKey,
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BrandHeader(subtitle: l.resetPassword),
              const SizedBox(height: SsLayout.section),
              TextFormField(
                controller: ui.token,
                decoration: const InputDecoration(labelText: 'Reset token / OTP'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l.requiredField : null,
              ),
              const SizedBox(height: SsLayout.item),
              TextFormField(
                controller: ui.password,
                obscureText: true,
                decoration: InputDecoration(labelText: l.newPassword),
                validator: (v) =>
                    (v == null || v.length < 8) ? l.weakPassword : null,
              ),
              const SizedBox(height: SsLayout.item),
              TextFormField(
                controller: ui.confirm,
                obscureText: true,
                decoration: InputDecoration(labelText: l.confirmPassword),
                validator: (v) =>
                    v != ui.password.text ? l.passwordMismatch : null,
              ),
              if (auth.error.value.isNotEmpty)
                Text(auth.error.value,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: SsLayout.section),
              FilledButton(
                onPressed: auth.loading.value
                    ? null
                    : () async {
                        if (!ui.formKey.currentState!.validate()) return;
                        final ok = await auth.resetPassword(
                          ui.token.text.trim(),
                          ui.password.text,
                        );
                        if (ok) {
                          Get.snackbar(l.resetPassword, l.signIn);
                          Get.offAllNamed('/sign-in');
                        }
                      },
                child: Text(auth.loading.value ? l.loading : l.resetPassword),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class ForgotIdentifierView extends StatelessWidget {
  const ForgotIdentifierView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = Get.find<AuthController>();
    final ui = Get.put(ForgotIdentifierUiController());

    return AuthScaffold(
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrandHeader(subtitle: l.forgotIdentifier),
          const SizedBox(height: SsLayout.section),
          Text(l.supportHelp, style: SsLayout.bodyStyle(context)),
          const SizedBox(height: SsLayout.section),
          TextField(
            controller: ui.contact,
            decoration: InputDecoration(labelText: l.altMobile),
          ),
          const SizedBox(height: SsLayout.section),
          FilledButton(
            onPressed: () async {
              final res = await auth.api.dio.post('/auth/forgot-identifier', data: {
                'recoveryContact': ui.contact.text.trim(),
              });
              Get.snackbar(
                l.forgotIdentifier,
                (res.data as Map)['message']?.toString() ?? l.supportHelp,
              );
            },
            child: Text(l.continueLabel),
          ),
        ],
      ),
    );
  }
}

class VerifyView extends StatelessWidget {
  const VerifyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final ui = Get.put(VerifyUiController());
    final auth = ui.auth;

    return AuthScaffold(
      child: Obx(() {
        final hint = ui.devCode.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrandHeader(subtitle: l.verifyAccount),
            const SizedBox(height: SsLayout.section),
            TextFormField(
              controller: ui.code,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.enterOtp),
            ),
            if (hint != null)
              Text(
                '${l.devCodeHint}: $hint',
                style: SsLayout.captionStyle(context),
              ),
            const SizedBox(height: SsLayout.section),
            FilledButton(
              onPressed: auth.loading.value
                  ? null
                  : () async {
                      final ok = await auth.confirmVerify(ui.code.text.trim());
                      if (ok) Get.offAllNamed(auth.routeAfterAuth());
                    },
              child: Text(auth.loading.value ? l.loading : l.continueLabel),
            ),
            TextButton(onPressed: ui.request, child: Text(l.resendCode)),
          ],
        );
      }),
    );
  }
}
