import 'package:get/get.dart';

import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/data/repositories/field_repository.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_field_controller.dart';

class FieldadminFieldBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    if (!Get.isRegistered<FieldRepository>()) {
      Get.lazyPut<FieldRepository>(
        () => FieldRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    Get.lazyPut<FieldadminFieldController>(
      () => FieldadminFieldController(
        fieldRepository: Get.find<FieldRepository>(),
      ),
      fenix: true,
    );
  }
}
