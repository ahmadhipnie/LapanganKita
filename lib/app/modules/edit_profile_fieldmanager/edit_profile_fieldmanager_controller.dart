import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileFieldmanagerController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final birthdateController = TextEditingController();
  final accountNumberController = TextEditingController();
  final bankTypeController = TextEditingController();

  // For address fields
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // TODO: Load initial profile data here
    nameController.text = 'Nama Fieldmanager';
    emailController.text = 'email@domain.com';
    genderController.text = 'Laki-laki';
    addressController.text = 'Jl. Mawar, Jakarta, DKI Jakarta';
    birthdateController.text = '01/01/1990';
    accountNumberController.text = '1234567890';
    bankTypeController.text = 'BCA';

    // Example split for address
    streetController.text = 'Jl. Mawar';
    cityController.text = 'Jakarta';
    provinceController.text = 'DKI Jakarta';
  }

  void saveProfile() {
    // TODO: Implement save logic
    Get.snackbar('Success', 'Profile updated successfully');
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    genderController.dispose();
    addressController.dispose();
    birthdateController.dispose();
    accountNumberController.dispose();
    bankTypeController.dispose();
    streetController.dispose();
    cityController.dispose();
    provinceController.dispose();
    super.onClose();
  }
}
