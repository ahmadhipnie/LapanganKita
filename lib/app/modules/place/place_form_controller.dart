import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddOnModel {
  String name;
  int pricePerHour;
  int quantity;
  String description;
  File? image;
  AddOnModel({
    required this.name,
    required this.pricePerHour,
    required this.quantity,
    required this.description,
    this.image,
  });
}

class PlaceFormController extends GetxController {
  // Addon logic
  final isAddOnChecked = false.obs;
  final addOnNameController = TextEditingController();
  final addOnPriceController = TextEditingController();
  final addOnQtyController = TextEditingController();
  final addOnDescController = TextEditingController();
  final addOnImage = Rx<File?>(null);
  final addOns = <AddOnModel>[].obs;

  void pickAddOnImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      addOnImage.value = File(picked.path);
    }
  }

  void addAddOn() {
    if (addOnNameController.text.isEmpty ||
        addOnPriceController.text.isEmpty ||
        addOnQtyController.text.isEmpty ||
        addOnDescController.text.isEmpty) {
      Get.snackbar('Error', 'Semua field add on wajib diisi');
      return;
    }
    addOns.add(
      AddOnModel(
        name: addOnNameController.text,
        pricePerHour: int.tryParse(addOnPriceController.text) ?? 0,
        quantity: int.tryParse(addOnQtyController.text) ?? 0,
        description: addOnDescController.text,
        image: addOnImage.value,
      ),
    );
    addOnNameController.clear();
    addOnPriceController.clear();
    addOnQtyController.clear();
    addOnDescController.clear();
    addOnImage.value = null;
  }

  void removeAddOn(int idx) {
    addOns.removeAt(idx);
  }

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
    addOnNameController.dispose();
    addOnPriceController.dispose();
    addOnQtyController.dispose();
    addOnDescController.dispose();
    super.onClose();
  }
}
