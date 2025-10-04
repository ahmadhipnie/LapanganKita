import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/data/repositories/auth_repository.dart';
import 'package:lapangan_kita/app/modules/register/otp_controller.dart';

class OTPBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<Dio>()) {
      Get.lazyPut<Dio>(() => ApiClient.createDefaultDio(), fenix: true);
    }
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(
        () => ApiClient(dio: Get.find<Dio>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(
        () => AuthRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    Get.lazyPut<OTPController>(
      () => OTPController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
