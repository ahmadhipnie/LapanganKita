import 'package:get/get.dart';

import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/data/repositories/promosi_repository.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_promosi_controller.dart';

class FieldadminPromosiBinding extends Bindings {
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

    Get.lazyPut<FieldadminPromosiController>(
      () => FieldadminPromosiController(
        promosiRepository: Get.find<PromosiRepository>(),
      ),
      fenix: true,
    );
  }
}
