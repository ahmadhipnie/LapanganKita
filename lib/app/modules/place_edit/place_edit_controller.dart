import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/add_on_model.dart';
import '../../data/models/place_model.dart';
import '../../data/network/api_client.dart';
import '../../data/repositories/add_on_repository.dart';
import '../../data/repositories/place_repository.dart';
// import '../../data/services/session_service.dart';
import '../../services/local_storage_service.dart';
import '../navigation/fieldmanager/tabs_controller/fieldmanager_home_controller.dart';

class AddOnActionResult {
  const AddOnActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class PlaceEditController extends GetxController {
  PlaceEditController({
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

  final Rx<File?> selectedPhoto = Rx<File?>(null);
  final RxString initialPhotoUrl = ''.obs;
  final isSubmitting = false.obs;

  final RxList<AddOnModel> addOns = <AddOnModel>[].obs;
  final isLoadingAddOns = false.obs;
  final isCreatingAddOn = false.obs;
  final RxString addOnError = ''.obs;
  final RxMap<int, bool> addOnSubmitting = <int, bool>{}.obs;
  final RxMap<int, bool> addOnDeleting = <int, bool>{}.obs;

  final ImagePicker _picker = ImagePicker();

  PlaceModel? _originalPlace;

  @override
  void onInit() {
    super.onInit();
    _loadPlaceFromArgs();
  }

  void _loadPlaceFromArgs() {
    final args = Get.arguments;
    if (args is! PlaceModel) {
      Get.snackbar(
        'Data tidak ditemukan',
        'Tidak ada data tempat untuk diedit.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _originalPlace = args;
    nameController.text = args.placeName;

    final parts = args.address.split(',');
    if (parts.isNotEmpty) {
      streetController.text = parts[0].trim();
    }
    if (parts.length >= 2) {
      cityController.text = parts[1].trim();
    }
    if (parts.length >= 3) {
      provinceController.text = parts[2].trim();
    }

    initialPhotoUrl.value = args.placePhoto ?? '';

    fetchAddOnsForPlace();
  }

  Future<void> pickPlaceImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedPhoto.value = File(picked.path);
    }
  }

  void removeSelectedImage() {
    selectedPhoto.value = null;
  }

  Future<void> fetchAddOnsForPlace() async {
    final placeId = _originalPlace?.id;
    if (placeId == null) {
      addOns.clear();
      addOnError.value = '';
      return;
    }

    isLoadingAddOns.value = true;
    addOnError.value = '';

    try {
      final results = await _addOnRepository.getAddOnsByPlace(placeId: placeId);
      addOns.assignAll(
        results
            .map(
              (addOn) => addOn.copyWith(photo: _resolvePhotoUrl(addOn.photo)),
            )
            .toList(),
      );
    } on AddOnException catch (e) {
      addOnError.value = e.message;
      addOns.clear();
    } catch (_) {
      addOnError.value = 'Gagal memuat data add-on. Coba lagi nanti.';
      addOns.clear();
    } finally {
      isLoadingAddOns.value = false;
    }
  }

  Future<AddOnActionResult> createAddOn({
    required String name,
    required int pricePerHour,
    required int stock,
    required String description,
    File? photo,
  }) async {
    if (isCreatingAddOn.value) {
      return const AddOnActionResult(
        success: false,
        message: 'Permintaan sedang diproses. Tunggu sebentar.',
      );
    }

    // final user = _sessionService.rememberedUser;
    final placeId = _originalPlace?.id;
    final userId = _storageService.userId;

    if (!_storageService.isLoggedIn) {
      return const AddOnActionResult(
        success: false,
        message: 'Sesi berakhir. Silakan masuk kembali.',
      );
    }

    if (placeId == null) {
      return const AddOnActionResult(
        success: false,
        message: 'Data tempat tidak ditemukan.',
      );
    }

    isCreatingAddOn.value = true;

    try {
      final response = await _addOnRepository.createAddOn(
        AddOnPayload(
          name: name,
          pricePerHour: pricePerHour,
          stock: stock,
          description: description,
          placeId: placeId,
          userId: userId,
          photo: photo,
        ),
      );

      final successMessage = response.message.isNotEmpty
          ? response.message
          : 'Add-on berhasil ditambahkan.';

      if (response.addOn != null) {
        final created = response.addOn!.copyWith(
          photo: _resolvePhotoUrl(response.addOn!.photo),
        );
        addOns.insert(0, created);
        addOns.refresh();
      } else {
        await fetchAddOnsForPlace();
      }

      return AddOnActionResult(success: true, message: successMessage);
    } on AddOnException catch (e) {
      return AddOnActionResult(success: false, message: e.message);
    } catch (_) {
      return const AddOnActionResult(
        success: false,
        message: 'Terjadi kesalahan tak terduga. Coba lagi nanti.',
      );
    } finally {
      isCreatingAddOn.value = false;
    }
  }

  Future<bool> submit() async {
    if (isSubmitting.value) return false;
    if (_originalPlace == null) return false;

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return false;

    // final user = _sessionService.rememberedUser;
    if (!_storageService.isLoggedIn) {
      Get.snackbar(
        'Sesi berakhir',
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

    final userId = _storageService.userId;
    isSubmitting.value = true;
    try {
      final response = await _repository.updatePlace(
        placeId: _originalPlace!.id,
        placeName: nameController.text.trim(),
        address: address,
        userId: userId,
        placePhoto: selectedPhoto.value,
      );

      final updatedPlace =
          response.data ??
          _originalPlace!.copyWith(
            placeName: nameController.text.trim(),
            address: address,
            placePhoto: initialPhotoUrl.value,
          );

      _notifyHome(updatedPlace);

      initialPhotoUrl.value = updatedPlace.placePhoto ?? '';
      selectedPhoto.value = null;

      final successMessage = response.message.isNotEmpty
          ? response.message
          : 'Data tempat berhasil diperbarui.';

      Get.back(result: {'updated': true, 'message': successMessage});
      return true;
    } on PlaceException catch (e) {
      Get.snackbar(
        'Gagal memperbarui tempat',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Gagal memperbarui tempat',
        'Terjadi kesalahan tak terduga. Coba lagi beberapa saat.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateAddOn({
    required AddOnModel addOn,
    required String name,
    required int pricePerHour,
    required int stock,
    required String description,
  }) async {
    // final user = _sessionService.rememberedUser;
    if (!_storageService.isLoggedIn) {
      Get.snackbar(
        'Sesi berakhir',
        'Silakan masuk kembali untuk melanjutkan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    addOnSubmitting[addOn.id] = true;
    addOnSubmitting.refresh();
    final userId = _storageService.userId;

    try {
      final response = await _addOnRepository.updateAddOn(
        AddOnUpdatePayload(
          id: addOn.id,
          name: name,
          pricePerHour: pricePerHour,
          stock: stock,
          description: description,
          userId: userId,
          placeId: _originalPlace?.id,
        ),
      );

      final successMessage = response.message.isNotEmpty
          ? response.message
          : 'Add-on berhasil diperbarui.';

      if (response.addOn != null) {
        final updated = response.addOn!.copyWith(
          photo: _resolvePhotoUrl(response.addOn!.photo),
        );
        final index = addOns.indexWhere((item) => item.id == updated.id);
        if (index >= 0) {
          addOns[index] = updated;
          addOns.refresh();
        } else {
          addOns.insert(0, updated);
        }
      } else {
        final index = addOns.indexWhere((item) => item.id == addOn.id);
        if (index >= 0) {
          addOns[index] = addOns[index].copyWith(
            name: name,
            pricePerHour: pricePerHour,
            stock: stock,
            description: description,
          );
          addOns.refresh();
        }
      }

      Get.snackbar(
        'Berhasil',
        successMessage,
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } on AddOnException catch (e) {
      Get.snackbar(
        'Gagal memperbarui add-on',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Gagal memperbarui add-on',
        'Terjadi kesalahan tak terduga. Coba lagi nanti.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      addOnSubmitting[addOn.id] = false;
      addOnSubmitting.refresh();
    }
  }

  Future<bool> deleteAddOn(AddOnModel addOn) async {
    // final user = _sessionService.rememberedUser;
    if (!_storageService.isLoggedIn) {
      Get.snackbar(
        'Sesi berakhir',
        'Silakan masuk kembali untuk melanjutkan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (addOnDeleting[addOn.id] == true) {
      return false;
    }

    addOnDeleting[addOn.id] = true;
    addOnDeleting.refresh();
    final userId = _storageService.userId;

    try {
      final response = await _addOnRepository.deleteAddOn(
        addOnId: addOn.id,
        userId: userId,
      );

      final successMessage = response.message.isNotEmpty
          ? response.message
          : 'Add-on berhasil dihapus.';

      addOns.removeWhere((item) => item.id == addOn.id);
      addOns.refresh();

      Get.snackbar(
        'Berhasil',
        successMessage,
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } on AddOnException catch (e) {
      Get.snackbar(
        'Gagal menghapus add-on',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Gagal menghapus add-on',
        'Terjadi kesalahan tak terduga. Coba lagi nanti.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      addOnDeleting[addOn.id] = false;
      addOnDeleting.refresh();
    }
  }

  bool isAddOnUpdating(int addOnId) => addOnSubmitting[addOnId] == true;
  bool isAddOnDeleting(int addOnId) => addOnDeleting[addOnId] == true;

  void _notifyHome(PlaceModel place) {
    if (Get.isRegistered<FieldManagerHomeController>()) {
      final home = Get.find<FieldManagerHomeController>();
      home.setPlace(place);
    }
  }

  String? get resolvedInitialPhotoUrl {
    return _resolvePhotoUrl(initialPhotoUrl.value);
  }

  String? _resolvePhotoUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;

    final base = Uri.parse(ApiClient.baseUrl);
    final buffer = StringBuffer()
      ..write(base.scheme)
      ..write('://')
      ..write(base.host);

    if (base.hasPort && base.port != 80 && base.port != 443) {
      buffer.write(':${base.port}');
    }

    final normalized = raw.startsWith('/') ? raw : '/$raw';
    return '${buffer.toString()}$normalized';
  }

  @override
  void onClose() {
    nameController.dispose();
    streetController.dispose();
    cityController.dispose();
    provinceController.dispose();
    super.onClose();
  }
}
