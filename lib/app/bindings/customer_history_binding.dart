import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_controller.dart';

class CustomerHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerHistoryController>(() => CustomerHistoryController());
  }
}
