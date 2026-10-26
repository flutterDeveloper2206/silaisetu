import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class ForgotPasswordUiController extends GetxController {
  final identifier = TextEditingController();
  final message = RxnString();
  final devToken = RxnString();

  Future<void> submit(String resetSentLabel) async {
    final auth = Get.find<AuthController>();
    final res = await auth.forgotPassword(identifier.text);
    if (res != null) {
      message.value = resetSentLabel;
      devToken.value = res['devHint']?['token'] as String?;
    }
  }

  @override
  void onClose() {
    identifier.dispose();
    super.onClose();
  }
}

class ResetPasswordUiController extends GetxController {
  late final token = TextEditingController(
    text: (Get.arguments as String?) ?? '',
  );
  final password = TextEditingController();
  final confirm = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    token.dispose();
    password.dispose();
    confirm.dispose();
    super.onClose();
  }
}

class ForgotIdentifierUiController extends GetxController {
  final contact = TextEditingController();

  @override
  void onClose() {
    contact.dispose();
    super.onClose();
  }
}

class VerifyUiController extends GetxController {
  final code = TextEditingController();
  final devCode = RxnString();
  final auth = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    request();
  }

  Future<void> request() async {
    final res = await auth.requestVerify();
    if (res != null) {
      devCode.value = res['devHint']?['code'] as String?;
    }
  }

  @override
  void onClose() {
    code.dispose();
    super.onClose();
  }
}
