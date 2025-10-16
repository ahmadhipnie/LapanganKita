import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lapangan_kita/app/data/models/user_model.dart';
import 'package:lapangan_kita/app/data/repositories/auth_repository.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';
import '../../data/models/edit_profile_request.dart';

class EditProfileFieldmanagerController extends GetxController {
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final AuthRepository _authRepository = Get.find();
  final ApiClient _apiClient = Get.find();
  final ImagePicker _imagePicker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final birthdateController = TextEditingController();
  final accountNumberController = TextEditingController();
  final bankTypeController = TextEditingController();
  final phoneController = TextEditingController();

  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final provinceController = TextEditingController();
  final roleController = TextEditingController();

  final Rxn<UserModel> currentUser = Rxn();
  final isLoading = false.obs;
  final Rxn<File> selectedPhotoFile = Rxn();

  // Gunakan getImageUrl dari ApiClient
  String get photoProfileUrl {
    if (currentUser.value?.photoProfil != null &&
        currentUser.value!.photoProfil!.isNotEmpty) {
      return _apiClient.getImageUrl(currentUser.value!.photoProfil!);
    }
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    if (_localStorage.getUserData() == null) {
      _setDefaultValues();
      return;
    }

    final userData = _localStorage.getUserData();
    if (userData != null) {
      try {
        currentUser.value = UserModel.fromJson(userData);
        _populateFormFields(userData);
      } catch (e) {
        _setDefaultValues();
      }
    } else {
      _setDefaultValues();
    }
  }

  void _populateFormFields(Map<String, dynamic> userData) {
    nameController.text = userData['name']?.toString() ?? '';
    emailController.text = userData['email']?.toString() ?? '';
    genderController.text = userData['gender']?.toString() ?? '';

    final address = userData['address']?.toString() ?? '';
    addressController.text = address;
    _parseAddress(address);

    final dob = userData['date_of_birth'];
    if (dob != null) {
      final date = DateTime.tryParse(dob.toString());
      if (date != null) {
        birthdateController.text =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    }

    accountNumberController.text = userData['account_number']?.toString() ?? '';
    bankTypeController.text = userData['bank_type']?.toString() ?? '';
    roleController.text = userData['role']?.toString() ?? '';
    phoneController.text = userData['nomor_telepon']?.toString() ?? '';
  }

  void _parseAddress(String address) {
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
    phoneController.text = '';
  }

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

  Future<void> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedPhotoFile.value = File(image.path);
        Get.snackbar('Success', 'Photo selected. Click Save to upload.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  void removePhoto() {
    selectedPhotoFile.value = null;
    if (currentUser.value != null) {
      currentUser.value = UserModel(
        id: currentUser.value!.id,
        name: currentUser.value!.name,
        email: currentUser.value!.email,
        gender: currentUser.value!.gender,
        address: currentUser.value!.address,
        dateOfBirth: currentUser.value!.dateOfBirth,
        accountNumber: currentUser.value!.accountNumber,
        bankType: currentUser.value!.bankType,
        nomorTelepon: currentUser.value!.nomorTelepon,
        photoProfil: null,
        role: currentUser.value!.role,
        isVerified: currentUser.value!.isVerified,
        createdAt: currentUser.value!.createdAt,
        updatedAt: currentUser.value!.updatedAt,
      );
    }
    Get.snackbar('Success', 'Photo removed');
  }

  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                pickImage(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Get.back();
                pickImage(fromCamera: true);
              },
            ),
            if (photoProfileUrl.isNotEmpty || selectedPhotoFile.value != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> saveProfile() async {
    updateAddress();
    if (currentUser.value == null) {
      Get.snackbar(
        'Error',
        'User data not found',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline, color: Colors.red),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Validate birthdate format before saving
    final formattedDate = _formatDateForApi(birthdateController.text);
    if (birthdateController.text.isNotEmpty && formattedDate == null) {
      Get.snackbar(
        'Invalid Date',
        'Please enter a valid birthdate in DD/MM/YYYY format',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        icon: const Icon(Icons.warning, color: Colors.orange),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;
    try {
      final request = UpdateProfileRequest(
        name: nameController.text,
        email: emailController.text,
        gender: genderController.text.isEmpty ? null : genderController.text,
        address: addressController.text.isEmpty ? null : addressController.text,
        dateOfBirth: formattedDate,
        accountNumber: accountNumberController.text.isEmpty
            ? null
            : accountNumberController.text,
        bankType: bankTypeController.text.isEmpty
            ? null
            : bankTypeController.text,
        nomorTelepon: phoneController.text.isEmpty
            ? null
            : phoneController.text,
        photoProfil: currentUser.value!.photoProfil,
        role: roleController.text,
      );

      final response = await _authRepository.updateProfile(
        userId: currentUser.value!.id,
        request: request,
        photoFile: selectedPhotoFile.value,
      );

      if (response.success && response.user != null) {
        await _localStorage.saveUserData(response.user!.toJson());
        currentUser.value = response.user;
        selectedPhotoFile.value = null;

        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(result: true);

        Get.snackbar(
          'Profile Updated',
          'Your profile has been updated successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
          duration: const Duration(seconds: 2),
        );
      } else {
        // Even if success is true, check if user data is null
        throw AuthException(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update profile',
        );
      }
    } on AuthException catch (e) {
      Get.snackbar(
        'Update Failed',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline, color: Colors.red),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        'Something went wrong. Please try again',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline, color: Colors.red),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? _formatDateForApi(String date) {
    if (date.isEmpty) return null;

    try {
      // Format: DD/MM/YYYY -> YYYY-MM-DD
      final parts = date.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        // Validate date ranges
        if (day < 1 || day > 31) {
          return null;
        }
        if (month < 1 || month > 12) {
          return null;
        }
        if (year < 1900 || year > DateTime.now().year) {
          return null;
        }

        // Create DateTime to validate the date is real (e.g., not Feb 31)
        try {
          final dateTime = DateTime(year, month, day);

          // Double check the date didn't overflow (e.g., Feb 31 became Mar 3)
          if (dateTime.day != day ||
              dateTime.month != month ||
              dateTime.year != year) {
            return null;
          }

          // Format to API format: YYYY-MM-DD
          final formatted =
              '${year.toString().padLeft(4, '0')}-'
              '${month.toString().padLeft(2, '0')}-'
              '${day.toString().padLeft(2, '0')}';

          return formatted;
        } catch (e) {
          return null;
        }
      }
    } catch (e) {
      return null;
    }

    return null;
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
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    provinceController.dispose();
    roleController.dispose();
    super.onClose();
  }
}
