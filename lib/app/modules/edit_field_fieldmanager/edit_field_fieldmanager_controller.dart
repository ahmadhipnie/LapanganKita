import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditFieldFieldmanagerController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    final field = Get.arguments;
    if (field == null) {
      debugPrint(
        'EditFieldFieldmanagerController: No arguments passed to edit field!',
      );
      Get.snackbar('Error', 'No field data provided for editing.');
      _fillDefaults();
      return;
    }
    if (field is! Map) {
      debugPrint(
        'EditFieldFieldmanagerController: Arguments are not a Map! Value: '
        '${field.runtimeType}',
      );
      Get.snackbar('Error', 'Invalid field data format.');
      _fillDefaults();
      return;
    }
    nameController.text = field['name']?.toString() ?? '';
    openHourController.text = field['openHour']?.toString() ?? '';
    closeHourController.text = field['closeHour']?.toString() ?? '';
    priceController.text = field['price']?.toString() ?? '';
    descController.text = field['description']?.toString() ?? '';
    maxPersonController.text = field['maxPerson']?.toString() ?? '';
    fieldType.value = field['type']?.toString() ?? '';
    // If there are images, handle them here as well
  }

  void _fillDefaults() {
    nameController.text = '';
    openHourController.text = '';
    closeHourController.text = '';
    priceController.text = '';
    descController.text = '';
    maxPersonController.text = '';
    fieldType.value = '';
  }

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final openHourController = TextEditingController();
  final closeHourController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final maxPersonController = TextEditingController();

  final fieldType = ''.obs;
  final fieldTypeList = [
    'Futsal',
    'Mini Soccer',
    'Badminton',
    'Basket',
    'Tennis',
    'Voli',
    'Other',
  ];

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

  Future<void> pickOpenHour(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      openHourController.text = picked.format(context);
    }
  }

  Future<void> pickCloseHour(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      closeHourController.text = picked.format(context);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    openHourController.dispose();
    closeHourController.dispose();
    priceController.dispose();
    descController.dispose();
    maxPersonController.dispose();
    super.onClose();
  }
}
