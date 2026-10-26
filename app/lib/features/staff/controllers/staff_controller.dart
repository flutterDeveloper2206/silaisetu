import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ss_feedback.dart';

class StaffController extends GetxController {
  final api = Get.find<ApiClient>();
  final items = <dynamic>[].obs;
  final loading = true.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await api.dio.get('/staff');
      items.assignAll(
        res.data is List
            ? res.data as List
            : ((res.data as Map?)?['items'] as List? ?? []),
      );
      loading.value = false;
    } catch (e) {
      error.value = '$e';
      loading.value = false;
    }
  }

  Future<void> invite() async {
    final l = AppLocalizations.of(Get.context!)!;
    final name = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final password = TextEditingController(text: 'StaffPass1!');
    var role = 'TAILOR';
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l.addStaff),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: InputDecoration(labelText: l.fullName)),
              TextField(controller: email, decoration: InputDecoration(labelText: l.email)),
              TextField(controller: phone, decoration: InputDecoration(labelText: l.phone)),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(labelText: l.password),
              ),
              DropdownButtonFormField<String>(
                value: role,
                items: const [
                  DropdownMenuItem(value: 'MANAGER', child: Text('MANAGER')),
                  DropdownMenuItem(value: 'TAILOR', child: Text('TAILOR')),
                ],
                onChanged: (v) => role = v ?? 'TAILOR',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Get.back(result: true), child: Text(l.save)),
        ],
      ),
    );
    if (ok != true) {
      name.dispose();
      email.dispose();
      phone.dispose();
      password.dispose();
      return;
    }
    try {
      await api.dio.post('/staff', data: {
        'fullName': name.text.trim(),
        'email': email.text.trim(),
        'password': password.text,
        'role': role,
        if (phone.text.trim().isNotEmpty) 'phone': phone.text.trim(),
      });
      await load();
    } on DioException catch (e) {
      SsSnack.fromError(e, title: l.staff);
    } finally {
      name.dispose();
      email.dispose();
      phone.dispose();
      password.dispose();
    }
  }

  Future<void> deactivate(String id) async {
    await api.dio.post('/staff/$id/deactivate');
    load();
  }
}
