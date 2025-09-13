import 'package:get/get.dart';
import '../modules/navigation/fieldmanager/fieldmanager_navigation_controller.dart';

class FieldManagerNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FieldManagerNavigationController>(
      () => FieldManagerNavigationController(),
    );
  }
}
