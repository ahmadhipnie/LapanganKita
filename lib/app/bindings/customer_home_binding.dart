import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';
import 'package:lapangan_kita/app/data/repositories/promosi_repository.dart';
import 'package:lapangan_kita/app/modules/home/customer_home_controller.dart';

class CustomerHomeBinding extends Bindings {
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

    Get.lazyPut<CustomerHomeController>(
      () => CustomerHomeController(
        promosiRepository: Get.find<PromosiRepository>(),
      ),
    );
  }
}
