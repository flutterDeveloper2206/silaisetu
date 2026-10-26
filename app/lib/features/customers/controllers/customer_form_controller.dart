import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ss_feedback.dart';

class CustomerFormController extends GetxController {
  CustomerFormController({this.id});

  final String? id;
  final api = Get.find<ApiClient>();

  final name = TextEditingController();
  final phone = TextEditingController();
  final alt = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final notes = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final loading = false.obs;
  final fetching = false.obs;

  bool get isNew => id == null;

  @override
  void onInit() {
    super.onInit();
    if (id != null) fetch();
  }

  @override
  void onClose() {
    name.dispose();
    phone.dispose();
    alt.dispose();
    email.dispose();
    address.dispose();
    notes.dispose();
    super.onClose();
  }

  Future<void> fetch() async {
    fetching.value = true;
    try {
      final res = await api.dio.get('/customers/$id');
      final c = res.data as Map;
      name.text = '${c['fullName'] ?? ''}';
      phone.text = '${c['phone'] ?? ''}';
      alt.text = '${c['altPhone'] ?? ''}';
      email.text = '${c['email'] ?? ''}';
      address.text = '${c['address'] ?? ''}';
      notes.text = '${c['notes'] ?? ''}';
    } finally {
      fetching.value = false;
    }
  }

  void debugFill() {
    name.text = 'Ramesh Patel';
    phone.text = '9876501234';
    alt.text = '9123456789';
    email.text = 'ramesh.patel@example.com';
    address.text = '12, Relief Road, Ahmedabad, Gujarat';
    notes.text = 'Prefers morning fittings';
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final ctx = Get.context;
    final l = ctx != null ? AppLocalizations.of(ctx)! : null;
    loading.value = true;
    final data = {
      'fullName': name.text.trim(),
      'phone': phone.text.trim(),
      if (alt.text.trim().isNotEmpty) 'altPhone': alt.text.trim(),
      if (email.text.trim().isNotEmpty) 'email': email.text.trim(),
      if (address.text.trim().isNotEmpty) 'address': address.text.trim(),
      if (notes.text.trim().isNotEmpty) 'notes': notes.text.trim(),
    };
    try {
      if (id == null) {
        final res = await api.dio.post('/customers', data: data);
        final newId = '${res.data['id']}';
        final goOrder = await Get.dialog<bool>(
          AlertDialog(
            title: Text(l?.customerAdded ?? 'Customer added'),
            content: Text(
              l?.customerAddedOrderPrompt ?? 'Create an order now?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(l?.later ?? 'Later'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: Text(l?.newOrder ?? 'New order'),
              ),
            ],
          ),
        );
        if (goOrder == true) {
          Get.offNamed('/orders/new', arguments: {'customerId': newId});
        } else {
          Get.offNamed('/customers/$newId');
        }
      } else {
        await api.dio.patch('/customers/$id', data: data);
        Get.back();
      }
    } on DioException catch (e) {
      SsSnack.fromError(
        e,
        title: l?.errorGeneric ?? 'Error',
        context: Get.context,
      );
    } finally {
      loading.value = false;
    }
  }
}
