import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_debug_fill_button.dart';
import '../../../core/widgets/ss_page.dart';
import '../../../core/widgets/ss_widgets.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingFlowView extends StatelessWidget {
  const OnboardingFlowView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = Get.put(OnboardingController());
    final scheme = Theme.of(context).colorScheme;

    return SsScaffoldWash(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l.resumeOnboarding,
            style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                  color: SsLayout.title(scheme),
                ),
          ),
          leading: Obx(() => c.step.value > 1
              ? IconButton(onPressed: c.back, icon: const Icon(Icons.arrow_back))
              : const SizedBox.shrink()),
        ),
        body: SafeArea(
          child: Obx(() {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SsLayout.pageH,
                    SsLayout.tight,
                    SsLayout.pageH,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title(l, c.step.value),
                        style: SsLayout.titleStyle(context),
                      ),
                      const SizedBox(height: SsLayout.tight),
                      LinearProgressIndicator(value: c.step.value / 5),
                      Text(
                        'Step ${c.step.value} / 5',
                        style: SsLayout.captionStyle(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: !c.draftReady.value
                      ? const SsLoading()
                      : SingleChildScrollView(
                          padding: SsLayout.formPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SsDebugFillButton(onPressed: c.fillDebugData),
                              KeyedSubtree(
                                key: ValueKey('ob_${c.formEpoch.value}'),
                                child: _stepBody(context, l, c),
                              ),
                            ],
                          ),
                        ),
                ),
                if (c.error.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: SsLayout.pageH),
                    child: Text(
                      c.error.value,
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                Padding(
                  padding: SsLayout.formPadding,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: c.loading.value
                              ? null
                              : () async {
                                  await c.saveDraft();
                                  Get.snackbar(l.saveDraft, l.save);
                                },
                          child: Text(l.saveDraft),
                        ),
                      ),
                      const SizedBox(width: SsLayout.item),
                      Expanded(
                        child: FilledButton(
                          onPressed: c.loading.value
                              ? null
                              : () async {
                                  if (c.step.value < 5) {
                                    await c.next();
                                  } else {
                                    final ok = await c.finish();
                                    if (ok) {
                                      Get.offAllNamed('/home');
                                      Get.snackbar(l.appName, l.welcomeShop);
                                    }
                                  }
                                },
                          child: Text(
                            c.loading.value
                                ? l.loading
                                : (c.step.value < 5 ? l.saveContinue : l.finish),
                          ),
                        ),
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

  String _title(AppLocalizations l, int step) => switch (step) {
        1 => l.onboardingShopProfile,
        2 => l.onboardingAddress,
        3 => l.onboardingPreferences,
        4 => l.onboardingSettings,
        _ => l.onboardingReview,
      };

  Widget _stepBody(
    BuildContext context,
    AppLocalizations l,
    OnboardingController c,
  ) {
    switch (c.step.value) {
      case 1:
        return Column(
          children: [
            _field(l.shopName, c.shopName),
            _field(l.ownerName, c.ownerName),
            _field(l.shopPhone, c.shopPhone, keyboard: TextInputType.phone),
            _field(l.shopEmail, c.shopEmail, keyboard: TextInputType.emailAddress),
            _field(l.altMobile, c.altPhone, keyboard: TextInputType.phone),
            _field(l.description, c.description, maxLines: 3),
          ],
        );
      case 2:
        return Column(
          children: [
            _field(l.address1, c.address1),
            _field(l.address2, c.address2),
            _field(l.area, c.area),
            _field(l.city, c.city),
            _field(l.state, c.state),
            _field(l.pincode, c.pincode, keyboard: TextInputType.number),
            _field(l.country, c.country),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.businessType, style: SsLayout.titleStyle(context)),
            Wrap(
              spacing: SsLayout.tight,
              children: [
                for (final t in [
                  'mens',
                  'womens',
                  'unisex',
                  'boutique',
                  'other',
                ])
                  FilterChip(
                    label: Text(t),
                    selected: c.businessTypes.contains(t),
                    onSelected: (v) {
                      if (v) {
                        c.businessTypes.add(t);
                      } else {
                        c.businessTypes.remove(t);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: SsLayout.item),
            Text(l.garments, style: SsLayout.titleStyle(context)),
            Wrap(
              spacing: SsLayout.tight,
              children: [
                for (final g in [
                  'shirt',
                  'trouser',
                  'kurta',
                  'blouse',
                  'suit',
                  'dress',
                ])
                  FilterChip(
                    label: Text(g),
                    selected: c.garments.contains(g),
                    onSelected: (v) {
                      if (v) {
                        c.garments.add(g);
                      } else {
                        c.garments.remove(g);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: SsLayout.section),
            Text(l.unitInches, style: SsLayout.titleStyle(context)),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'INCH', label: Text(l.unitInches)),
                ButtonSegment(value: 'CM', label: Text(l.unitCm)),
              ],
              selected: {c.unit.value},
              onSelectionChanged: (s) => c.unit.value = s.first,
            ),
            const SizedBox(height: SsLayout.item),
            Text(l.language, style: SsLayout.titleStyle(context)),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'gu', label: Text('ગુ')),
                ButtonSegment(value: 'hi', label: Text('हिं')),
                ButtonSegment(value: 'en', label: Text('EN')),
              ],
              selected: {c.language.value},
              onSelectionChanged: (s) => c.language.value = s.first,
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            _field(l.receiptHeader, c.receiptHeader),
            _field(l.receiptFooter, c.receiptFooter),
            _field('${l.shopPhone} (receipt)', c.receiptContact),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _review(context, l.shopName, c.shopName.value),
            _review(context, l.ownerName, c.ownerName.value),
            _review(
              context,
              l.city,
              '${c.city.value}, ${c.state.value} ${c.pincode.value}',
            ),
            _review(context, l.address1, c.address1.value),
            _review(context, l.businessType, c.businessTypes.join(', ')),
            _review(context, l.garments, c.garments.join(', ')),
            _review(context, l.language, c.language.value),
            TextButton(
              onPressed: () => c.step.value = 1,
              child: Text(l.back),
            ),
          ],
        );
    }
  }

  Widget _field(
    String label,
    RxString value, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SsLayout.item),
      child: TextFormField(
        initialValue: value.value,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
        onChanged: (v) => value.value = v,
      ),
    );
  }

  Widget _review(BuildContext context, String label, String value) {
    return SsListTile(
      title: label,
      subtitle: value.isEmpty ? '—' : value,
    );
  }
}
