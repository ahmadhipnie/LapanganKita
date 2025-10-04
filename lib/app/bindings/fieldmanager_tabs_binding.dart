import 'package:get/get.dart';

import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/data/repositories/booking_repository.dart';
import 'package:lapangan_kita/app/data/repositories/field_repository.dart';
import 'package:lapangan_kita/app/data/repositories/place_repository.dart';
import 'package:lapangan_kita/app/data/services/session_service.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldmanager/tabs_controller/fieldmanager_booking_controller.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldmanager/tabs_controller/fieldmanager_history_controller.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldmanager/tabs_controller/fieldmanager_home_controller.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldmanager/tabs_controller/fieldmanager_profile_controller.dart';

class FieldManagerTabsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<FieldRepository>()) {
      Get.lazyPut<FieldRepository>(
        () => FieldRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<BookingRepository>()) {
      Get.lazyPut<BookingRepository>(
        () => BookingRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PlaceRepository>()) {
      Get.lazyPut<PlaceRepository>(
        () => PlaceRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    Get.lazyPut<FieldManagerHomeController>(
      () => FieldManagerHomeController(
        placeRepository: Get.find<PlaceRepository>(),
        sessionService: Get.find<SessionService>(),
      ),
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
