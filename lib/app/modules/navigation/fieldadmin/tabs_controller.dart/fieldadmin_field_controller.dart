import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:lapangan_kita/app/data/models/field_model.dart';
import 'package:lapangan_kita/app/data/repositories/field_repository.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

class FieldadminFieldController extends GetxController {
  FieldadminFieldController({
    FieldRepository? fieldRepository,
    LocalStorageService? storageService,
  }) : _fieldRepository = fieldRepository ?? Get.find<FieldRepository>(),
       _storageService = storageService ?? LocalStorageService.instance;

  final FieldRepository _fieldRepository;
  final LocalStorageService _storageService;

  final RxList<FieldModel> fields = <FieldModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString filterStatus = 'All'.obs; // All, Pending, Approved, Rejected
  final RxString searchQuery = ''.obs;

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  void onInit() {
    super.onInit();
    fetchFields();
  }

  Future<void> fetchFields() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final results = await _fieldRepository.getAllFields();
      fields.assignAll(results);
    } on FieldException catch (e) {
      errorMessage.value = e.message;
      fields.clear();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data field. Silakan coba lagi.';
      fields.clear();
      debugPrint('Error fetching fields: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshFields() => fetchFields();

  List<FieldModel> get filteredFields {
    final query = searchQuery.value.trim().toLowerCase();
    
    var list = fields.toList();

    // Filter berdasarkan status verifikasi
    if (filterStatus.value != 'All') {
      final statusFilter = filterStatus.value.toLowerCase();
      list = list.where((field) {
        final fieldStatus = (field.isVerifiedAdmin ?? 'pending').toLowerCase();
        return fieldStatus == statusFilter;
      }).toList();
    }

    // Filter berdasarkan search query
    if (query.isNotEmpty) {
      list = list.where((field) {
        return field.fieldName.toLowerCase().contains(query) ||
            (field.placeName?.toLowerCase().contains(query) ?? false) ||
            (field.placeAddress?.toLowerCase().contains(query) ?? false) ||
            (field.placeOwnerName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort berdasarkan tanggal (terbaru dulu)
    list.sort((a, b) {
      final dateA = a.createdAt ?? DateTime.now();
      final dateB = b.createdAt ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    return list;
  }

  Future<void> approveField(FieldModel field) async {
    final adminId = _storageService.userId;
    
    if (adminId == 0) {
      Get.snackbar(
        'Error',
        'Admin ID tidak ditemukan. Silakan login kembali.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await _fieldRepository.verifyField(
        fieldId: field.id,
        isVerifiedAdmin: 'approved',
        adminId: adminId,
      );

      Get.back(); // Close loading dialog

      if (response.success) {
        await fetchFields();
        Get.snackbar(
          'Berhasil',
          response.message.isNotEmpty 
              ? response.message 
              : 'Field ${field.fieldName} has been approved.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Gagal',
          response.message.isNotEmpty 
              ? response.message 
              : 'Failed to approve field.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } on FieldException catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Gagal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Gagal',
        'Tidak dapat menyetujui field. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      debugPrint('Error approving field: $e');
    }
  }

  Future<void> rejectField(FieldModel field, String reason) async {
    final adminId = _storageService.userId;
    
    if (adminId == 0) {
      Get.snackbar(
        'Error',
        'Admin ID tidak ditemukan. Silakan login kembali.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await _fieldRepository.verifyField(
        fieldId: field.id,
        isVerifiedAdmin: 'rejected',
        adminId: adminId,
      );

      Get.back(); // Close loading dialog

      if (response.success) {
        await fetchFields();
        Get.snackbar(
          'Berhasil',
          response.message.isNotEmpty 
              ? response.message 
              : 'Field ${field.fieldName} telah ditolak.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Gagal',
          response.message.isNotEmpty 
              ? response.message 
              : 'Tidak dapat menolak field.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } on FieldException catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Gagal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Gagal',
        'Tidak dapat menolak field. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      debugPrint('Error rejecting field: $e');
    }
  }

  String formatCurrency(num amount) => _currencyFormatter.format(amount);

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return _dateFormatter.format(date.toLocal());
  }
}
