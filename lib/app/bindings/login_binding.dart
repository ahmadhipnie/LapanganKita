import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/data/repositories/auth_repository.dart';

import '../modules/login/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Dio>(() => ApiClient.createDefaultDio(), fenix: true);
    Get.lazyPut<ApiClient>(() => ApiClient(dio: Get.find<Dio>()), fenix: true);
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<LoginController>(
      () => LoginController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
