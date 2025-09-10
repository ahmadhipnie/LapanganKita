import 'package:get/get.dart';
import '../modules/register/customer_register_controller.dart';

class CustomerRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerRegisterController>(() => CustomerRegisterController());
  }
}
