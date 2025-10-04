import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/field_model.dart';
import '../../data/models/place_model.dart';
import '../../data/repositories/field_repository.dart';
import '../../data/services/session_service.dart';
import '../../routes/app_routes.dart';
import '../navigation/fieldmanager/tabs_controller/fieldmanager_home_controller.dart';

class FieldAddController extends GetxController {
  FieldAddController({
    FieldRepository? repository,
    SessionService? sessionService,
  }) : _repository = repository ?? Get.find<FieldRepository>(),
       _sessionService = sessionService ?? Get.find<SessionService>();

  final FieldRepository _repository;
  final SessionService _sessionService;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final openHourController = TextEditingController();
  final closeHourController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final maxPersonController = TextEditingController();

  final fieldType = ''.obs;
  final fieldTypeList = const [
    'Futsal',
    'Mini Soccer',
    'Badminton',
    'Basket',
    'Tennis',
    'Voli',
    'Other',
  ];

  final Rx<File?> fieldPhoto = Rx<File?>(null);
  final isSubmitting = false.obs;
  final Rx<TimeOfDay?> _openTime = Rx<TimeOfDay?>(null);
  final Rx<TimeOfDay?> _closeTime = Rx<TimeOfDay?>(null);

  final ImagePicker _picker = ImagePicker();

  Future<void> pickFieldPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      fieldPhoto.value = File(picked.path);
    }
  }

  void removeFieldPhoto() {
    fieldPhoto.value = null;
  }

  Future<void> pickOpenHour(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _openTime.value ?? TimeOfDay.now(),
    );
    if (picked != null) {
      _openTime.value = picked;
      openHourController.text = picked.format(context);
    }
  }

  Future<void> pickCloseHour(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _closeTime.value ?? TimeOfDay.now(),
    );
    if (picked != null) {
      _closeTime.value = picked;
      closeHourController.text = picked.format(context);
    }
  }

  Future<bool> submit() async {
    if (isSubmitting.value) return false;

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return false;

    final user = _sessionService.rememberedUser;
    if (user == null) {
      Get.snackbar(
        'Session expired',
        'Please sign in again to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (_openTime.value == null || _closeTime.value == null) {
      Get.snackbar(
        'Operating hours incomplete',
        'Select both opening and closing times.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (fieldType.value.isEmpty) {
      Get.snackbar(
        'Field type required',
        'Choose a field type before continuing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final photo = fieldPhoto.value;
    if (photo == null) {
      Get.snackbar(
        'Photo missing',
        'Upload a field photo before submitting.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final price = _parseInt(priceController.text);
    if (price == null || price <= 0) {
      Get.snackbar(
        'Invalid price',
        'Enter a numeric price per hour.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final maxPerson = _parseInt(maxPersonController.text);
    if (maxPerson == null || maxPerson <= 0) {
      Get.snackbar(
        'Invalid capacity',
        'Enter a numeric value for max persons.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final place = _currentPlace();
    if (place == null) {
      Get.snackbar(
        'Place required',
        'Register your place before adding a field.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isSubmitting.value = true;
    try {
      final response = await _repository.createField(
        fieldName: nameController.text.trim(),
        openingTime: _formatTime(_openTime.value!),
        closingTime: _formatTime(_closeTime.value!),
        pricePerHour: price,
        description: descController.text.trim(),
        fieldType: fieldType.value.toLowerCase(),
        fieldPhoto: photo,
        status: 'available',
        maxPerson: maxPerson,
        placeId: place.id,
        userId: user.id,
      );

      final field = response.data;
      if (field != null) {
        _notifyFieldCreated(field);
      }

      Get.snackbar(
        'Field created',
        response.message.isNotEmpty
            ? response.message
            : 'The new field is ready for bookings.',
        snackPosition: SnackPosition.BOTTOM,
      );

      await Future.delayed(const Duration(milliseconds: 300));

      Get.offAllNamed(AppRoutes.FIELD_MANAGER_NAVIGATION);

      return true;
    } on FieldException catch (e) {
      Get.snackbar(
        'Failed to create field',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Failed to create field',
        'An unexpected error occurred. Please try again shortly.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  int? _parseInt(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  void _notifyFieldCreated(FieldModel field) {
    if (Get.isRegistered<FieldManagerHomeController>()) {
      final home = Get.find<FieldManagerHomeController>();
      home.addOrUpdateField(field);
    }
  }

  PlaceModel? _currentPlace() {
    if (Get.isRegistered<FieldManagerHomeController>()) {
      return Get.find<FieldManagerHomeController>().place.value;
    }
    return null;
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
