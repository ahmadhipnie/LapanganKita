import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/repositories/auth_repository.dart';
import 'package:lapangan_kita/app/routes/app_routes.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

import '../../data/helper/error_helper.dart'; // Add this

class LoginController extends GetxController {
  LoginController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final ErrorHandler _errorHandler = ErrorHandler(); // Add this

  // Form Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Observable Variables
  final rememberMe = false.obs;
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    _loadRememberedCredentials();
    super.onInit();
  }

  /// Load remembered email if remember me is enabled
  void _loadRememberedCredentials() {
    if (_localStorage.rememberMe) {
      final userData = _localStorage.getUserData();
      if (userData != null) {
        try {
          emailController.text = userData['email']?.toString() ?? '';
          rememberMe.value = true;
        } catch (e) {
          // Silent fail
        }
      }
    }
  }

  /// Email validation
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

  /// Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle remember me
  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  /// Main login function
  Future<void> submitLogin() async {
    // Validate form
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    // Reset error message
    errorMessage.value = null;
    isLoading.value = true;

    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      // Call API login
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      // Check if login successful
      if (!response.success || response.user == null) {
        throw AuthException(
          response.message.isNotEmpty ? response.message : 'Login failed.',
        );
      }

      // Save user data to local storage
      await _localStorage.saveUserData(response.user!.toJson());

      // Save remember me preference
      await _localStorage.setRememberMe(rememberMe.value);

      // Show success message using ErrorHandler
      _errorHandler.showSuccessMessage(
        response.message.isNotEmpty ? response.message : 'Login successful',
      );

      // Navigate to appropriate dashboard based on role
      final route = _resolveRoute(response.user!.role);
      await Get.offAllNamed(route);
    } on AuthException catch (e) {
      // Get user-friendly error message and translate
      final friendlyError = _errorHandler.translateMessage(e.message);
      errorMessage.value = friendlyError;

      // Show error using ErrorHandler (no snackbar, just set errorMessage)
      // Don't show snackbar because we have the error box in UI
    } catch (e) {
      // Handle unexpected errors with ErrorHandler
      final friendlyError = _errorHandler.getSimpleErrorMessage(e);
      errorMessage.value = friendlyError;
    } finally {
      isLoading.value = false;
    }
  }

  /// Determine route based on user role
  String _resolveRoute(String role) {
    switch (role.toLowerCase()) {
      case 'field_owner':
      case 'field_manager':
        return AppRoutes.FIELD_MANAGER_NAVIGATION;
      case 'field_admin':
      case 'admin':
        return AppRoutes.FIELD_ADMIN_NAVIGATION;
      case 'user':
      case 'customer':
        return AppRoutes.CUSTOMER_NAVIGATION;
      default:
        return AppRoutes.LOGIN; // Fallback to login if role not recognized
    }
  }

  /// Clear form fields
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    errorMessage.value = null;
    isPasswordVisible.value = false;
    formKey.currentState?.reset();
  }

  /// Check if form is valid and ready for submission
  bool get isFormValid {
    return emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        validateEmail(emailController.text) == null &&
        validatePassword(passwordController.text) == null;
  }

  // @override
  // void onClose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   super.onClose();
  // }
}
