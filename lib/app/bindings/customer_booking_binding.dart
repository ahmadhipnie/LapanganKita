import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_controller.dart';

class CustomerBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerBookingController>(() => CustomerBookingController());
  }
}
