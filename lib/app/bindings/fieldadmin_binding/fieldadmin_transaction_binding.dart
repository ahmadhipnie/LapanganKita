import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_transaction_controller.dart';

class FieldadminTransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FieldadminTransactionController>(
      () => FieldadminTransactionController(),
    );
  }
}