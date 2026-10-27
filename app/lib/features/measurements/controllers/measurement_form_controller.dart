import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/ss_layout.dart';
import '../../../core/utils/ss_feedback.dart';
import '../data/measurement_catalog.dart';

class MeasurementFieldDef {
  const MeasurementFieldDef({
    required this.id,
    required this.name,
    this.code,
    this.required = false,
    this.helpText,
    this.custom = false,
  });
  final String id;
  final String name;
  final String? code;
  final bool required;
  final String? helpText;
  final bool custom;
}

class MeasurementFormController extends GetxController {
  final api = Get.find<ApiClient>();

  final customers = <dynamic>[].obs;
  final templates = <dynamic>[].obs;
  final customerId = RxnString();
  final categoryId = RxnString();
  String? orderId;
  String? orderItemId;
  String? preferredTemplateId;
  final garmentNameHint = RxnString();
  final unit = 'INCH'.obs;
  final notes = TextEditingController();
  final fields = <String, TextEditingController>{}.obs;
  final fieldDefs = <MeasurementFieldDef>[].obs;
  final loading = true.obs;
  final saving = false.obs;

  static const _legacyAliases = <String, List<String>>{
    'chest': ['half_chest', 'bust', 'chest'],
    'shoulder': [
      'shoulder_length',
      'shoulder_length_hps',
      'shoulder_seam',
      'shoulder',
    ],
    'sleeve': ['sleeve_length', 'sleeve'],
    'length': [
      'body_length',
      'body_length_hps',
      'outseam_length',
      'length',
    ],
    'waist': ['half_waist', 'waist'],
    'hip': ['hip', 'hips'],
    'neck': ['neck', 'neck_opening', 'collar_length'],
    'inseam': ['inseam', 'inside_length'],
    'thigh': ['half_thigh', 'thigh'],
  };

