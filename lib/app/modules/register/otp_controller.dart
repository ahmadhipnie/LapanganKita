import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OTPController extends GetxController {
  // State variables
  var isLoading = false.obs;
  var otpCodes = List<String?>.filled(4, null).obs;
  var phoneNumber = '*********124'.obs;

  // Text controllers untuk setiap field
  final List<TextEditingController> textControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  // Handle OTP input change dengan auto focus yang smooth
  void onOTPChanged(int index, String value, BuildContext context) {
    final oldValue = otpCodes[index];
    otpCodes[index] = value.isNotEmpty ? value : null;

    if (value.isNotEmpty && value.length == 1) {
      // User mengetik karakter baru - pindah ke next field
      if (index < 3) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).nextFocus();
          // Auto select text di next field untuk overwrite mudah
          textControllers[index + 1].selection = TextSelection(
            baseOffset: 0,
            extentOffset: textControllers[index + 1].text.length,
          );
        });
      } else if (index == 3) {
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
  String get completeOTP => otpCodes.where((code) => code != null).join();

  // Validate OTP
  bool get isOTPComplete =>
      otpCodes.every((code) => code != null && code.isNotEmpty);

  // Verify OTP
  Future<void> verifyOTP() async {
    if (!isOTPComplete) {
      Get.snackbar('Error', 'Please enter complete verification code');
      return;
    }

    isLoading.value = true;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual OTP verification API call
      // print('OTP Verified: $completeOTP');

      Get.offAllNamed('/container-login');
    } catch (e) {
      Get.snackbar('Error', 'Verification failed: $e');
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

      Get.snackbar('Success', 'Verification code sent successfully');

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
    otpCodes.assignAll(List<String?>.filled(4, null));

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
