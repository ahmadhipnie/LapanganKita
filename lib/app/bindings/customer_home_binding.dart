import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/home/customer_home_controller.dart';

class CustomerHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerHomeController>(() => CustomerHomeController());
  }
}
