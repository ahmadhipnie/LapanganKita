import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/fieldadmin_navigation_controller.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_transaction_controller.dart';

class FieldadminNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FieldadminTransactionController>(
      () => FieldadminTransactionController(),
    );
    Get.lazyPut<FieldadminNavigationController>(
      () => FieldadminNavigationController(),
    );
  }
}
