import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/repositories/auth_repository.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final RxBool isLoading = false.obs;
  final Rxn<String> errorMessage = Rxn<String>();
  final Rxn<String> successMessage = Rxn<String>();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> submitForgotPassword() async {
    // Clear previous messages
    errorMessage.value = null;
    successMessage.value = null;

    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final response = await _authRepository.forgotPassword(
        email: emailController.text.trim(),
      );

      if (response['success'] == true) {
        successMessage.value = response['message'] ??
            'New password has been sent to your email. Please check your inbox.';

        // Show success snackbar
        Get.snackbar(
          'Success',
          response['message'] ?? 'Password reset email sent successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check_circle, color: Colors.green),
          margin: const EdgeInsets.all(16),
        );

        // Wait a bit then navigate back to login
        await Future.delayed(const Duration(seconds: 2));
        Get.back(); // Go back to auth/login page
      } else {
        errorMessage.value =
            response['message'] ?? 'Failed to send reset password email';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again later.';
      
      // Show error snackbar
      Get.snackbar(
        'Error',
        errorMessage.value!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.red),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
