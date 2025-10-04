import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/field_model.dart';
import '../../data/network/api_client.dart';
import '../../data/repositories/field_repository.dart';
import '../../data/services/session_service.dart';
import '../navigation/fieldmanager/tabs_controller/fieldmanager_home_controller.dart';

class EditFieldFieldmanagerController extends GetxController {
  EditFieldFieldmanagerController({
    FieldRepository? repository,
    SessionService? sessionService,
    FieldManagerHomeController? homeController,
  }) : _repository = repository ?? Get.find<FieldRepository>(),
       _sessionService = sessionService ?? Get.find<SessionService>(),
       _homeController =
           homeController ??
           (Get.isRegistered<FieldManagerHomeController>()
               ? Get.find<FieldManagerHomeController>()
               : null);

  final FieldRepository _repository;
  final SessionService _sessionService;
  final FieldManagerHomeController? _homeController;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final openHourController = TextEditingController();
  final closeHourController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final maxPersonController = TextEditingController();

  final fieldType = ''.obs;
  final List<String> fieldTypeList = const [
    'Futsal',
    'Mini Soccer',
    'Badminton',
    'Basket',
    'Tennis',
    'Voli',
    'Other',
  ];

  final status = ''.obs;
  final List<String> statusList = const ['Available', 'Not Available'];

  final Rx<File?> selectedPhoto = Rx<File?>(null);
  final RxString initialPhotoUrl = ''.obs;

  final isSubmitting = false.obs;
  final isDeleting = false.obs;

  final ImagePicker _picker = ImagePicker();
  final Rx<TimeOfDay?> _openTime = Rx<TimeOfDay?>(null);
  final Rx<TimeOfDay?> _closeTime = Rx<TimeOfDay?>(null);

  int? _fieldId;
  int? _placeId;

  @override
  void onInit() {
    super.onInit();
    _loadFieldFromArgs();
  }

  void _loadFieldFromArgs() {
    final args = Get.arguments;
    if (args == null) {
      debugPrint('EditFieldFieldmanagerController: No field data provided.');
      Get.snackbar(
        'Data tidak ditemukan',
        'Tidak ada data lapangan untuk diedit.',
        snackPosition: SnackPosition.BOTTOM,
      );
      _fillDefaults();
      return;
    }

    if (args is FieldModel) {
      _fieldId = args.id;
      _placeId = args.placeId;
      nameController.text = args.fieldName;
      openHourController.text = _formatTimeForDisplay(args.openingTime);
      closeHourController.text = _formatTimeForDisplay(args.closingTime);
      priceController.text = args.pricePerHour.toString();
      descController.text = args.description;
      maxPersonController.text = args.maxPerson.toString();
      fieldType.value = _formatFieldTypeForUi(args.fieldType);
      status.value = _mapStatusForUi(args.status);
      initialPhotoUrl.value = args.fieldPhoto ?? '';
      _openTime.value = _parseTimeOfDay(args.openingTime);
      _closeTime.value = _parseTimeOfDay(args.closingTime);
      return;
    }

    if (args is Map) {
      _fieldId = _parseInt(args['id']);
      _placeId = _parseInt(args['placeId']);
      nameController.text = args['name']?.toString() ?? '';
      openHourController.text = args['openHour']?.toString() ?? '';
      closeHourController.text = args['closeHour']?.toString() ?? '';
      priceController.text = args['price']?.toString() ?? '';
      descController.text = args['description']?.toString() ?? '';
      maxPersonController.text = args['maxPerson']?.toString() ?? '';
      fieldType.value = args['type']?.toString() ?? '';
      status.value = args['status']?.toString() ?? '';
      initialPhotoUrl.value = args['photo']?.toString() ?? '';
      _openTime.value = _parseTimeOfDay(args['openHour']?.toString());
      _closeTime.value = _parseTimeOfDay(args['closeHour']?.toString());
      return;
    }

    debugPrint(
      'EditFieldFieldmanagerController: Unsupported argument type '
      '${args.runtimeType}',
    );
    Get.snackbar(
      'Data tidak valid',
      'Format data field tidak dikenali.',
      snackPosition: SnackPosition.BOTTOM,
    );
    _fillDefaults();
  }

  void _fillDefaults() {
    nameController.text = '';
    openHourController.text = '';
    closeHourController.text = '';
    priceController.text = '';
    descController.text = '';
    maxPersonController.text = '';
    fieldType.value = '';
    status.value = '';
    initialPhotoUrl.value = '';
    _openTime.value = null;
    _closeTime.value = null;
  }

