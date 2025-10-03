import 'package:get/get.dart';
import '../modules/edit_profile_fieldmanager/edit_profile_fieldmanager_controller.dart';
import 'auth_binding.dart';

class EditProfileFieldmanagerBinding extends Bindings {
  @override
  void dependencies() {
    AuthRepositoryBinding().dependencies();
    Get.lazyPut<EditProfileFieldmanagerController>(
      () => EditProfileFieldmanagerController(),
    );
  }
}
