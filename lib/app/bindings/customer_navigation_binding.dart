import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_controller.dart';
import 'package:lapangan_kita/app/modules/home/customer_home_controller.dart';
import 'package:lapangan_kita/app/modules/navigation/customer_navigation_controller.dart';

class CustomerNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerBookingController>(() => CustomerBookingController());
    Get.lazyPut<CustomerHomeController>(() => CustomerHomeController());
    Get.lazyPut<CustomerNavigationController>(
      () => CustomerNavigationController(),
    );
  }
}
