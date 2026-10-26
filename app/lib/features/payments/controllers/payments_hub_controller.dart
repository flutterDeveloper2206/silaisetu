import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/ss_feedback.dart';

class PaymentsHubController extends GetxController {
  final api = Get.find<ApiClient>();
  final orders = <dynamic>[].obs;
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
      final res = await api.dio.get('/orders', queryParameters: {'pageSize': 50});
      final list = (res.data as Map)['items'] as List? ?? [];
      orders.assignAll(list.where((o) {
        final bal = num.tryParse('${(o as Map)['balanceDue']}') ?? 0;
        return bal > 0 && o['status'] != 'CANCELLED';
      }));
      loading.value = false;
    } catch (e) {
      error.value = ssErrorMessage(e);
      loading.value = false;
    }
  }
}
