import 'package:get/get.dart';
import '../data/network/api_client.dart';
import '../data/repositories/auth_repository.dart';

class AuthRepositoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);

    Get.lazyPut<AuthRepository>(
      () => AuthRepository(Get.find<ApiClient>()),
      fenix: true,
    );
  }
}
