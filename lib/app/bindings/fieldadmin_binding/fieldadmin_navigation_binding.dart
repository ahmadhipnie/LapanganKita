import 'package:get/get.dart';

import 'package:lapangan_kita/app/modules/navigation/fieldadmin/fieldadmin_navigation_controller.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_logout_controller.dart';
import 'package:lapangan_kita/app/bindings/fieldadmin_binding/fieldadmin_transaction_binding.dart';
import 'package:lapangan_kita/app/bindings/fieldadmin_binding/fieldadmin_field_binding.dart';
import 'package:lapangan_kita/app/bindings/fieldadmin_binding/fieldadmin_withdraw_binding.dart';
import 'package:lapangan_kita/app/bindings/fieldadmin_binding/fieldadmin_promosi_binding.dart';

class FieldadminNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FieldadminNavigationController>(
      () => FieldadminNavigationController(),
      fenix: true,
    );

    Get.lazyPut<FieldadminLogoutController>(
      () => FieldadminLogoutController(),
      fenix: true,
    );

    // Initialize all tab bindings
    FieldadminTransactionBinding().dependencies();
    FieldadminWithdrawBinding().dependencies();
    FieldadminFieldBinding().dependencies();
    FieldadminPromosiBinding().dependencies();
  }
}
