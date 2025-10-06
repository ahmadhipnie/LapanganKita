// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:lapangan_kita/app/data/models/user_model.dart';
// import 'package:lapangan_kita/app/data/repositories/auth_repository.dart';
// import 'package:lapangan_kita/app/data/services/session_service.dart';
// import 'package:lapangan_kita/app/routes/app_routes.dart';

// class LoginController extends GetxController {
//   LoginController({
//     required AuthRepository authRepository,
//     required SessionService sessionService,
//   }) : _authRepository = authRepository,
//        _sessionService = sessionService;

//   final AuthRepository _authRepository;
//   final SessionService _sessionService;

//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();

//   final rememberMe = false.obs;
//   final isPasswordVisible = false.obs;
//   final isLoading = false.obs;
//   final RxnString errorMessage = RxnString();
//   final Rxn<UserModel> currentUser = Rxn<UserModel>();

//   @override
//   void onInit() {
//     super.onInit();
//     rememberMe.value = _sessionService.isRemembered;
//   }

//   void resetForm() {
//     formKey.currentState?.reset();
//     emailController
//       ..text = ''
//       ..selection = const TextSelection.collapsed(offset: 0);
//     passwordController
//       ..text = ''
//       ..selection = const TextSelection.collapsed(offset: 0);
//     errorMessage.value = null;
//     isPasswordVisible.value = false;
//   }

//   @override
//   void onReady() {
//     super.onReady();
//     _attemptAutoLogin();
//   }

//   String? validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email is required';
//     }
//     final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+\u0000?');
//     if (!emailRegex.hasMatch(value)) {
//       return 'Enter a valid email';
//     }
//     return null;
//   }

//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 8) {
//       return 'Password must be at least 8 characters';
//     }
//     return null;
//   }

//   void togglePasswordVisibility() {
//     isPasswordVisible.value = !isPasswordVisible.value;
//   }

//   Future<void> submitLogin() async {
//     if (!(formKey.currentState?.validate() ?? false)) {
//       return;
//     }

//     FocusManager.instance.primaryFocus?.unfocus();
//     errorMessage.value = null;
//     isLoading.value = true;

//     final email = emailController.text.trim();
//     final password = passwordController.text;

//     try {
//       final response = await _authRepository.login(
//         email: email,
//         password: password,
//       );

//       if (!response.success || response.user == null) {
//         throw AuthException(
//           response.message.isNotEmpty ? response.message : 'Login failed.',
//         );
//       }

//       final user = response.user!;
//       if (user.isVerified != true) {
//         throw const AuthException(
//           'Akun belum diverifikasi. Silakan cek email Anda.',
//         );
//       }

//       currentUser.value = user;

//       if (rememberMe.value) {
//         await _sessionService.persistUser(user);
//       } else {
//         await _sessionService.clearRememberedUser();
//       }

//       Get.snackbar('Success', response.message);

//       final route = _resolveRoute(user.role);
//       await Get.offAllNamed(route, arguments: user);
//     } on AuthException catch (e) {
//       errorMessage.value = e.message;
//       Get.snackbar(
//         'Login Failed',
//         e.message,
//         backgroundColor: Colors.red.shade50,
//         colorText: Colors.red.shade900,
//       );
//     } catch (e) {
//       errorMessage.value = 'Unexpected error: $e';
//       Get.snackbar(
//         'Login Failed',
//         'Unexpected error: $e',
//         backgroundColor: Colors.red.shade50,
//         colorText: Colors.red.shade900,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   String _resolveRoute(String role) {
//     switch (role.toLowerCase()) {
//       case 'field_owner':
//       case 'field_manager':
//         return AppRoutes.FIELD_MANAGER_NAVIGATION;
//       case 'field_admin':
//         return AppRoutes.FIELD_ADMIN_NAVIGATION;
//       case 'user':
//         return AppRoutes.CUSTOMER_NAVIGATION;
//       default:
//         return AppRoutes.FIELD_MANAGER_NAVIGATION;
//     }
//   }

//   void _attemptAutoLogin() {
//     if (!_sessionService.isRemembered) return;

//     final remembered = _sessionService.rememberedUser;
//     if (remembered == null || remembered.isVerified != true) {
//       _sessionService.clearRememberedUser();
//       rememberMe.value = false;
//       return;
//     }

//     currentUser.value = remembered;
//     rememberMe.value = true;

//     Future.microtask(() {
//       final route = _resolveRoute(remembered.role);
//       Get.offAllNamed(route, arguments: remembered);
//     });
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/repositories/auth_repository.dart';
import 'package:lapangan_kita/app/routes/app_routes.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

class LoginController extends GetxController {
  LoginController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  final LocalStorageService _localStorage = LocalStorageService.instance;

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
          print('Error loading remembered credentials: $e');
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

      //        final user = response.user!;
      // if (user.isVerified != true) {
      //   throw const AuthException(
      //     'Akun belum diverifikasi. Silakan cek email Anda.',
      //   );
      // }
      // Save user data to local storage
      await _localStorage.saveUserData(response.user!.toJson());

      // Save remember me preference
      await _localStorage.setRememberMe(rememberMe.value);

      // Show success message
      Get.snackbar(
        'Success',
        response.message,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );

      // Navigate to appropriate dashboard based on role
      final route = _resolveRoute(response.user!.role);
      await Get.offAllNamed(route);
    } on AuthException catch (e) {
      // Handle authentication errors
      errorMessage.value = e.message;
      Get.snackbar(
        'Login Failed',
        e.message,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // Handle unexpected errors
      errorMessage.value = 'Unexpected error occurred';
      Get.snackbar(
        'Login Failed',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
      print('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Determine route based on user role
  String _resolveRoute(String role) {
    switch (role.toLowerCase()) {
      case 'field_owner':
        return AppRoutes.FIELD_MANAGER_NAVIGATION;
      case 'admin':
        return AppRoutes.FIELD_ADMIN_NAVIGATION;
      case 'user':
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

  /// Get form validity as observable
  RxBool get isFormValidObs {
    return RxBool(isFormValid);
  }

  // @override
  // void onClose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   super.onClose();
  // }
}
