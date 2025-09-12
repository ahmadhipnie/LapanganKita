import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/navigation/customer_navigation_controller.dart';

class CustomerNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerNavigationController>(() => CustomerNavigationController());
  }
}
