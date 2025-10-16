import 'package:get/get.dart';

import '../data/network/api_client.dart';
import '../data/repositories/field_repository.dart';
// import '../data/services/session_service.dart';
import '../modules/field/field_add_controller.dart';

class FieldAddBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    Get.lazyPut<FieldRepository>(
      () => FieldRepository(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<FieldAddController>(
      () => FieldAddController(
        repository: Get.find<FieldRepository>(),
        // sessionService: Get.find<SessionService>(),
      ),
    );
  }
}