  static const _demoValues = <String, String>{
    'half_chest': '20',
    'half_waist': '18',
    'shoulder_length_hps': '17',
    'sleeve_length': '24',
    'half_bicep': '7.5',
    'sleeve_opening': '5',
    'armhole_length': '9',
    'body_length_hps': '29',
    'body_length': '28',
    'neck': '15.5',
    'collar_stand_length': '16',
    'collar_height': '1.5',
    'cuff': '9',
    'yoke': '16',
    'hip': '40',
    'half_thigh': '12',
    'knee': '9',
    'leg_opening': '8',
    'outseam_length': '40',
    'inseam': '30',
    'front_rise': '11',
    'back_rise': '14',
    'bust': '38',
    'shoulder': '15',
    'sleeve': '22',
    'length': '28',
    'waist': '32',
    'thigh': '24',
  };

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['customerId'] != null) customerId.value = '${args['customerId']}';
      if (args['orderId'] != null) orderId = '${args['orderId']}';
      if (args['orderItemId'] != null) {
        orderItemId = '${args['orderItemId']}';
      }
      if (args['garmentTemplateId'] != null) {
        preferredTemplateId = '${args['garmentTemplateId']}';
      }
      if (args['garmentName'] != null) {
        garmentNameHint.value = '${args['garmentName']}';
      }
    }
    bootstrap();
  }

  @override
  void onClose() {
    notes.dispose();
    for (final c in fields.values) {
      c.dispose();
    }
    super.onClose();
  }

  MeasurementCategory? get category => MeasurementCatalog.byId(categoryId.value);

  Future<void> bootstrap() async {
    final results = await Future.wait([
      api.dio.get('/customers', queryParameters: {'pageSize': 100}),
      api.dio.get('/garment-templates'),
    ]);
    customers.assignAll((results[0].data as Map)['items'] as List? ?? []);
    final tData = results[1].data;
    templates.assignAll(
      tData is List
          ? tData
          : ((tData as Map?)?['items'] as List? ?? []),
    );
    // Prefer category from order garment name / template when opened from order.
    final hint = (garmentNameHint.value ?? '').toLowerCase();
    String? autoCategory;
    if (preferredTemplateId != null) {
      for (final t in templates) {
        if (t is! Map || '${t['id']}' != preferredTemplateId) continue;
        final code = '${t['code'] ?? ''}'.toLowerCase();
        for (final c in MeasurementCatalog.categories) {
          final tc = c.templateCode.toLowerCase();
          if (code == tc || code.contains(tc) || tc.contains(code)) {
            autoCategory = c.id;
            break;
          }
        }
      }
    }
    if (autoCategory == null && hint.isNotEmpty) {
      if (hint.contains('pant') || hint.contains('trouser')) {
        autoCategory = 'man_pant';
      } else if (hint.contains('kurta')) {
        autoCategory = 'woman_kurta';
      } else if (hint.contains('blouse')) {
        autoCategory = 'woman_blouse';
      } else if (hint.contains('polo')) {
        autoCategory = 'man_polo';
      } else if (hint.contains('t-shirt') || hint.contains('tshirt')) {
        autoCategory = 'man_tshirt';
      } else if (hint.contains('shirt')) {
        autoCategory = 'man_shirt';
      }
    }
    if (autoCategory != null) {
      selectCategory(autoCategory);
    }
    loading.value = false;
  }

  String? templateIdForCategory() {
    final cat = category;
    if (cat == null) return null;
    final code = cat.templateCode.toLowerCase();
    for (final t in templates) {
      if (t is! Map) continue;
      final tc = '${t['code'] ?? ''}'.toLowerCase();
      final tn = '${t['name'] ?? ''}'.toLowerCase();
      if (tc == code ||
          tn.contains(code) ||
          tn.contains(cat.label.toLowerCase())) {
        return '${t['id']}';
      }
    }
    // Fallback: shirt→any shirt-like, pant→trouser, etc.
    for (final t in templates) {
      if (t is! Map) continue;
      final key = '${t['code']} ${t['name']}'.toLowerCase();
      if (code.contains('shirt') &&
          key.contains('shirt') &&
          !key.contains('t')) {
        return '${t['id']}';
      }
      if ((code.contains('trouser') || code.contains('pant')) &&
          (key.contains('trouser') || key.contains('pant'))) {
        return '${t['id']}';
      }
      if (code.contains('tshirt') &&
          (key.contains('tshirt') || key.contains('t-shirt'))) {
        return '${t['id']}';
      }
      if (code.contains('polo') && key.contains('polo')) return '${t['id']}';
      if (code.contains('blouse') && key.contains('blouse')) {
        return '${t['id']}';
      }
      if (code.contains('kurta') && key.contains('kurta')) return '${t['id']}';
    }
    if (templates.isNotEmpty && templates.first is Map) {
      return '${(templates.first as Map)['id']}';
    }
    return null;
  }

  void selectCategory(String id) {
    final previousValues = <String, String>{};
    final oldControllers = List<TextEditingController>.from(fields.values);
    for (final e in fields.entries) {
      previousValues[e.key] = e.value.text;
    }
    final nextFields = <String, TextEditingController>{};
    final nextDefs = <MeasurementFieldDef>[];
    categoryId.value = id;
    final cat = MeasurementCatalog.byId(id);
    if (cat != null) {
      for (final c in cat.components) {
        nextDefs.add(
          MeasurementFieldDef(
            id: c.id,
            name: c.name,
            code: c.code,
            required: c.required,
            helpText: c.helpText,
          ),
        );
        nextFields[c.id] =
            TextEditingController(text: previousValues[c.id] ?? '');
      }
    }
    // Swap first so Obx rebuilds with live controllers, then dispose old ones.
    fields.assignAll(nextFields);
    fieldDefs.assignAll(nextDefs);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in oldControllers) {
        c.dispose();
      }
    });
  }

  String _slug(String name) {
    final base = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    var id = base.isEmpty ? 'custom' : base;
    var n = 1;
    while (fields.containsKey(id)) {
      id = '${base}_$n';
      n++;
    }
    return id;
  }

  Future<void> addComponent(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<({String name, String help})>(
      context: context,
      builder: (ctx) => const AddComponentDialog(),
    );
    if (result == null || result.name.isEmpty) return;
    if (categoryId.value == null) {
      SsSnack.error(loc.selectCategoryFirst, title: loc.measurements);
      return;
    }
    final id = _slug(result.name);
    fields[id] = TextEditingController();
    fieldDefs.add(
      MeasurementFieldDef(
        id: id,
        name: result.name,
        helpText: result.help.isEmpty ? null : result.help,
        custom: true,
      ),
    );
  }

  void removeField(MeasurementFieldDef def) {
    final removed = fields.remove(def.id);
    fieldDefs.removeWhere((f) => f.id == def.id);
    if (removed != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
    }
  }

  Future<void> save(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final templateId = templateIdForCategory();
    if (customerId.value == null ||
        templateId == null ||
        categoryId.value == null) {
      SsSnack.error(
        categoryId.value == null ? l.selectCategoryFirst : l.requiredField,
        title: l.measurements,
      );
      return;
    }
    saving.value = true;
    try {
      final values = <String, dynamic>{
        'category': categoryId.value,
        'categoryLabel': category?.label,
      };
      fields.forEach((k, c) {
        final v = c.text.trim();
        if (v.isNotEmpty) values[k] = num.tryParse(v) ?? v;
      });

      Map? template;
      for (final t in templates) {
        if (t is Map && '${t['id']}' == templateId) {
          template = t;
          break;
        }
      }
      final defs = template?['fields'];
      if (defs is List) {
        for (final f in defs) {
          if (f is! Map) continue;
          final id = '${f['id'] ?? ''}'.trim();
          if (id.isEmpty || values.containsKey(id)) continue;
          final aliases = _legacyAliases[id] ?? [id];
          for (final a in aliases) {
            if (values.containsKey(a)) {
              values[id] = values[a];
              break;
            }
          }
        }
      }

      final res = await api.dio.post('/measurements', data: {
        'customerId': customerId.value,
        'garmentTemplateId': templateId,
        'unit': unit.value,
        'values': values,
        if (notes.text.trim().isNotEmpty) 'notes': notes.text.trim(),
      });
      final measurementId = '${(res.data as Map?)?['id'] ?? ''}';
      if (orderId != null &&
          orderItemId != null &&
          measurementId.isNotEmpty) {
        await api.dio.post(
          '/orders/$orderId/items/$orderItemId/measurement',
          data: {'measurementRecordId': measurementId},
        );
      }
      Get.back(result: true);
    } on DioException catch (e) {
      SsSnack.fromError(e, title: l.measurements, context: Get.context);
    } finally {
      saving.value = false;
    }
  }

  IconData iconFor(MeasurementCategory cat) {
    if (cat.id.contains('pant')) return Icons.accessibility_new;
    if (cat.id.contains('polo') || cat.id.contains('tshirt')) {
      return Icons.checkroom_outlined;
    }
    return Icons.checkroom;
  }

  void debugFill() {
    if (customers.isNotEmpty && customerId.value == null) {
      customerId.value = '${(customers.first as Map)['id']}';
    }
    final targetCategory = categoryId.value ?? 'man_shirt';
    if (categoryId.value != targetCategory) {
      selectCategory(targetCategory);
    }
    for (final e in fields.entries) {
      e.value.text = _demoValues[e.key] ?? '12';
    }
    notes.text = 'Debug sample measurement';
    unit.value = 'INCH';
  }
}

/// Owns its own [TextEditingController]s so dispose happens with the route,
/// not via GetX delete while dependents are still attached.
class AddComponentDialog extends StatefulWidget {
  const AddComponentDialog({super.key});

  @override
  State<AddComponentDialog> createState() => _AddComponentDialogState();
}

class _AddComponentDialogState extends State<AddComponentDialog> {
  final _nameCtrl = TextEditingController();
  final _helpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _helpCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop((
      name: _nameCtrl.text.trim(),
      help: _helpCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.addComponent),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l.componentName,
                  hintText: l.componentNameHint,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l.requiredField : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: SsLayout.item),
              TextFormField(
                controller: _helpCtrl,
                decoration: InputDecoration(
                  labelText: l.helpTextOptional,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l.save),
        ),
      ],
    );
  }
}
