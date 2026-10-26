import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ss_feedback.dart';
import '../../auth/controllers/auth_controller.dart';

class CustomersController extends GetxController {
  final api = Get.find<ApiClient>();
  final auth = Get.find<AuthController>();
  final search = TextEditingController();

  final items = <dynamic>[].obs;
  final loading = true.obs;
  final showArchived = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    search.dispose();
    super.onClose();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      await auth.ensureShopContext();
      final res = await api.dio.get('/customers', queryParameters: {
        'search': search.text.trim().isEmpty ? null : search.text.trim(),
        'archived': showArchived.value ? 'true' : 'false',
        'pageSize': 50,
      });
      items.assignAll((res.data as Map)['items'] as List? ?? []);
    } catch (e) {
      error.value = ssErrorMessage(e);
    } finally {
      loading.value = false;
    }
  }

  void toggleArchived() {
    showArchived.value = !showArchived.value;
    load();
  }
}
