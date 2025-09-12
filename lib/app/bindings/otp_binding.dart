import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/register/otp_controller.dart';

class OTPBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OTPController>(() => OTPController());
  }
}