import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/models/register_request.dart';
import 'package:lapangan_kita/app/data/repositories/auth_repository.dart';
import 'package:lapangan_kita/app/routes/app_routes.dart';

import '../../data/helper/error_helper.dart'; // ADD THIS

class FieldManagerRegisterController extends GetxController {
  FieldManagerRegisterController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  final ErrorHandler _errorHandler = ErrorHandler(); // ADD THIS

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController(); // ADD THIS
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
  final RxString errorMessage = ''.obs;

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

  // ADD THIS - Phone validation
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number must contain only digits';
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
    phoneController.dispose(); // ADD THIS
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
      _errorHandler.showErrorMessage('Registration form not valid!');
      return;
    }

    if (gender.value.isEmpty) {
      _errorHandler.showErrorMessage('Please select a gender.');
      return;
    }

    if (bank.value.isEmpty) {
      _errorHandler.showErrorMessage('Please select a bank.');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    errorMessage.value = '';
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
      nomorTelepon: phoneController.text.trim(), // ADD THIS
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

      _errorHandler.showSuccessMessage(response.message);

      if (response.note != null && response.note!.isNotEmpty) {
        _errorHandler.showInfoMessage(response.note!);
      }

      if (response.emailSent == true) {
        await Get.toNamed(
          AppRoutes.OTP,
          arguments: {'email': request.email, 'role': request.role},
        );
      } else {
        await Get.offAllNamed(AppRoutes.PLACE_FORM);
      }
    } catch (e) {
      _errorHandler.handleGeneralError(
        context: 'Field Manager Registration',
        error: e,
        errorMessage: errorMessage,
        showSnackbar: true,
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
    phoneController.clear(); // ADD THIS
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
