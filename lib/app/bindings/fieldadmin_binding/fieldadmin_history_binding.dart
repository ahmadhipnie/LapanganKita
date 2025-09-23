import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_history_controller.dart';

class FieldadminHistoryBinding extends Bindings {
  @override
  void dependencies() {
   Get.lazyPut<FieldadminHistoryController>(
      () => FieldadminHistoryController(),
    );
  }
}