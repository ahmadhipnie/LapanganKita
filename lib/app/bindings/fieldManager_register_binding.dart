import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../data/network/api_client.dart';
import '../data/repositories/auth_repository.dart';
import '../modules/register/fieldManager_register_controller.dart';

class FieldManagerRegisterBinding extends Bindings {
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
    Get.lazyPut<FieldManagerRegisterController>(
      () => FieldManagerRegisterController(
        authRepository: Get.find<AuthRepository>(),
      ),
    );
  }
}
