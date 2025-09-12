import 'package:get/get.dart';
import '../modules/place/place_form_controller.dart';

class PlaceFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlaceFormController>(() => PlaceFormController());
  }
}
