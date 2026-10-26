import 'package:flutter/material.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../features/measurements/data/measurement_l10n.dart';
import '../theme/ss_layout.dart';

/// Renders a measurement `values` map as readable chips / rows.
class SsMeasurementValues extends StatelessWidget {
  const SsMeasurementValues({
    super.key,
    required this.values,
    this.unit,
    this.compact = false,
  });

  final Map values;
  final String? unit;
  final bool compact;

  static Map<String, String> readableEntries(
    Map? raw, {
    AppLocalizations? l,
  }) {
    if (raw == null) return {};
    final out = <String, String>{};
    for (final e in raw.entries) {
      final key = '${e.key}';
      if (key == 'category' || key == 'categoryLabel') continue;
      final v = e.value;
      if (v == null || '$v'.trim().isEmpty) continue;
      final label = l?.measurementPomLabel(key) ?? _fallbackLabel(key);
      out[label] = '$v';
    }
    return out;
  }

  static String _fallbackLabel(String id) {
    return id
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final entries = readableEntries(values, l: l);
    if (entries.isEmpty) {
      return Text('—', style: SsLayout.captionStyle(context));
    }
    final scheme = Theme.of(context).colorScheme;
    final unitSuffix = (unit != null && unit!.isNotEmpty) ? ' $unit' : '';

    if (compact) {
      final preview =
          entries.entries.take(4).map((e) => '${e.key} ${e.value}').join(' · ');
      final more = entries.length > 4 ? ' +${entries.length - 4}' : '';
      return Text(
        '$preview$more',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: SsLayout.captionStyle(context),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in entries.entries)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(SsLayout.radiusSm),
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${e.key}  ',
                    style: TextStyle(
                      color: SsLayout.muted(scheme),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '${e.value}$unitSuffix',
                    style: TextStyle(
                      color: SsLayout.title(scheme),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
