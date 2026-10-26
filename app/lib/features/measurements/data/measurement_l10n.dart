import 'package:silaisetu/core/localization/l10n/app_localizations.dart';

/// Localizes measurement category and POM field names.
extension MeasurementL10n on AppLocalizations {
  String measurementCategoryLabel(String categoryId) {
    return switch (categoryId) {
      'man_shirt' => catManShirt,
      'man_pant' => catManPant,
      'man_tshirt' => catManTshirt,
      'man_polo' => catManPolo,
      'woman_blouse' => catWomanBlouse,
      'woman_kurta' => catWomanKurta,
      _ => categoryId,
    };
  }

  String measurementPomLabel(String fieldId, {String? fallback}) {
    return switch (fieldId) {
      'half_chest' => pomHalfChest,
      'chest' => pomChest,
      'half_waist' => pomHalfWaist,
      'waist' => pomWaist,
      'shoulder_length_hps' => pomShoulderHps,
      'shoulder_length' => pomShoulderLength,
      'shoulder' => pomShoulder,
      'sleeve_length' => pomSleeveLength,
      'sleeve' => pomSleeve,
      'half_bicep' => pomHalfBicep,
      'sleeve_opening' => pomSleeveOpening,
      'armhole' => pomArmhole,
      'armhole_length' => pomArmholeLength,
      'body_length' => pomBodyLength,
      'body_length_hps' => pomBodyLengthHps,
      'length' => pomLength,
      'neck' => pomNeckCollar,
      'neck_opening' => pomNeckOpening,
      'collar_stand_length' => pomCollarStandLength,
      'collar_height' => pomCollarHeight,
      'collar_length' => pomCollarLength,
      'cuff' => pomCuff,
      'yoke' => pomYoke,
      'hip' || 'hips' => pomHip,
      'half_thigh' => pomHalfThigh,
      'thigh' => pomThigh,
      'knee' => pomKnee,
      'leg_opening' => pomLegOpening,
      'outseam_length' => pomOutseamLength,
      'inseam' => pomInseam,
      'front_rise' => pomFrontRise,
      'back_rise' => pomBackRise,
      'bottom_hem_width' => pomBottomHemWidth,
      'bottom_hem' => pomBottomHem,
      'placket_length' => pomPlacketLength,
      'bust' => pomBust,
      'front_neck_drop' => pomFrontNeckDrop,
      'back_neck_drop' => pomBackNeckDrop,
      _ => fallback ??
          fieldId
              .replaceAll('_', ' ')
              .split(' ')
              .where((w) => w.isNotEmpty)
              .map((w) => w[0].toUpperCase() + w.substring(1))
              .join(' '),
    };
  }
}
