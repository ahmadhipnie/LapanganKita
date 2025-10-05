import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/repositories/field_repository.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_controller.dart';
import 'package:lapangan_kita/app/modules/community/customer_community_controller.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_controller.dart';
import 'package:lapangan_kita/app/modules/home/customer_home_controller.dart';
import 'package:lapangan_kita/app/modules/navigation/customer_navigation_controller.dart';

import '../data/network/api_client.dart';

class CustomerNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<CourtRepository>(() => CourtRepository(Get.find<ApiClient>()));
    Get.lazyPut<CustomerCommunityController>(
      () => CustomerCommunityController(),
    );
    Get.lazyPut<CustomerHistoryController>(() => CustomerHistoryController());
    Get.lazyPut<CustomerBookingController>(() => CustomerBookingController());
    Get.lazyPut<CustomerHomeController>(() => CustomerHomeController());
    Get.lazyPut<CustomerNavigationController>(
      () => CustomerNavigationController(),
    );
  }
}
