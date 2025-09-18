import 'package:get/get.dart';
import '../modules/edit_field_fieldmanager/edit_field_fieldmanager_controller.dart';

class EditFieldFieldmanagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditFieldFieldmanagerController>(
      () => EditFieldFieldmanagerController(),
    );
  }
}
