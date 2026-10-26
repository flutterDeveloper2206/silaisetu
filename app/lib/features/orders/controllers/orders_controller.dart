import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../auth/controllers/auth_controller.dart';

class OrdersController extends GetxController {
  final api = Get.find<ApiClient>();
  final auth = Get.find<AuthController>();

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
      await auth.ensureShopContext();
      final res = await api.dio.get('/orders');
      items.assignAll((res.data as Map)['items'] as List? ?? []);
      loading.value = false;
    } catch (_) {
      error.value = 'error';
      loading.value = false;
    }
  }
}
