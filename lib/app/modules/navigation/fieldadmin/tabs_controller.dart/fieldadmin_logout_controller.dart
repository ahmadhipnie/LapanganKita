import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/routes/app_routes.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

class FieldadminLogoutController extends GetxController {
  final LocalStorageService _localStorage = LocalStorageService.instance;

  final RxBool isLoggingOut = false.obs;

  void confirmLogout() {
    if (isLoggingOut.value) return;

    Get.defaultDialog(
      title: 'Keluar Aplikasi',
      middleText: 'Apakah Anda yakin ingin keluar dari akun admin lapangan?',
      textCancel: 'Batal',
      textConfirm: 'Logout',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        logout();
      },
    );
  }

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      await _localStorage.logout();
      Get.offAllNamed(AppRoutes.LOGIN);
      Get.snackbar(
        'Success',
        'You have logged out of your account.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Failed',
        'Unable to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoggingOut.value = false;
    }
  }
}
