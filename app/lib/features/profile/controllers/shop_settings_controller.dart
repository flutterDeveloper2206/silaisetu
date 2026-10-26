import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silaisetu/core/localization/l10n/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../auth/controllers/auth_controller.dart';

class ShopSettingsController extends GetxController {
  final api = Get.find<ApiClient>();
  final auth = Get.find<AuthController>();

  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final city = TextEditingController();
  final address = TextEditingController();

  final shopId = RxnString();
  final loading = true.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    city.dispose();
    address.dispose();
    super.onClose();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final memberships = auth.memberships;
      if (memberships.isEmpty) {
        loading.value = false;
        error.value = 'no-shop';
        return;
      }
      shopId.value = memberships.first['shop']?['id'] as String?;
      if (shopId.value == null) throw Exception('missing shop');
      await api.setShopId(shopId.value!);
      final res = await api.dio.get('/shops/${shopId.value}');
      final s = res.data as Map<String, dynamic>;
      name.text = '${s['name'] ?? ''}';
      phone.text = '${s['phone'] ?? ''}';
      email.text = '${s['email'] ?? ''}';
      city.text = '${s['city'] ?? ''}';
      address.text = '${s['address'] ?? s['addressLine1'] ?? ''}';
      loading.value = false;
    } catch (_) {
      loading.value = false;
      error.value = 'error';
    }
  }

  Future<void> save() async {
    if (shopId.value == null) return;
    final ctx = Get.context;
    final l = ctx != null ? AppLocalizations.of(ctx)! : null;
    loading.value = true;
    try {
      await api.dio.patch('/shops/${shopId.value}', data: {
        'name': name.text.trim(),
        'phone': phone.text.trim(),
        'email': email.text.trim().isEmpty ? null : email.text.trim(),
        'city': city.text.trim(),
        'address': address.text.trim(),
      });
      await auth.hydrate();
      Get.snackbar(l?.shopSettings ?? 'Shop settings', l?.save ?? 'Saved');
    } catch (_) {
      error.value = 'error';
    } finally {
      loading.value = false;
    }
  }
}
