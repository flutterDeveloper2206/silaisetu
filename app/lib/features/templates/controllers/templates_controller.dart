import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ss_feedback.dart';

class TemplatesController extends GetxController {
  final api = Get.find<ApiClient>();

  final items = <dynamic>[].obs;
  final loading = true.obs;
  final error = RxnString();

  /// Add-template dialog fields (created per open, disposed after).
  TextEditingController? addName;
  TextEditingController? addCode;
  final addFormKey = GlobalKey<FormState>();
  final codeEdited = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    disposeAddDialog();
    super.onClose();
  }

  void prepareAddDialog() {
    disposeAddDialog();
    addName = TextEditingController();
    addCode = TextEditingController();
    codeEdited.value = false;
  }

  void disposeAddDialog() {
    addName?.dispose();
    addCode?.dispose();
    addName = null;
    addCode = null;
  }

  void onAddNameChanged(String v) {
    if (!codeEdited.value) {
      addCode?.text = slugCode(v);
    }
  }

  void markCodeEdited() => codeEdited.value = true;

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await api.dio.get('/garment-templates', queryParameters: {
        'all': 'true',
      });
      items.assignAll(res.data is List
          ? res.data as List
          : ((res.data as Map?)?['items'] as List? ?? []));
      loading.value = false;
    } catch (e) {
      error.value = ssErrorMessage(e);
      loading.value = false;
    }
  }

  List<Map<String, dynamic>> starterFields(String codeHint) {
    final c = codeHint.toLowerCase();
    Map<String, String> defs;
    if (c.contains('trouser') || c.contains('pant') || c.contains('bottom')) {
      defs = {
        'waist': 'Waist',
        'hip': 'Hip',
        'length': 'Length',
        'inseam': 'Inseam',
        'thigh': 'Thigh',
        'knee': 'Knee',
        'bottom': 'Bottom / Hem',
      };
    } else if (c.contains('blouse') ||
        c.contains('kurti') ||
        c.contains('kurta')) {
      defs = {
        'bust': 'Bust',
        'waist': 'Waist',
        'hip': 'Hip',
        'shoulder': 'Shoulder',
        'sleeve': 'Sleeve',
        'length': 'Length',
        'neck': 'Neck',
      };
    } else {
      defs = {
        'chest': 'Chest',
        'shoulder': 'Shoulder',
        'sleeve': 'Sleeve',
        'length': 'Length',
        'neck': 'Neck / Collar',
        'waist': 'Waist',
      };
    }
    var i = 0;
    return defs.entries
        .map(
          (e) => {
            'id': e.key,
            'name': e.value,
            'type': 'number',
            'unit': 'inch',
            'required': i++ < 3,
            'order': i,
          },
        )
        .toList();
  }

  String slugCode(String name) => name
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  Future<void> create({
    required String name,
    required String code,
    required BuildContext context,
  }) async {
    final l = AppLocalizations.of(context)!;
    try {
      await api.dio.post('/garment-templates', data: {
        'name': name,
        'code': code,
        'fields': starterFields(code),
      });
      await load();
      if (!context.mounted) return;
      SsSnack.success(
        l.templateCreated,
        title: l.garmentTemplates,
        context: context,
      );
    } on DioException catch (e) {
      if (!context.mounted) return;
      final data = e.response?.data;
      final codeStr = data is Map ? '${data['code']}' : '';
      final raw = '${data ?? ''}'.toLowerCase();
      final msg = codeStr == 'TEMPLATE_CODE_EXISTS' ||
              raw.contains('already exists') ||
              raw.contains('unique')
          ? l.templateExists
          : ssErrorMessage(e, fallback: l.somethingWentWrong);
      SsSnack.error(msg, title: l.garmentTemplates, context: context);
    } catch (e) {
      if (!context.mounted) return;
      SsSnack.error(
        ssErrorMessage(e, fallback: l.somethingWentWrong),
        title: l.garmentTemplates,
        context: context,
      );
    }
  }
}
