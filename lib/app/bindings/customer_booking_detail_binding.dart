import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_detail_controller.dart';

class CustomerBookingDetailBinding extends Bindings{
  @override
  void dependencies() {
   Get.lazyPut<CustomerBookingDetailController>(() => CustomerBookingDetailController());
  }
}