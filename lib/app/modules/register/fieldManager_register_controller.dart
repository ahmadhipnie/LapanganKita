import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lapangan_kita/app/data/models/register_request.dart';
import 'package:lapangan_kita/app/data/repositories/auth_repository.dart';
import 'package:lapangan_kita/app/routes/app_routes.dart';

class FieldManagerRegisterController extends GetxController {
  FieldManagerRegisterController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final dobController = TextEditingController();
  final accountNumberController = TextEditingController();

  final isPasswordVisible = false.obs;
  final gender = ''.obs;
  final bank = ''.obs;
  final isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final bankList = [
    'BCA',
    'BNI',
    'BRI',
    'Mandiri',
    'CIMB',
    'Danamon',
    'Permata',
    'BTN',
    'Other',
  ];

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    streetController.dispose();
    cityController.dispose();
    provinceController.dispose();
    dobController.dispose();
    accountNumberController.dispose();
    super.onClose();
  }

  Future<void> submitRegistration() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      Get.snackbar('Error', 'Registration form not valid!');
      return;
    }
    if (gender.value.isEmpty) {
      Get.snackbar('Error', 'Please select a gender.');
      return;
    }
    if (bank.value.isEmpty) {
      Get.snackbar('Error', 'Please select a bank.');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    errorMessage.value = null;
    isLoading.value = true;

    final request = RegisterRequest(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      gender: gender.value,
      address: _composeAddress(),
      dateOfBirth: dobController.text.trim(),
      accountNumber: accountNumberController.text.trim(),
      bankType: bank.value,
      role: 'field_owner',
    );

    try {
      final response = await _authRepository.register(request: request);

      if (!response.success) {
        throw AuthException(
          response.message.isNotEmpty
              ? response.message
              : 'Registration failed.',
        );
      }

      _resetForm();

      Get.snackbar('Success', response.message);
      if (response.note != null && response.note!.isNotEmpty) {
        Get.snackbar('Info', response.note!);
      }

      if (response.emailSent == true) {
        await Get.toNamed(
          AppRoutes.OTP,
          arguments: {'email': request.email, 'role': request.role},
        );
      } else {
        await Get.offAllNamed(AppRoutes.PLACE_FORM);
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Registration Failed',
        e.message,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar(
        'Registration Failed',
        'Unexpected error: $e',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _composeAddress() {
    final parts = [
      streetController.text.trim(),
      cityController.text.trim(),
      provinceController.text.trim(),
    ]..removeWhere((element) => element.isEmpty);
    return parts.join(', ');
  }

  void _resetForm() {
    formKey.currentState?.reset();
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    streetController.clear();
    cityController.clear();
    provinceController.clear();
    dobController.clear();
    accountNumberController.clear();
    gender.value = '';
    bank.value = '';
    isPasswordVisible.value = false;
  }
}
