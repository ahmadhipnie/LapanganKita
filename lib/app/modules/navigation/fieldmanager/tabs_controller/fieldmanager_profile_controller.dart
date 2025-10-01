import 'package:get/get.dart';

import 'package:lapangan_kita/app/data/services/session_service.dart';
import 'package:lapangan_kita/app/modules/login/login_controller.dart';
import 'package:lapangan_kita/app/routes/app_routes.dart';

class FieldManagerProfileController extends GetxController {
  FieldManagerProfileController({SessionService? sessionService})
    : _sessionService = sessionService ?? Get.find<SessionService>();

  final SessionService _sessionService;
  RxBool faceIdEnabled = false.obs;
  // Dummy user data
  final RxString name = 'Budi sakti'.obs;
  final RxString email = 'budi@gmail.com'.obs;
  final RxString avatarUrl = ''.obs;

  void toggleFaceId(bool value) {
    faceIdEnabled.value = value;
  }

  // Add more profile logic here as needed

  Future<void> logout() async {
    await _sessionService.clearRememberedUser();
    if (Get.isRegistered<LoginController>()) {
      Get.find<LoginController>().resetForm();
    }
    await Get.offAllNamed(AppRoutes.LOGIN);
  }
}
