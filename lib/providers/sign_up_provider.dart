import 'package:flutter/cupertino.dart';

class SignUpProvider extends ChangeNotifier {

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController signUpEmailController = TextEditingController();
  final TextEditingController signUpPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  String? selectedGender;
  DateTime? selectedDob;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  /// ---------------- VALIDATIONS ----------------

  String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return "Select gender";
    }
    return null;
  }

  String? validateDob(String? value) {
    if (value == null || value.isEmpty) {
      return "Select DOB";
    }
    return null;
  }

  void setGender(String? value) {
    selectedGender = value;
    notifyListeners();
  }

  void setDob(DateTime date) {
    selectedDob = date;
    dobController.text = "${date.day}/${date.month}/${date.year}";
    notifyListeners();
  }

  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "First name is required";
    }

    if (value.trim().length < 2) {
      return "Minimum 2 characters required";
    }

    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
      return "Only alphabets allowed";
    }

    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Last name is required";
    }

    if (value.trim().length < 2) {
      return "Minimum 2 characters required";
    }

    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
      return "Only alphabets allowed";
    }

    return null;
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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Confirm password is required";
    }

    if (value != signUpPasswordController.text) {
      return "Passwords do not match";
    }

    return null;
  }

  void clearSignUpFields({BuildContext? context}) {
    firstNameController.clear();
    lastNameController.clear();
    signUpEmailController.clear();
    signUpPasswordController.clear();
    confirmPasswordController.clear();
    dobController.clear();
    isPasswordVisible = false;
    isConfirmPasswordVisible = false;
    selectedGender = null;
    selectedDob = null;
    if (context != null) {
      FocusScope.of(context).unfocus();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    super.dispose();
  }
}