import 'package:get/get.dart';
import '../../../core/network/api_client.dart';

class MeasurementsListController extends GetxController {
  final api = Get.find<ApiClient>();

  final customers = <dynamic>[].obs;
  final customerId = RxnString();
  final items = <dynamic>[].obs;
  final loading = true.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    bootstrap();
  }

  Future<void> bootstrap() async {
    try {
      final res =
          await api.dio.get('/customers', queryParameters: {'pageSize': 100});
      customers.assignAll((res.data as Map)['items'] as List? ?? []);
      if (customers.isNotEmpty) {
        customerId.value = '${(customers.first as Map)['id']}';
        await load();
      } else {
        loading.value = false;
      }
    } catch (e) {
      error.value = '$e';
      loading.value = false;
    }
  }

  Future<void> load() async {
    if (customerId.value == null) return;
    loading.value = true;
    error.value = null;
    try {
      final res = await api.dio.get('/measurements', queryParameters: {
        'customerId': customerId.value,
      });
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

  void onCustomerChanged(String? v) {
    customerId.value = v;
    load();
  }
}
