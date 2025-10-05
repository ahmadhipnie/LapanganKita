import 'package:get/get.dart';

import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/data/repositories/booking_repository.dart';
import 'package:lapangan_kita/app/data/repositories/refund_repository.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_refund_controller.dart';

class FieldadminTransactionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    if (!Get.isRegistered<RefundRepository>()) {
      Get.lazyPut<RefundRepository>(
        () => RefundRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<BookingRepository>()) {
      Get.lazyPut<BookingRepository>(
        () => BookingRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    Get.lazyPut<FieldadminTransactionController>(
      () => FieldadminTransactionController(
        refundRepository: Get.find<RefundRepository>(),
        bookingRepository: Get.find<BookingRepository>(),
      ),
      fenix: true,
    );
  }
}
