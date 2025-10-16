import 'package:get/get.dart';

import '../data/network/api_client.dart';
import '../data/repositories/add_on_repository.dart';
import '../data/repositories/place_repository.dart';
// import '../data/services/session_service.dart';
import '../modules/place_edit/place_edit_controller.dart';

class PlaceEditBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<AddOnRepository>()) {
      Get.lazyPut<AddOnRepository>(
        () => AddOnRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PlaceRepository>()) {
      Get.lazyPut<PlaceRepository>(
        () => PlaceRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    Get.lazyPut<PlaceEditController>(
      () => PlaceEditController(
        repository: Get.find<PlaceRepository>(),
        // sessionService: Get.find<SessionService>(),
        addOnRepository: Get.find<AddOnRepository>(),
      ),
    );
  }
}
