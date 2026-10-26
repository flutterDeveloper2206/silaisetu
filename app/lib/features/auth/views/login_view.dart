import 'package:flutter/material.dart';
import 'sign_in_view.dart';

/// Legacy alias — `/login` routes to [SignInView] in main.dart as well.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) => const SignInView();
}
