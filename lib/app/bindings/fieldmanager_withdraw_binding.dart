import 'package:get/get.dart';

import '../modules/fieldmanager_withdraw/fieldmanager_withdraw_controller.dart';

import '../modules/fieldmanager_withdraw/fieldmanager_withdraw_controller.dart';

class FieldmanagerWithdrawBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FieldmanagerWithdrawController>(
      () => FieldmanagerWithdrawController(),
    );
  }
}
