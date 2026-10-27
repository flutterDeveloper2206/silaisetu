import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_debug_fill_button.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sign_in_ui_controller.dart';
import '../widgets/auth_scaffold.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = Get.find<AuthController>();
    final ui = Get.put(SignInUiController());

    return AuthScaffold(
      showBack: true,
      child: Form(
        key: ui.formKey,
        child: Obx(() {
          final obscure = ui.obscurePassword.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BrandHeader(subtitle: l.signIn),
              const SizedBox(height: 20),
              SsDebugFillButton(onPressed: ui.debugFill),
              TextFormField(
                controller: ui.identifier,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l.emailOrMobile),
                validator: (v) =>
                    (v == null || v.trim().length < 3) ? l.requiredField : null,
              ),
              const SizedBox(height: SsLayout.item),
              TextFormField(
                controller: ui.password,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: l.password,
                  suffixIcon: IconButton(
                    onPressed: ui.toggleObscure,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l.requiredField : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed('/forgot-password'),
                  child: Text(l.forgotPassword),
                ),
              ),
              if (auth.error.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: SsLayout.tight),
                  child: Text(
                    auth.error.value == 'invalid'
                        ? l.invalidCredentials
                        : auth.error.value == 'offline'
                            ? l.errorGeneric
                            : auth.error.value,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              FilledButton(
                onPressed: auth.loading.value
                    ? null
                    : () async {
                        if (!ui.formKey.currentState!.validate()) return;
                        final ok = await auth.login(
                          ui.identifier.text,
                          ui.password.text,
                        );
                        if (ok) {
                          Get.offAllNamed(await auth.routeAfterAuthAsync());
                        }
                      },
                child: Text(auth.loading.value ? l.loading : l.signIn),
              ),
              const SizedBox(height: SsLayout.item),
              TextButton(
                onPressed: () => Get.toNamed('/forgot-identifier'),
                child: Text(l.forgotIdentifier),
              ),
              TextButton(
                onPressed: () => Get.offNamed('/sign-up'),
                child: Text('${l.newHere} ${l.createAccount}'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
