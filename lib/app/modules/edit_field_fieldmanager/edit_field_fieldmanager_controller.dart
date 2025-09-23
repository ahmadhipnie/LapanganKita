import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldmanager/tabs_controller/fieldmanager_home_controller.dart';

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
    // Status mapping: map Indonesian to English for UI
    final rawStatus = field['status']?.toString() ?? '';
    if (rawStatus.toLowerCase() == 'tersedia') {
      status.value = 'Available';
    } else if (rawStatus.toLowerCase() == 'tidak tersedia') {
      status.value = 'Not Available';
    } else {
      status.value = rawStatus;
    }
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

  // Status for availability (UI in English)
  final status = ''.obs;
  final statusList = ['Available', 'Not Available'];

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

  // Delete the field from the home controller's list (dummy data)
  void deleteField() {
    final args = Get.arguments;
    FieldManagerHomeController? home;
    if (Get.isRegistered<FieldManagerHomeController>()) {
      home = Get.find<FieldManagerHomeController>();
    }
    if (home != null) {
      dynamic id = (args is Map) ? args['id'] : null;
      if (id != null) {
        home.fields.removeWhere((e) => e['id'] == id);
      } else {
        // fallback by name+type
        final name = nameController.text;
        final type = fieldType.value;
        home.fields.removeWhere((e) => e['name'] == name && e['type'] == type);
      }
    }
    Get.back();
    Get.snackbar('Success', 'Field deleted successfully');
  }
}
