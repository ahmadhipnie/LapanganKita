import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../data/network/api_client.dart';
import '../data/repositories/auth_repository.dart';
import '../modules/register/customer_register_controller.dart';

class CustomerRegisterBinding extends Bindings {
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
    Get.lazyPut<CustomerRegisterController>(
      () => CustomerRegisterController(
        authRepository: Get.find<AuthRepository>(),
      ),
    );
  }
}
