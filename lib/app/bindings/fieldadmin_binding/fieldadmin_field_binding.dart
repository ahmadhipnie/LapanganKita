import 'package:get/get.dart';

import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/data/repositories/place_repository.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_field_controller.dart';

class FieldadminFieldBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    if (!Get.isRegistered<PlaceRepository>()) {
      Get.lazyPut<PlaceRepository>(
        () => PlaceRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    Get.lazyPut<FieldadminFieldController>(
      () => FieldadminFieldController(
        placeRepository: Get.find<PlaceRepository>(),
      ),
      fenix: true,
    );
  }
}
