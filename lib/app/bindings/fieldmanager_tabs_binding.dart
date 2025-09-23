import 'package:get/get.dart';

import '../modules/navigation/fieldmanager/tabs_controller/fieldmanager_home_controller.dart';
import '../modules/navigation/fieldmanager/tabs_controller/fieldmanager_booking_controller.dart';
import '../modules/navigation/fieldmanager/tabs_controller/fieldmanager_history_controller.dart';
import '../modules/navigation/fieldmanager/tabs_controller/fieldmanager_profile_controller.dart';

class FieldManagerTabsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FieldManagerHomeController>(
      () => FieldManagerHomeController(),
      fenix: true,
    );
    Get.lazyPut<FieldManagerBookingController>(
      () => FieldManagerBookingController(),
      fenix: true,
    );
    Get.lazyPut<FieldManagerHistoryController>(
      () => FieldManagerHistoryController(),
      fenix: true,
    );
    Get.lazyPut<FieldManagerProfileController>(
      () => FieldManagerProfileController(),
      fenix: true,
    );
  }
}
