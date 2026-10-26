import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../settings/views/settings_view.dart';

class AppIntroUiController extends GetxController {
  static const pageCount = 3;

  final pageController = PageController();
  final pageIndex = 0.obs;

  bool get isLast => pageIndex.value >= pageCount - 1;

  void onPageChanged(int i) => pageIndex.value = i;

  Future<void> finish() async {
    await Get.find<SettingsController>().setIntroSeen();
    Get.offAllNamed('/welcome');
  }

  void next() {
    if (isLast) {
      finish();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
