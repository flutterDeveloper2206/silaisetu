import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../widgets/auth_scaffold.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrandHeader(subtitle: l.tagline),
          const SizedBox(height: 40),
          FilledButton(
            onPressed: () => Get.toNamed('/sign-in'),
            child: Text(l.signIn),
          ),
          const SizedBox(height: SsLayout.item),
          OutlinedButton(
            onPressed: () => Get.toNamed('/sign-up'),
            child: Text(l.signUp),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Get.snackbar(l.privacy, 'Configure PRIVACY_URL when ready');
                },
                child: Text(l.privacy),
              ),
              const Text(' · '),
              TextButton(
                onPressed: () {
                  Get.snackbar(l.terms, 'Configure TERMS_URL when ready');
                },
                child: Text(l.terms),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
