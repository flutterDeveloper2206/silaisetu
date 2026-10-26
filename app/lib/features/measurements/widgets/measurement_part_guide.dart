import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ss_layout.dart';

/// Maps measurement field ids to body-part guide images.
class MeasurementPartGuide {
  static const _assetDir = 'assets/measurements';

  static const overviewAsset = '$_assetDir/measure_body_overview.jpg';

  static const Map<String, String> _byId = {
    'neck': '$_assetDir/measure_neck.jpg',
    'collar': '$_assetDir/measure_neck.jpg',
    'neck_opening': '$_assetDir/measure_neck.jpg',
    'front_neck_drop': '$_assetDir/measure_neck.jpg',
    'back_neck_drop': '$_assetDir/measure_neck.jpg',
    'front_neck_band_width': '$_assetDir/measure_neck.jpg',
    'collar_length': '$_assetDir/measure_neck.jpg',
    'collar_length_outer': '$_assetDir/measure_neck.jpg',
    'collar_height': '$_assetDir/measure_neck.jpg',
    'collar_stand_length': '$_assetDir/measure_neck.jpg',
    'collar_stand_height': '$_assetDir/measure_neck.jpg',
    'collar_point': '$_assetDir/measure_neck.jpg',
    'shoulder': '$_assetDir/measure_shoulder.jpg',
    'shoulders': '$_assetDir/measure_shoulder.jpg',
    'shoulder_length': '$_assetDir/measure_shoulder.jpg',
    'shoulder_length_hps': '$_assetDir/measure_shoulder.jpg',
    'shoulder_seam': '$_assetDir/measure_shoulder.jpg',
    'yoke': '$_assetDir/measure_shoulder.jpg',
    'chest': '$_assetDir/measure_chest.jpg',
    'half_chest': '$_assetDir/measure_chest.jpg',
    'high_chest_armhole': '$_assetDir/measure_chest.jpg',
    'bust': '$_assetDir/measure_bust.jpg',
    'waist': '$_assetDir/measure_waist.jpg',
    'half_waist': '$_assetDir/measure_waist.jpg',
    'waistband_depth': '$_assetDir/measure_waist.jpg',
    'hip': '$_assetDir/measure_hip.jpg',
    'hips': '$_assetDir/measure_hip.jpg',
    'sleeve': '$_assetDir/measure_sleeve.jpg',
    'sleeve_length': '$_assetDir/measure_sleeve.jpg',
    'sleeve_length_underarm': '$_assetDir/measure_sleeve.jpg',
    'sleeve_opening': '$_assetDir/measure_sleeve.jpg',
    'sleeve_hem_width': '$_assetDir/measure_sleeve.jpg',
    'half_bicep': '$_assetDir/measure_sleeve.jpg',
    'armhole': '$_assetDir/measure_sleeve.jpg',
    'armhole_length': '$_assetDir/measure_sleeve.jpg',
    'armhole_curve': '$_assetDir/measure_sleeve.jpg',
    'high_back_armhole': '$_assetDir/measure_sleeve.jpg',
    'cuff': '$_assetDir/measure_sleeve.jpg',
    'length': '$_assetDir/measure_length.jpg',
    'body_length': '$_assetDir/measure_length.jpg',
    'body_length_hps': '$_assetDir/measure_length.jpg',
    'body_length_cb': '$_assetDir/measure_length.jpg',
    'body_back_length': '$_assetDir/measure_length.jpg',
    'side_seam_length': '$_assetDir/measure_length.jpg',
    'outseam_length': '$_assetDir/measure_length.jpg',
    'shirt_length': '$_assetDir/measure_length.jpg',
    'placket_length': '$_assetDir/measure_length.jpg',
    'body_hem': '$_assetDir/measure_length.jpg',
    'body_hem_width': '$_assetDir/measure_length.jpg',
    'bottom_hem_width': '$_assetDir/measure_length.jpg',
    'inseam': '$_assetDir/measure_inseam.jpg',
    'inside_length': '$_assetDir/measure_inseam.jpg',
    'front_rise': '$_assetDir/measure_inseam.jpg',
    'back_rise': '$_assetDir/measure_inseam.jpg',
    'thigh': '$_assetDir/measure_thigh.jpg',
    'half_thigh': '$_assetDir/measure_thigh.jpg',
    'knee': '$_assetDir/measure_thigh.jpg',
    'leg_opening': '$_assetDir/measure_thigh.jpg',
    'pocket_width': '$_assetDir/measure_chest.jpg',
    'pocket_depth': '$_assetDir/measure_chest.jpg',
  };

  static String assetFor(String fieldId) {
    final key = fieldId.trim().toLowerCase().replaceAll(' ', '_');
    if (_byId.containsKey(key)) return _byId[key]!;
    for (final entry in _byId.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return overviewAsset;
  }
}

class MeasurementOverviewCard extends StatelessWidget {
  const MeasurementOverviewCard({super.key, this.hint});

  final String? hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: context.gradients.card,
        borderRadius: BorderRadius.circular(SsLayout.radius),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 110,
              child: Image.asset(
                MeasurementPartGuide.overviewAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: scheme.onSurface.withValues(alpha: 0.04),
                  child: Icon(
                    Icons.accessibility_new,
                    color: SsLayout.muted(scheme),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(SsLayout.item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Body guide', style: SsLayout.titleStyle(context)),
                    if (hint != null) ...[
                      const SizedBox(height: 4),
                      Text(hint!, style: SsLayout.captionStyle(context)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal row: body-part image (left) + label/field (right).
class MeasurementFieldCard extends StatelessWidget {
  const MeasurementFieldCard({
    super.key,
    required this.fieldId,
    required this.label,
    required this.controller,
    required this.unitLabel,
    this.code,
    this.required = false,
    this.helpText,
    this.onRemove,
  });

  final String fieldId;
  final String label;
  final TextEditingController controller;
  final String unitLabel;
  final String? code;
  final bool required;
  final String? helpText;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final asset = MeasurementPartGuide.assetFor(fieldId);

    return Container(
      margin: const EdgeInsets.only(bottom: SsLayout.item),
      decoration: BoxDecoration(
        gradient: context.gradients.card,
        borderRadius: BorderRadius.circular(SsLayout.radius),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 96,
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: scheme.onSurface.withValues(alpha: 0.04),
                  child: Icon(
                    Icons.straighten,
                    color: SsLayout.muted(scheme),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  SsLayout.item,
                  SsLayout.tight,
                  SsLayout.tight,
                  SsLayout.tight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (code != null && code!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.onSurface.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              code!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: SsLayout.title(scheme),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            required ? '$label *' : label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: SsLayout.titleStyle(context).copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (onRemove != null)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: onRemove,
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: SsLayout.muted(scheme),
                            ),
                          ),
                      ],
                    ),
                    if (helpText != null && helpText!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          helpText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SsLayout.captionStyle(context),
                        ),
                      ),
                    TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        color: SsLayout.title(scheme),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '0',
                        hintStyle: TextStyle(color: SsLayout.muted(scheme)),
                        suffixText: unitLabel,
                        suffixStyle: TextStyle(
                          color: SsLayout.body(scheme),
                          fontWeight: FontWeight.w600,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
