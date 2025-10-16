import 'package:get/get.dart';

import '../data/network/api_client.dart';
import '../data/repositories/field_repository.dart';
import '../modules/edit_field_fieldmanager/edit_field_fieldmanager_controller.dart';

class EditFieldFieldmanagerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FieldRepository>()) {
      Get.lazyPut<FieldRepository>(
        () => FieldRepository(Get.find<ApiClient>()),
      );
    }

    Get.lazyPut<EditFieldFieldmanagerController>(
      () => EditFieldFieldmanagerController(
        repository: Get.find<FieldRepository>(),
      ),
    );
  }
}
