import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/repositories/add_on_repository.dart';
import 'package:lapangan_kita/app/data/repositories/customer_booking_repository.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_detail_controller.dart';

import '../data/network/api_client.dart';

class CustomerBookingDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerBookingRepository>(() => CustomerBookingRepository());
    Get.lazyPut<AddOnRepository>(
      () => AddOnRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<CustomerBookingDetailController>(
      () => CustomerBookingDetailController(),
    );
  }
}
