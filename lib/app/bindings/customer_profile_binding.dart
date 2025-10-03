import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/profile/customer_profile_controller.dart';

class CustomerProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerProfileController>(() => CustomerProfileController());
  }
}
