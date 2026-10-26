import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/config/brand.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_debug_fill_button.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/onboarding_controller.dart';

/// Friendly intro before the multi-step shop setup wizard.
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  void _debugFillAndStart() {
    final c = Get.isRegistered<OnboardingController>()
        ? Get.find<OnboardingController>()
        : Get.put(OnboardingController());
    c.fillDebugData();
    Get.toNamed('/onboarding/flow');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return SsScaffoldWash(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: SsLayout.formPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.onSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'S',
                    style: GoogleFonts.fraunces(
                      color: scheme.surface,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  Brand.name,
                  style: GoogleFonts.fraunces(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: SsLayout.title(scheme),
                  ),
                ),
                const SizedBox(height: SsLayout.item),
                Text(
                  l.onboardingIntroTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: SsLayout.title(scheme),
                      ),
                ),
                const SizedBox(height: SsLayout.item),
                Text(
                  l.onboardingIntroBody,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: SsLayout.body(scheme),
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: SsLayout.section * 2),
                _StepHint(
                  index: '1',
                  title: l.onboardingShopProfile,
                  subtitle: l.onboardingHintProfile,
                ),
                _StepHint(
                  index: '2',
                  title: l.onboardingAddress,
                  subtitle: l.onboardingHintAddress,
                ),
                _StepHint(
                  index: '3',
                  title: l.onboardingPreferences,
                  subtitle: l.onboardingHintPreferences,
                ),
                _StepHint(
                  index: '4',
                  title: l.onboardingSettings,
                  subtitle: l.onboardingHintSettings,
                ),
                const Spacer(),
                SsDebugFillButton(
                  label: '${l.debugFill} → setup',
                  onPressed: _debugFillAndStart,
                ),
                Text(
                  l.onboardingIntroNote,
                  style: SsLayout.captionStyle(context),
                ),
                const SizedBox(height: SsLayout.section),
                FilledButton(
                  onPressed: () => Get.toNamed('/onboarding/flow'),
                  child: Text(l.startSetup),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/onboarding/flow'),
                  child: Text(l.resumeOnboarding),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepHint extends StatelessWidget {
  const _StepHint({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  final String index;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: scheme.onSurface),
              borderRadius: BorderRadius.circular(SsLayout.tight),
            ),
            child: Text(
              index,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: SsLayout.title(scheme),
              ),
            ),
          ),
          const SizedBox(width: SsLayout.item),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: SsLayout.title(scheme),
                  ),
                ),
                Text(
                  subtitle,
                  style: SsLayout.captionStyle(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
