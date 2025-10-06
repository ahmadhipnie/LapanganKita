import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lapangan_kita/app/data/models/promosi_model.dart';
import 'package:lapangan_kita/app/data/repositories/promosi_repository.dart';

class FieldadminPromosiController extends GetxController {
  FieldadminPromosiController({PromosiRepository? promosiRepository})
    : _promosiRepository = promosiRepository ?? Get.find<PromosiRepository>(),
      _picker = ImagePicker();

  final PromosiRepository _promosiRepository;
  final ImagePicker _picker;

  final RxList<PromosiModel> promosiItems = <PromosiModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<int, bool> _updateStates = <int, bool>{}.obs;
  final RxMap<int, bool> _deleteStates = <int, bool>{}.obs;

  bool isUpdating(int id) => _updateStates[id] ?? false;
  bool isDeleting(int id) => _deleteStates[id] ?? false;

  @override
  void onInit() {
    super.onInit();
    fetchPromosiList();
  }

  Future<void> fetchPromosiList() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final list = await _promosiRepository.getPromosiList();
      promosiItems.assignAll(list);
    } on PromosiException catch (e) {
      promosiItems.clear();
      errorMessage.value = e.message;
    } catch (e) {
      promosiItems.clear();
      errorMessage.value =
          'Gagal memuat data promosi. Silakan coba beberapa saat lagi.';
      debugPrint('fetchPromosiList error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPromosi() async {
    await fetchPromosiList();
  }

  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final file = await _picker.pickImage(source: source);
      return file;
    } catch (e) {
      debugPrint('pickImage error: $e');
      return null;
    }
  }

  Future<bool> createPromosi(XFile file) async {
    if (isSubmitting.value) return false;

    isSubmitting.value = true;

    try {
      final created = await _promosiRepository.createPromosi(File(file.path));
      promosiItems.insert(0, created);
      return true;
    } on PromosiException catch (e) {
      Get.snackbar(
        'Gagal membuat promosi',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE68A),
        colorText: Colors.black87,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal membuat promosi',
        'Terjadi kesalahan. Coba lagi beberapa saat.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE68A),
        colorText: Colors.black87,
      );
    } finally {
      isSubmitting.value = false;
    }

    return false;
  }

  Future<bool> updatePromosi(int id, {XFile? file}) async {
    if (isUpdating(id)) return false;

    _setUpdating(id, true);

    try {
      final updated = await _promosiRepository.updatePromosi(
        id: id,
        file: file != null ? File(file.path) : null,
      );

      final index = promosiItems.indexWhere((element) => element.id == id);
      if (index != -1) {
        promosiItems[index] = updated;
      } else {
        promosiItems.insert(0, updated);
      }

      return true;
    } on PromosiException catch (e) {
      Get.snackbar(
        'Gagal memperbarui promosi',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFECACA),
        colorText: Colors.black87,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal memperbarui promosi',
        'Terjadi kesalahan. Silakan coba kembali.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFECACA),
        colorText: Colors.black87,
      );
    } finally {
      _setUpdating(id, false);
    }

    return false;
  }

  Future<bool> deletePromosi(int id) async {
    if (isDeleting(id)) return false;

    _setDeleting(id, true);

    try {
      await _promosiRepository.deletePromosi(id);
      promosiItems.removeWhere((element) => element.id == id);
      return true;
    } on PromosiException catch (e) {
      Get.snackbar(
        'Gagal menghapus promosi',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFECACA),
        colorText: Colors.black87,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal menghapus promosi',
        'Terjadi kesalahan. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFECACA),
        colorText: Colors.black87,
      );
    } finally {
      _setDeleting(id, false);
    }

    return false;
  }

  void _setUpdating(int id, bool value) {
    if (value) {
      _updateStates[id] = true;
    } else {
      _updateStates.remove(id);
    }
  }

  void _setDeleting(int id, bool value) {
    if (value) {
      _deleteStates[id] = true;
    } else {
      _deleteStates.remove(id);
    }
  }
}
