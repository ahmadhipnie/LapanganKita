import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/add_on_model.dart';
import '../../data/models/place_model.dart';
import '../../data/repositories/add_on_repository.dart';
import '../../data/repositories/place_repository.dart';
// import '../../data/services/session_service.dart';
import '../../services/local_storage_service.dart';
import '../navigation/fieldmanager/tabs_controller/fieldmanager_home_controller.dart';

class PlaceFormController extends GetxController {
  PlaceFormController({
    required PlaceRepository repository,
    // required SessionService sessionService,
    required AddOnRepository addOnRepository,
  }) : _repository = repository,
       //  _sessionService = sessionService,
       _addOnRepository = addOnRepository;

  final PlaceRepository _repository;
  // final SessionService _sessionService;
  final AddOnRepository _addOnRepository;
  final LocalStorageService _storageService = LocalStorageService.instance;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final placeImage = Rx<File?>(null);
  final isSubmitting = false.obs;

  // Add-on state (single entry per submission)
  final isAddOnChecked = false.obs;
  final addOnNameController = TextEditingController();
  final addOnPriceController = TextEditingController();
  final addOnQtyController = TextEditingController();
  final addOnDescController = TextEditingController();
  final addOnImage = Rx<File?>(null);

  final Rxn<PlaceModel> lastCreatedPlace = Rxn<PlaceModel>();

  final ImagePicker _picker = ImagePicker();

  Future<void> pickPlaceImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      placeImage.value = File(picked.path);
    }
  }

  void removePlaceImage() {
    placeImage.value = null;
  }

  Future<void> pickAddOnImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      addOnImage.value = File(picked.path);
    }
  }

  bool _validateAddOnFields() {
    if (!isAddOnChecked.value) return true;

    final name = addOnNameController.text.trim();
    final priceText = addOnPriceController.text.trim();
    final stockText = addOnQtyController.text.trim();
    final description = addOnDescController.text.trim();

    if (name.isEmpty ||
        priceText.isEmpty ||
        stockText.isEmpty ||
        description.isEmpty) {
      Get.snackbar(
        'Form add-on belum lengkap',
        'Isi nama, harga, stok, dan deskripsi add-on terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final price = int.tryParse(priceText.replaceAll('.', ''));
    final stock = int.tryParse(stockText);

    if (price == null || price < 0) {
      Get.snackbar(
        'Harga add-on tidak valid',
        'Masukkan angka yang benar untuk harga per jam.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (stock == null || stock < 0) {
      Get.snackbar(
        'Stok add-on tidak valid',
        'Masukkan angka yang benar untuk stok add-on.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  Future<bool> submit() async {
    if (isSubmitting.value) return false;

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return false;

    if (!_validateAddOnFields()) {
      return false;
    }

    // final user = _sessionService.rememberedUser;
    if (!_storageService.isLoggedIn) {
      Get.snackbar(
        'Sesi berakhir',
        'Silakan masuk kembali untuk melanjutkan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final userId = _storageService.userId;
    if (userId == 0) {
      Get.snackbar(
        'Data pengguna tidak valid',
        'Silakan masuk kembali untuk melanjutkan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final address = [
      streetController.text.trim(),
      cityController.text.trim(),
      provinceController.text.trim(),
    ].where((element) => element.isNotEmpty).join(', ');

    final File? primaryPhoto = placeImage.value;

    isSubmitting.value = true;
    try {
      final response = await _repository.createPlace(
        placeName: nameController.text.trim(),
        address: address,
        userId: userId,
        placePhoto: primaryPhoto,
      );

      PlaceModel? createdPlace = response.data;

      if (createdPlace != null) {
        lastCreatedPlace.value = createdPlace;
        _notifyHome(createdPlace);

        if (isAddOnChecked.value) {
          await _submitSingleAddOn(place: createdPlace, userId: userId);
        }
      }

      Get.snackbar(
        'Berhasil',
        response.message.isNotEmpty
            ? response.message
            : 'Tempat berhasil dibuat.',
        snackPosition: SnackPosition.BOTTOM,
      );

      _resetForm();

      return true;
    } on PlaceException catch (e) {
      Get.snackbar(
        'Gagal menyimpan tempat',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Gagal menyimpan tempat',
        'Terjadi kesalahan tak terduga. Coba lagi beberapa saat.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void _notifyHome(PlaceModel place) {
    if (Get.isRegistered<FieldManagerHomeController>()) {
      Get.find<FieldManagerHomeController>().setPlace(place);
    }
  }

  Future<void> _submitSingleAddOn({
    required PlaceModel place,
    required int userId,
  }) async {
    final payload = AddOnPayload(
      name: addOnNameController.text.trim(),
      pricePerHour:
          int.tryParse(addOnPriceController.text.replaceAll('.', '')) ?? 0,
      stock: int.tryParse(addOnQtyController.text.trim()) ?? 0,
      description: addOnDescController.text.trim(),
      placeId: place.id,
      userId: userId,
      photo: addOnImage.value,
    );

    try {
      final response = await _addOnRepository.createAddOn(payload);
      Get.snackbar(
        'Add-on tersimpan',
        response.message.isNotEmpty
            ? response.message
            : 'Add-on berhasil dibuat.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AddOnException catch (e) {
      Get.snackbar(
        'Gagal membuat add-on',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Gagal membuat add-on',
        'Terjadi kesalahan tak terduga saat menyimpan add-on.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _resetForm() {
    formKey.currentState?.reset();
    nameController.clear();
    streetController.clear();
    cityController.clear();
    provinceController.clear();
    placeImage.value = null;
    isAddOnChecked.value = false;
    addOnNameController.clear();
    addOnPriceController.clear();
    addOnQtyController.clear();
    addOnDescController.clear();
    addOnImage.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    streetController.dispose();
    cityController.dispose();
    provinceController.dispose();
    addOnNameController.dispose();
    addOnPriceController.dispose();
    addOnQtyController.dispose();
    addOnDescController.dispose();
    super.onClose();
  }
}
