/// One garment category — only its own measurement components are shown.
class MeasurementCategory {
  const MeasurementCategory({
    required this.id,
    required this.label,
    required this.templateCode,
    required this.icon,
    required this.components,
  });

  final String id;
  final String label;
  final String templateCode;
  final String icon; // material icon name hint
  final List<MeasurementComponent> components;
}

class MeasurementComponent {
  const MeasurementComponent({
    required this.id,
    required this.name,
    this.code,
    this.required = false,
    this.helpText,
  });

  final String id;
  final String name;
  final String? code;
  final bool required;
  final String? helpText;
}

class MeasurementCatalog {
  static const categories = <MeasurementCategory>[
    MeasurementCategory(
      id: 'man_shirt',
      label: 'Man Shirt',
      templateCode: 'shirt',
      icon: 'checkroom',
      components: [
        MeasurementComponent(
            id: 'half_chest', name: '½ Chest', code: 'A', required: true),
        MeasurementComponent(id: 'half_waist', name: '½ Waist', code: 'B'),
        MeasurementComponent(
            id: 'shoulder_length_hps',
            name: 'Shoulder (HPS)',
            code: 'D',
            required: true),
        MeasurementComponent(
            id: 'sleeve_length', name: 'Sleeve Length', code: 'F', required: true),
        MeasurementComponent(id: 'half_bicep', name: '½ Bicep', code: 'H'),
        MeasurementComponent(id: 'sleeve_opening', name: 'Sleeve Opening', code: 'I'),
        MeasurementComponent(id: 'armhole_length', name: 'Arm Hole', code: 'G'),
        MeasurementComponent(
            id: 'body_length_hps',
            name: 'Body Length (HPS)',
            code: 'O',
            required: true),
        MeasurementComponent(
            id: 'neck', name: 'Neck / Collar', code: 'Q', required: true),
        MeasurementComponent(
            id: 'collar_stand_length', name: 'Collar Stand Length', code: 'S'),
        MeasurementComponent(id: 'collar_height', name: 'Collar Height', code: 'R'),
        MeasurementComponent(id: 'cuff', name: 'Cuff'),
        MeasurementComponent(id: 'yoke', name: 'Yoke'),
      ],
    ),
    MeasurementCategory(
      id: 'man_pant',
      label: 'Man Pant',
      templateCode: 'trouser',
      icon: 'straighten',
      components: [
        MeasurementComponent(
            id: 'half_waist', name: '½ Waist', code: 'A', required: true),
        MeasurementComponent(id: 'hip', name: 'Hip', code: 'B', required: true),
        MeasurementComponent(id: 'half_thigh', name: '½ Thigh', code: 'C'),
        MeasurementComponent(id: 'knee', name: 'Knee', code: 'D'),
        MeasurementComponent(id: 'leg_opening', name: 'Leg Opening', code: 'E'),
        MeasurementComponent(
            id: 'outseam_length',
            name: 'Length (Outseam)',
            code: 'F',
            required: true),
        MeasurementComponent(id: 'inseam', name: 'Inseam'),
        MeasurementComponent(id: 'front_rise', name: 'Front Rise'),
        MeasurementComponent(id: 'back_rise', name: 'Back Rise'),
      ],
    ),
    MeasurementCategory(
      id: 'man_tshirt',
      label: 'Man T-Shirt',
      templateCode: 'tshirt',
      icon: 'checkroom',
      components: [
        MeasurementComponent(
            id: 'half_chest', name: '½ Chest', code: 'A', required: true),
        MeasurementComponent(
            id: 'body_length', name: 'Body Length', code: 'B', required: true),
        MeasurementComponent(id: 'half_waist', name: '½ Waist', code: 'C'),
        MeasurementComponent(
            id: 'shoulder_length',
            name: 'Shoulder Length',
            code: 'D',
            required: true),
        MeasurementComponent(
            id: 'sleeve_length', name: 'Sleeve Length', code: 'F', required: true),
        MeasurementComponent(id: 'half_bicep', name: '½ Bicep', code: 'G'),
        MeasurementComponent(id: 'sleeve_opening', name: 'Sleeve Opening', code: 'H'),
        MeasurementComponent(id: 'neck_opening', name: 'Neck Opening', code: 'I'),
        MeasurementComponent(id: 'armhole', name: 'Arm Hole', code: 'O'),
        MeasurementComponent(id: 'bottom_hem_width', name: 'Bottom Hem Width', code: 'Q'),
      ],
    ),
    MeasurementCategory(
      id: 'man_polo',
      label: 'Man Polo',
      templateCode: 'polo',
      icon: 'checkroom',
      components: [
        MeasurementComponent(
            id: 'body_length', name: 'Body Length', code: 'A', required: true),
        MeasurementComponent(
            id: 'half_chest', name: '½ Chest', code: 'B', required: true),
        MeasurementComponent(
            id: 'shoulder_length',
            name: 'Shoulder Length',
            code: 'C',
            required: true),
        MeasurementComponent(
            id: 'sleeve_length', name: 'Sleeve Length', code: 'D', required: true),
        MeasurementComponent(id: 'armhole_length', name: 'Arm Hole Length', code: 'E'),
        MeasurementComponent(id: 'collar_length', name: 'Collar Length', code: 'F'),
        MeasurementComponent(id: 'placket_length', name: 'Placket Length', code: 'G'),
        MeasurementComponent(id: 'sleeve_opening', name: 'Sleeve Opening', code: 'H'),
      ],
    ),
    MeasurementCategory(
      id: 'woman_blouse',
      label: 'Woman Blouse',
      templateCode: 'blouse',
      icon: 'checkroom',
      components: [
        MeasurementComponent(id: 'bust', name: 'Bust', required: true),
        MeasurementComponent(id: 'half_waist', name: '½ Waist'),
        MeasurementComponent(
            id: 'shoulder_length', name: 'Shoulder Length', required: true),
        MeasurementComponent(
            id: 'body_length', name: 'Body Length', required: true),
        MeasurementComponent(id: 'sleeve_length', name: 'Sleeve Length'),
        MeasurementComponent(id: 'armhole', name: 'Arm Hole'),
        MeasurementComponent(id: 'neck_opening', name: 'Neck Opening'),
        MeasurementComponent(id: 'front_neck_drop', name: 'Front Neck Drop'),
        MeasurementComponent(id: 'back_neck_drop', name: 'Back Neck Drop'),
      ],
    ),
    MeasurementCategory(
      id: 'woman_kurta',
      label: 'Woman Kurta',
      templateCode: 'kurta',
      icon: 'checkroom',
      components: [
        MeasurementComponent(
            id: 'half_chest', name: '½ Chest', required: true),
        MeasurementComponent(
            id: 'shoulder_length', name: 'Shoulder Length', required: true),
        MeasurementComponent(
            id: 'body_length', name: 'Body Length', required: true),
        MeasurementComponent(id: 'sleeve_length', name: 'Sleeve Length'),
        MeasurementComponent(id: 'half_waist', name: '½ Waist'),
        MeasurementComponent(id: 'hip', name: 'Hip'),
        MeasurementComponent(id: 'neck', name: 'Neck'),
        MeasurementComponent(id: 'armhole', name: 'Arm Hole'),
        MeasurementComponent(id: 'bottom_hem_width', name: 'Bottom Hem'),
      ],
    ),
  ];

  static MeasurementCategory? byId(String? id) {
    if (id == null) return null;
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }
}
