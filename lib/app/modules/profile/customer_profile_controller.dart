import 'package:get/get.dart';

class CustomerProfileController extends GetxController{
  RxBool faceIdEnabled = false.obs;
  // Dummy user data
  final RxString name = 'Budi sakti'.obs;
  final RxString email = 'budi@gmail.com'.obs;
  final RxString avatarUrl = ''.obs;

  void toggleFaceId(bool value) {
    faceIdEnabled.value = value;
  }

  // Add more profile logic here as needed

}