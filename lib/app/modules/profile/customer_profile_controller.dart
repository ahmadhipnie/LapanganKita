import 'package:get/get.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

class CustomerProfileController extends GetxController {
  final LocalStorageService _localStorage = LocalStorageService();

  RxBool faceIdEnabled = false.obs;

  // User data from shared preferences
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString avatarUrl = ''.obs;

  @override
  void onInit() {
    _loadUserData();
    super.onInit();
  }

  void _loadUserData() {
    final userData = _localStorage.getUserData();
    if (userData != null) {
      try {
        name.value = userData['name']?.toString() ?? '';
        email.value = userData['email']?.toString() ?? '';

        // You can set avatar URL if available in your API
        avatarUrl.value = userData['avatar_url']?.toString() ?? '';
      } catch (e) {
        // Fallback to default values
        name.value = 'User';
        email.value = 'user@example.com';
      }
    } else {
      // If no user data found, set default values
      name.value = 'User';
      email.value = 'user@example.com';
    }
  }

  void toggleFaceId(bool value) {
    faceIdEnabled.value = value;
  }

  // Logout function
  Future<void> logout() async {
    await _localStorage.clearUserData();
    Get.offAllNamed('/login');
  }
}
