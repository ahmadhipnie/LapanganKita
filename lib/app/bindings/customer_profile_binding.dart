import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/profile/profile_controller.dart';

import 'auth_binding.dart';

class CustomerProfileBinding extends Bindings {
  @override
  void dependencies() {
    AuthRepositoryBinding().dependencies();
    Get.lazyPut<CustomerProfileController>(
      () => CustomerProfileController(),
      fenix: true,
    );
  }
}
