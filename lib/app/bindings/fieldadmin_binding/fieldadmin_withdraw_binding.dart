import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_withdraw_controller.dart';

class FieldadminWithdrawBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FieldadminWithdrawController>(
      () => FieldadminWithdrawController(),
    );
  }
}