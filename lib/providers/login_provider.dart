import 'package:flutter/cupertino.dart';

class LoginProvider extends ChangeNotifier{
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email";
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  void clearFields() {
    loginEmailController.clear();
    passwordController.clear();
    isPasswordVisible = false;

    notifyListeners();
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}