import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/fieldmanager_withdraw/fieldmanager_withdraw_controller.dart';

class FieldmanagerWithdrawBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FieldmanagerWithdrawController>(
      () => FieldmanagerWithdrawController(),
    );
  }
}
