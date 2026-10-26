import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeShellController extends GetxController {
  final tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    Get.find<AuthController>().ensureShopContext();
  }

  void selectTab(int i) => tabIndex.value = i;
}
