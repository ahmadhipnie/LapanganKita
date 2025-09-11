import 'package:get/get.dart';
import '../modules/field/field_add_controller.dart';

class FieldAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FieldAddController>(() => FieldAddController());
  }
}
