import 'package:get/get.dart';
import '../modules/register/fieldManager_register_controller.dart';

class FieldManagerRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FieldManagerRegisterController>(
      () => FieldManagerRegisterController(),
    );
  }
}
