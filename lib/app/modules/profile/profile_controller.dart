import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/repositories/auth_repository.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';

import '../edit_profile_fieldmanager/edit_profile_controller.dart';

class CustomerProfileController extends GetxController {
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  // User data
  final name = ''.obs;
  final email = ''.obs;
  final avatarUrl = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // Reset all observable values
  void _resetData() {
    name.value = '';
    email.value = '';
    avatarUrl.value = '';
    isLoading.value = false;
  }

  // Load from API instead of localStorage only
  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      // Get userId from localStorage
      final userId = _localStorage.userId;

      if (userId == 0) {
        // Fallback to localStorage if no userId
        _loadFromLocalStorage();
        return;
      }

      // Fetch from API
      final response = await _authRepository.getUserById(userId: userId);

      if (response.success && response.user != null) {
        final user = response.user!;

        // Update observable values
        name.value = user.name;
        email.value = user.email;

        // Get photo_profil and convert to full URL
        if (user.photoProfil != null && user.photoProfil!.isNotEmpty) {
          avatarUrl.value = _apiClient.getImageUrl(user.photoProfil!);
        } else {
          avatarUrl.value = '';
        }

        // Update localStorage with fresh data
        await _localStorage.saveUserData(user.toJson());
      } else {
        // Fallback to localStorage
        _loadFromLocalStorage();
      }
    } catch (e) {
      // Fallback to localStorage on error
      _loadFromLocalStorage();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadFromLocalStorage() {
    if (_localStorage.getUserData() == null) {
      return;
    }

    try {
      final userData = _localStorage.getUserData();
      if (userData != null) {
        name.value = userData['name']?.toString() ?? 'Field Manager';
        email.value = userData['email']?.toString() ?? 'email@example.com';

        final photoProfil = userData['photo_profil']?.toString() ?? '';
        if (photoProfil.isNotEmpty) {
          avatarUrl.value = _apiClient.getImageUrl(photoProfil);
        } else {
          avatarUrl.value = '';
        }
      }
    } catch (e) {
      name.value = 'Field Manager';
      email.value = 'email@example.com';
      avatarUrl.value = '';
    }
  }

  void reloadUserData() {
    loadUserData();
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      // Clear local storage data
      await _localStorage.clearUserData();

      // Reset controller data
      _resetData();

      // Delete this controller instance
      Get.delete<CustomerProfileController>();

      // Also delete edit profile controller if exists
      if (Get.isRegistered<EditProfileFieldmanagerController>()) {
        Get.delete<EditProfileFieldmanagerController>();
      }

      // Navigate to login page
      Get.offAllNamed('/auth');

      Get.snackbar(
        'Success',
        'You have been logged out',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Clean up when controller is deleted
    _resetData();
    super.onClose();
  }
}
