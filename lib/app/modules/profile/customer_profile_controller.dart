import 'package:get/get.dart';

class CustomerProfileController extends GetxController{
  RxBool faceIdEnabled = false.obs;
  // Dummy user data
  final RxString name = 'Itunoluwa Abidaye'.obs;
  final RxString username = '@itunoluwa'.obs;
  final RxString avatarUrl = ''.obs;

  void toggleFaceId(bool value) {
    faceIdEnabled.value = value;
  }

  // Add more profile logic here as needed

}