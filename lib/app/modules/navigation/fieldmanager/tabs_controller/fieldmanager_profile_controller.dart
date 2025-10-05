import 'package:get/get.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

class FieldManagerProfileController extends GetxController {
  final LocalStorageService _localStorage = LocalStorageService.instance;

  // User data
  final name = ''.obs;
  final email = ''.obs;
  final avatarUrl = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    // Safe check: pastikan LocalStorageService sudah terinisialisasi
    if (_localStorage.getUserData() == null) {
      print('No user data found in LocalStorage');
      return;
    }

    try {
      final userData = _localStorage.getUserData();
      if (userData != null) {
        name.value = userData['name']?.toString() ?? 'Field Manager';
        email.value = userData['email']?.toString() ?? 'email@example.com';
        avatarUrl.value = userData['avatar_url']?.toString() ?? '';
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Set default values if error occurs
      name.value = 'Field Manager';
      email.value = 'email@example.com';
      avatarUrl.value = '';
    }
  }

  void reloadUserData() {
    _loadUserData();
  }

  Future<void> logout() async {
    isLoading.value = true;

    try {
      // Clear local storage data
      await _localStorage.clearUserData();

      // Navigate to login page
      Get.offAllNamed('/login');

      Get.snackbar(
        'Success',
        'You have been logged out',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error during logout: $e');
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
