import 'package:get/get.dart';
import '../modules/edit_profile_fieldmanager/edit_profile_fieldmanager_controller.dart';

class EditProfileFieldmanagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileFieldmanagerController>(
      () => EditProfileFieldmanagerController(),
    );
  }
}
