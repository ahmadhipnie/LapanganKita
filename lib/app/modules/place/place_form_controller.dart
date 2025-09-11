import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PlaceFormController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final balanceController = TextEditingController();

  final images = <File>[].obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      images.addAll(picked.map((x) => File(x.path)));
    }
  }

  void removeImage(File img) {
    images.remove(img);
  }

  @override
  void onClose() {
    nameController.dispose();
    streetController.dispose();
    cityController.dispose();
    provinceController.dispose();
    balanceController.dispose();
    super.onClose();
  }
}
