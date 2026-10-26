import 'package:flutter/material.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/widgets/ss_page.dart';

/// Shown for modules that need backend tables/APIs not yet in the Nest project.
class ModulePlaceholderView extends StatelessWidget {
  const ModulePlaceholderView({
    super.key,
    required this.title,
    required this.backendGap,
  });

  final String title;
  final String backendGap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SsPage(
      title: title,
      padding: SsLayout.formPadding,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.moduleNotReady, style: SsLayout.titleStyle(context)),
          const SizedBox(height: SsLayout.item),
          Text(backendGap, style: SsLayout.bodyStyle(context)),
          const SizedBox(height: SsLayout.section),
          Text(l.moduleNotReadyHint, style: SsLayout.captionStyle(context)),
        ],
      ),
    );
  }
}
