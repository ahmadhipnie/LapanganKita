import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/repositories/field_repository.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_controller.dart';

import '../data/network/api_client.dart';

class CustomerBookingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    // Register FieldRepository
    Get.lazyPut<CourtRepository>(() => CourtRepository(Get.find<ApiClient>()));

    Get.lazyPut<CustomerBookingController>(() => CustomerBookingController());
  }
}
