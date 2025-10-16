import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/auth/auth_controller.dart';
import 'package:lapangan_kita/app/modules/login/login_controller.dart';

import '../data/network/api_client.dart';
import '../data/repositories/auth_repository.dart';
import '../modules/register/customer_register_controller.dart';
import '../modules/register/fieldManager_register_controller.dart';

class TestAuthBinding extends Bindings {
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
      fenix: true,
    );

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
    Get.lazyPut<CustomerRegisterController>(
      () => CustomerRegisterController(
        authRepository: Get.find<AuthRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<Dio>(() => ApiClient.createDefaultDio(), fenix: true);
    Get.lazyPut<ApiClient>(() => ApiClient(dio: Get.find<Dio>()), fenix: true);
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<LoginController>(
      () => LoginController(authRepository: Get.find<AuthRepository>()),
      fenix: true,
    );
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
