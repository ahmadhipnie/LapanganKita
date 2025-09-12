import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/community/customer_community_controller.dart';

class CustomerCommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerCommunityController>(() => CustomerCommunityController());
  }
}
