import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/repositories/post_repository.dart';
import 'package:lapangan_kita/app/modules/community/customer_community_controller.dart';

import '../data/network/api_client.dart';
import '../data/repositories/community_repository.dart';
import '../modules/history/customer_history_controller.dart';

class CustomerCommunityBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CustomerHistoryController>()) {
      Get.lazyPut<CustomerHistoryController>(() => CustomerHistoryController());
    }

    Get.lazyPut<PostRepository>(() => PostRepository(Get.find<ApiClient>()));

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
