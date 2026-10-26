import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/config/brand.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/app_intro_ui_controller.dart';

class AppIntroView extends StatelessWidget {
  const AppIntroView({super.key});

  static const _pages = [
    _IntroPage(
      asset: 'assets/onboarding/onboard_measure.jpg',
      titleKey: 0,
    ),
    _IntroPage(
      asset: 'assets/onboarding/onboard_orders.jpg',
      titleKey: 1,
    ),
    _IntroPage(
      asset: 'assets/onboarding/onboard_grow.jpg',
      titleKey: 2,
    ),
  ];

  (String, String) _copy(AppLocalizations l, int i) {
    return switch (i) {
      0 => (l.intro1Title, l.intro1Tagline),
      1 => (l.intro2Title, l.intro2Tagline),
      _ => (l.intro3Title, l.intro3Tagline),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final ui = Get.put(AppIntroUiController());

    return SsScaffoldWash(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Obx(() {
            final index = ui.pageIndex.value;
            final isLast = ui.isLast;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SsLayout.pageH,
                    SsLayout.tight,
                    SsLayout.pageH,
                    0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        Brand.name,
                        style: GoogleFonts.fraunces(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: SsLayout.title(scheme),
                        ),
                      ),
                      const Spacer(),
                      if (!isLast)
                        TextButton(
                          onPressed: ui.finish,
                          child: Text(l.introSkip),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: ui.pageController,
                    itemCount: _pages.length,
                    onPageChanged: ui.onPageChanged,
                    itemBuilder: (_, i) {
                      final page = _pages[i];
                      final (title, tagline) = _copy(l, page.titleKey);
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                          SsLayout.pageH,
                          SsLayout.item,
                          SsLayout.pageH,
                          SsLayout.item,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 6,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(SsLayout.radius),
                                child: Image.asset(
                                  page.asset,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => ColoredBox(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.06),
                                    child: Icon(
                                      Icons.checkroom_outlined,
                                      size: 64,
                                      color: SsLayout.muted(scheme),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: SsLayout.section),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: GoogleFonts.fraunces(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      height: 1.15,
                                      color: SsLayout.title(scheme),
                                    ),
                                  ),
                                  const SizedBox(height: SsLayout.item),
                                  Text(
                                    tagline,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: SsLayout.body(scheme),
                                          height: 1.4,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SsLayout.pageH,
                    0,
                    SsLayout.pageH,
                    SsLayout.section,
                  ),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(_pages.length, (i) {
                          final active = i == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.only(right: 6),
                            height: 8,
                            width: active ? 22 : 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? scheme.onSurface
                                  : scheme.onSurface.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          );
                        }),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: ui.next,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(88, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Text(isLast ? l.introGetStarted : l.introNext),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _IntroPage {
  const _IntroPage({required this.asset, required this.titleKey});
  final String asset;
  final int titleKey;
}