  Future<void> pickFieldPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedPhoto.value = File(picked.path);
    }
  }

  void removeSelectedPhoto() {
    selectedPhoto.value = null;
  }

  Future<void> pickOpenHour(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _openTime.value ?? TimeOfDay.now(),
    );
    if (picked != null) {
      _openTime.value = picked;
      openHourController.text = _formatDisplayTime(picked);
    }
  }

  Future<void> pickCloseHour(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _closeTime.value ?? TimeOfDay.now(),
    );
    if (picked != null) {
      _closeTime.value = picked;
      closeHourController.text = _formatDisplayTime(picked);
    }
  }

  Future<bool> submit() async {
    if (isSubmitting.value) return false;

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return false;

    final fieldId = _fieldId;
    if (fieldId == null) {
      Get.snackbar(
        'Data tidak ditemukan',
        'Identitas lapangan tidak tersedia.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final user = _sessionService.rememberedUser;
    if (user == null) {
      Get.snackbar(
        'Sesi berakhir',
        'Silakan masuk kembali untuk melanjutkan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final placeId = _placeId ?? _homeController?.place.value?.id;
    if (placeId == null) {
      Get.snackbar(
        'Tempat belum terdaftar',
        'Daftarkan tempat Anda sebelum mengubah lapangan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final openTime = _ensureOpenTime();
    final closeTime = _ensureCloseTime();

    if (openTime == null || closeTime == null) {
      Get.snackbar(
        'Jam operasional belum lengkap',
        'Pilih jam buka dan jam tutup terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final parsedPrice = _parseInt(priceController.text);
    if (parsedPrice == null || parsedPrice <= 0) {
      Get.snackbar(
        'Harga tidak valid',
        'Masukkan angka untuk harga per jam.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final parsedMaxPerson = _parseInt(maxPersonController.text);
    if (parsedMaxPerson == null || parsedMaxPerson <= 0) {
      Get.snackbar(
        'Kapasitas tidak valid',
        'Masukkan angka untuk kapasitas maksimum.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final currentFieldType = fieldType.value.trim();
    if (currentFieldType.isEmpty) {
      Get.snackbar(
        'Tipe lapangan wajib',
        'Pilih tipe lapangan terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final currentStatus = status.value.trim();
    if (currentStatus.isEmpty) {
      Get.snackbar(
        'Status wajib',
        'Pilih status ketersediaan lapangan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isSubmitting.value = true;
    try {
      final response = await _repository.updateField(
        fieldId: fieldId,
        fieldName: nameController.text.trim(),
        openingTime: _formatTimeForApi(openTime),
        closingTime: _formatTimeForApi(closeTime),
        pricePerHour: parsedPrice,
        description: descController.text.trim(),
        fieldType: _fieldTypeForApi(currentFieldType),
        status: _statusForApi(currentStatus),
        maxPerson: parsedMaxPerson,
        placeId: placeId,
        userId: user.id,
        fieldPhoto: selectedPhoto.value,
      );

      final successMessage = response.message.isNotEmpty
          ? response.message
          : 'Data lapangan berhasil diperbarui.';

      final updatedField = response.data;
      if (updatedField != null) {
        _placeId = updatedField.placeId;
        initialPhotoUrl.value =
            updatedField.fieldPhoto ?? initialPhotoUrl.value;
        _openTime.value = _parseTimeOfDay(updatedField.openingTime);
        _closeTime.value = _parseTimeOfDay(updatedField.closingTime);
      } else if (selectedPhoto.value != null) {
        initialPhotoUrl.value = selectedPhoto.value!.path;
      }
      selectedPhoto.value = null;

      if (_homeController != null) {
        if (updatedField != null) {
          _homeController.addOrUpdateField(updatedField);
        } else {
          await _homeController.fetchFieldsForPlace(force: true);
        }
      }

      Get.back(result: {'updated': true, 'message': successMessage});
      return true;
    } on FieldException catch (e) {
      Get.snackbar(
        'Gagal memperbarui lapangan',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Gagal memperbarui lapangan',
        'Terjadi kesalahan tak terduga. Coba lagi beberapa saat.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  TimeOfDay? _ensureOpenTime() {
    if (_openTime.value != null) return _openTime.value;
    final parsed = _parseTimeOfDay(openHourController.text);
    if (parsed != null) {
      _openTime.value = parsed;
    }
    return _openTime.value;
  }

  TimeOfDay? _ensureCloseTime() {
    if (_closeTime.value != null) return _closeTime.value;
    final parsed = _parseTimeOfDay(closeHourController.text);
    if (parsed != null) {
      _closeTime.value = parsed;
    }
    return _closeTime.value;
  }

  TimeOfDay? _parseTimeOfDay(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value.trim();
    final parts = cleaned.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
      }
    }
    return null;
  }

  String _formatDisplayTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimeForDisplay(String raw) {
    if (raw.isEmpty) return '';
    final parts = raw.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return raw;
  }

  String _formatTimeForApi(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    final cleaned = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  String _fieldTypeForApi(String raw) => raw.toLowerCase();

  String _formatFieldTypeForUi(String raw) {
    if (raw.isEmpty) return raw;
    return raw
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  String _statusForApi(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized == 'available' || normalized == 'tersedia') {
      return 'available';
    }
    if (normalized == 'not available' || normalized == 'tidak tersedia') {
      return 'not available';
    }
    return normalized;
  }

  String _mapStatusForUi(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized == 'available' || normalized == 'tersedia') {
      return 'Available';
    }
    if (normalized == 'not available' || normalized == 'tidak tersedia') {
      return 'Not Available';
    }
    return raw;
  }

  String? get resolvedInitialPhotoUrl {
    final raw = initialPhotoUrl.value;
    if (raw.isEmpty) return null;
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
    openHourController.dispose();
    closeHourController.dispose();
    priceController.dispose();
    descController.dispose();
    maxPersonController.dispose();
    super.onClose();
  }

  Future<bool> deleteField() async {
    if (isDeleting.value) return false;

    final fieldId = _fieldId;
    if (fieldId == null) {
      Get.snackbar(
        'Data tidak ditemukan',
        'Identitas lapangan tidak tersedia.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final user = _sessionService.rememberedUser;
    if (user == null) {
      Get.snackbar(
        'Sesi berakhir',
        'Silakan masuk kembali untuk melanjutkan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isDeleting.value = true;
    try {
      final response = await _repository.deleteField(
        fieldId: fieldId,
        userId: user.id,
      );

      final message = response.message.isNotEmpty
          ? response.message
          : 'Data lapangan berhasil dihapus.';

      if (_homeController != null) {
        await _homeController.fetchFieldsForPlace(force: true);
      }

      Get.back(result: {'deleted': true, 'message': message});
      return true;
    } on FieldException catch (e) {
      Get.snackbar(
        'Gagal menghapus lapangan',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Gagal menghapus lapangan',
        'Terjadi kesalahan tak terduga. Coba lagi beberapa saat.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
