import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/data/repositories/place_repository.dart';
import 'package:lapangan_kita/app/data/repositories/withdraw_repository.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_withdraw_controller.dart';

class FieldadminWithdrawBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<WithdrawRepository>()) {
      Get.lazyPut<WithdrawRepository>(
        () => WithdrawRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PlaceRepository>()) {
      Get.lazyPut<PlaceRepository>(
        () => PlaceRepository(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    Get.lazyPut<FieldadminWithdrawController>(
      () => FieldadminWithdrawController(
        withdrawRepository: Get.find<WithdrawRepository>(),
        placeRepository: Get.find<PlaceRepository>(),
      ),
    );
  }
}
