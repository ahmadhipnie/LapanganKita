import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/data/repositories/court_repositoy.dart';
import 'package:lapangan_kita/app/data/repositories/promosi_repository.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_controller.dart';
import 'package:lapangan_kita/app/modules/community/customer_community_controller.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_controller.dart';
import 'package:lapangan_kita/app/modules/home/customer_home_controller.dart';
import 'package:lapangan_kita/app/modules/navigation/customer_navigation_controller.dart';

class CustomerNavigationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<PromosiRepository>()) {
      Get.lazyPut<PromosiRepository>(
        () => PromosiRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    Get.lazyPut<CourtRepository>(() => CourtRepository(Get.find<ApiClient>()));
    Get.lazyPut<CustomerCommunityController>(
      () => CustomerCommunityController(),
    );
    Get.lazyPut<CustomerHistoryController>(() => CustomerHistoryController());
    Get.lazyPut<CustomerBookingController>(() => CustomerBookingController());
    Get.lazyPut<CustomerHomeController>(
      () => CustomerHomeController(
        promosiRepository: Get.find<PromosiRepository>(),
      ),
    );
    Get.lazyPut<CustomerNavigationController>(
      () => CustomerNavigationController(),
    );
  }
}
