import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInUiController extends GetxController {
  final identifier = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final obscurePassword = true.obs;

  void toggleObscure() => obscurePassword.toggle();

  void debugFill() {
    identifier.text = 'debug@silaisetu.test';
    password.text = 'Debug@1234';
    obscurePassword.value = false;
  }

  @override
  void onClose() {
    identifier.dispose();
    password.dispose();
    super.onClose();
  }
}
