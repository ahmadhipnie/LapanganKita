import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lapangan_kita/app/data/models/user_model.dart';
import 'package:lapangan_kita/app/data/repositories/auth_repository.dart';
// import 'package:lapangan_kita/app/modules/login/login_controller.dart';
import 'package:lapangan_kita/app/routes/app_routes.dart';

class OTPController extends GetxController {
  OTPController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  static const int _otpLength = 6;

  final isLoading = false.obs;
  final otpCodes = List<String?>.filled(_otpLength, null).obs;
  final email = ''.obs;
  final role = ''.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<UserModel> verifiedUser = Rxn<UserModel>();

  // Text controllers untuk setiap field
  final List<TextEditingController> textControllers = List.generate(
    _otpLength,
    (index) => TextEditingController(),
  );

  // Handle OTP input change dengan auto focus yang smooth
  void onOTPChanged(int index, String value, BuildContext context) {
    final oldValue = otpCodes[index];
    otpCodes[index] = value.isNotEmpty ? value : null;

    if (value.isNotEmpty && value.length == 1) {
      // User mengetik karakter baru - pindah ke next field
      if (index < _otpLength - 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).nextFocus();
          // Auto select text di next field untuk overwrite mudah
          textControllers[index + 1].selection = TextSelection(
            baseOffset: 0,
            extentOffset: textControllers[index + 1].text.length,
          );
        });
      } else if (index == _otpLength - 1) {
        // Jika di field terakhir, unfocus
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).unfocus();
        });
      }
    } else if (value.isEmpty && oldValue != null) {
      // User menghapus karakter - pindah ke previous field
      if (index > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).previousFocus();
          // Auto select text di previous field
          textControllers[index - 1].selection = TextSelection(
            baseOffset: 0,
            extentOffset: textControllers[index - 1].text.length,
          );
        });
      }
    }
  }

  // Get complete OTP
  String get completeOTP => otpCodes.map((code) => code ?? '').join();

  // Validate OTP
  bool get isOTPComplete =>
      otpCodes.every((code) => code != null && code.isNotEmpty);

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }

  void _loadArguments() {
    final args = Get.arguments;
    if (args is Map) {
      final emailArg = args['email']?.toString() ?? '';
      final roleArg = args['role']?.toString() ?? '';
      if (emailArg.isNotEmpty) {
        email.value = emailArg;
      }
      if (roleArg.isNotEmpty) {
        role.value = roleArg;
      }
    } else if (args is String && args.isNotEmpty) {
      email.value = args;
    }
  }

  // Verify OTP
  Future<void> verifyOTP() async {
    if (!isOTPComplete) {
      Get.snackbar('Error', 'Please enter complete verification code');
      return;
    }

    if (email.value.isEmpty) {
      Get.snackbar('Error', 'Missing email reference for verification');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final response = await _authRepository.verifyOtp(
        email: email.value,
        otp: completeOTP,
      );

      if (!response.success) {
        throw AuthException(
          response.message.isNotEmpty
              ? response.message
              : 'OTP verification failed.',
        );
      }

      Get.snackbar(
        'Verification Success',
        response.message.isNotEmpty
            ? response.message
            : 'Your account has been verified.',
      );

      verifiedUser.value = response.user;
      clearAllFields();

      // if (Get.isRegistered<LoginController>()) {
      //   Get.find<LoginController>().resetForm();
      // }

      await Get.offAllNamed(AppRoutes.AUTH);
    } catch (e) {
      final message = e is AuthException
          ? e.message
          : 'Verification failed: $e';
      errorMessage.value = message;
      Get.snackbar(
        'Verification Failed',
        message,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    // isLoading.value = true;

    try {
      // TODO: Implement resend OTP API call
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar('Success', 'Verification code sent to your email');

      // Clear existing OTP
      clearAllFields();
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend code: $e');
    }
    // finally {
    //   isLoading.value = false;
    // }
  }

  // Clear semua fields
  void clearAllFields() {
    for (var controller in textControllers) {
      controller.clear();
    }
    otpCodes.assignAll(List<String?>.filled(_otpLength, null));

    // Set focus ke field pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(Get.context!).requestFocus(FocusNode());
      if (textControllers.isNotEmpty) {
        textControllers[0].selection = TextSelection(
          baseOffset: 0,
          extentOffset: 0,
        );
      }
    });
  }

  @override
  void onClose() {
    // Dispose text controllers
    for (var controller in textControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
