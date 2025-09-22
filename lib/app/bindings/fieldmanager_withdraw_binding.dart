import 'package:get/get.dart';

import 'fieldmanager_withdraw_controller.dart';

class FieldmanagerWithdrawBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FieldmanagerWithdrawController>(
      () => FieldmanagerWithdrawController(),
    );
  }
}
