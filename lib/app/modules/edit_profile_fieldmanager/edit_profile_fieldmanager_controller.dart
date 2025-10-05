import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/models/user_model.dart';
import 'package:lapangan_kita/app/data/repositories/auth_repository.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

import '../../data/models/edit_profile_request.dart';
import '../navigation/fieldmanager/tabs_controller/fieldmanager_profile_controller.dart';
import '../profile/customer_profile_controller.dart';

class EditProfileFieldmanagerController extends GetxController {
  final LocalStorageService _localStorage = LocalStorageService();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final birthdateController = TextEditingController();
  final accountNumberController = TextEditingController();
  final bankTypeController = TextEditingController();

  // For address fields
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final roleController = TextEditingController();

  // User data
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    final userData = _localStorage.getUserData();
    if (userData != null) {
      try {
        currentUser.value = UserModel.fromJson(userData);
        _populateFormFields(userData);
      } catch (e) {
        // print('Error loading user data: $e');
        _setDefaultValues();
      }
    } else {
      _setDefaultValues();
    }
  }

  void _populateFormFields(Map<String, dynamic> userData) {
    // Name and Email
    nameController.text = userData['name']?.toString() ?? '';
    emailController.text = userData['email']?.toString() ?? '';

    // Gender
    genderController.text = userData['gender']?.toString() ?? '';

    // Address
    final address = userData['address']?.toString() ?? '';
    addressController.text = address;
    _parseAddress(address);

    // Date of Birth
    final dob = userData['date_of_birth'];
    if (dob != null) {
      final date = DateTime.tryParse(dob.toString());
      if (date != null) {
        birthdateController.text =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    }

    // Bank Information
    accountNumberController.text = userData['account_number']?.toString() ?? '';
    bankTypeController.text = userData['bank_type']?.toString() ?? '';
    roleController.text = userData['role']?.toString() ?? '';
  }

  void _parseAddress(String address) {
    // Simple address parsing
    final parts = address.split(',');
    if (parts.length >= 3) {
      streetController.text = parts[0].trim();
      cityController.text = parts[1].trim();
      provinceController.text = parts[2].trim();
    } else if (parts.length == 2) {
      streetController.text = parts[0].trim();
      cityController.text = parts[1].trim();
      provinceController.text = '';
    } else if (parts.length == 1) {
      streetController.text = address;
      cityController.text = '';
      provinceController.text = '';
    }
  }

  void _setDefaultValues() {
    // Fallback values jika tidak ada data
    nameController.text = 'Nama Fieldmanager';
    emailController.text = 'email@domain.com';
    genderController.text = 'Male';
    addressController.text = 'Jl. Mawar, Jakarta, DKI Jakarta';
    birthdateController.text = '01/01/1990';
    accountNumberController.text = '1234567890';
    bankTypeController.text = 'BCA';
    streetController.text = 'Jl. Mawar';
    cityController.text = 'Jakarta';
    provinceController.text = 'DKI Jakarta';
    roleController.text = 'field_manager';
  }

  // Update address controller when address fields change
  void updateAddress() {
    final street = streetController.text.trim();
    final city = cityController.text.trim();
    final province = provinceController.text.trim();

    final addressParts = [
      street,
      city,
      province,
    ].where((part) => part.isNotEmpty).toList();
    addressController.text = addressParts.join(', ');
  }

  // ✅ UPDATE METHOD SAVE PROFILE DENGAN API
  Future<void> saveProfile() async {
    // Update the address before saving
    updateAddress();

    if (currentUser.value == null) {
      Get.snackbar('Error', 'User data not found');
      return;
    }

    isLoading.value = true;

    try {
      final request = UpdateProfileRequest(
        name: nameController.text,
        email: emailController.text,
        gender: genderController.text.isEmpty ? null : genderController.text,
        address: addressController.text.isEmpty ? null : addressController.text,
        dateOfBirth: _formatDateForApi(birthdateController.text),
        accountNumber: accountNumberController.text.isEmpty
            ? null
            : accountNumberController.text,
        bankType: bankTypeController.text.isEmpty
            ? null
            : bankTypeController.text,
        role: roleController.text,
      );

      final response = await _authRepository.updateProfile(
        userId: currentUser.value!.id,
        request: request,
      );

      if (response.success && response.user != null) {
        // Update local storage dengan data terbaru dari API
        await _localStorage.saveUserData(response.user!.toJson());
        currentUser.value = response.user;

        _refreshProfileController();

        Get.snackbar('Success', response.message);
        await Future.delayed(const Duration(milliseconds: 1500));

        Get.back();
      } else {
        throw AuthException(response.message);
      }
    } on AuthException catch (e) {
      Get.snackbar('Update Failed', e.message);
    } catch (e) {
      Get.snackbar('Update Failed', 'Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _refreshProfileController() {
    try {
      // Cari instance FieldManagerProfileController yang aktif
      final fieldAdminProfileController =
          Get.find<FieldManagerProfileController>();
      fieldAdminProfileController.reloadUserData();
    } catch (e) {
      // Jika controller belum ada, tidak perlu dilakukan apa-apa
      // print('Profile controller not found: $e');
    }

    try {
      final customerProfileController = Get.find<CustomerProfileController>();
      customerProfileController.reloadUserData();
    } catch (e) {
      // Jika controller belum ada, tidak perlu dilakukan apa-apa
      // print('Customer Profile controller not found: $e');
    }
  }

  String? _formatDateForApi(String date) {
    if (date.isEmpty) return null;
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    } catch (e) {
      // print('Error formatting date: $e');
    }
    return null;
  }

  // Format date for display
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    genderController.dispose();
    addressController.dispose();
    birthdateController.dispose();
    accountNumberController.dispose();
    bankTypeController.dispose();
    streetController.dispose();
    cityController.dispose();
    provinceController.dispose();
    roleController.dispose();
    super.onClose();
  }
}
