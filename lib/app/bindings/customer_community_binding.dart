import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/community/customer_community_controller.dart';

import '../data/network/api_client.dart';
import '../data/repositories/community_repository.dart';

class CustomerCommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunityRepository>(
      () => CommunityRepository(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<CustomerCommunityController>(
      () => CustomerCommunityController(
        repository: Get.find<CommunityRepository>(),
      ),
    );
  }
}
