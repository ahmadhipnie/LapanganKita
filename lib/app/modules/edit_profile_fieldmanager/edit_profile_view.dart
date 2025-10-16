import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';
import 'edit_fields/edit_image_view.dart';
import 'edit_profile_controller.dart';
import 'edit_fields/edit_field_view.dart';

class EditProfileFieldmanagerView
    extends GetView<EditProfileFieldmanagerController> {
  const EditProfileFieldmanagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Updating profile...'),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
          children: [
            Center(
              child: Column(
                children: [
                  Obx(() {
                    // Preview newly selected file
                    if (controller.selectedPhotoFile.value != null) {
                      return CircleAvatar(
                        radius: 60,
                        backgroundImage: FileImage(
                          controller.selectedPhotoFile.value!,
                        ),
                      );
                    }
                    // Display photo from server
                    else if (controller.photoProfileUrl.isNotEmpty) {
                      return CachedNetworkImage(
                        imageUrl: controller.photoProfileUrl,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 60,
                          backgroundImage: imageProvider,
                        ),
                        placeholder: (context, url) => CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          child: const CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) {
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          );
                        },
                      );
                    }
                    // Default avatar
                    return CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Get.to(
                      () => EditImageFieldView(
                        title: 'Profile Photo',
                        currentImageUrl: controller.photoProfileUrl,
                        currentImageFile: controller.selectedPhotoFile.value,
                        onImageSelected: (file) {
                          controller.selectedPhotoFile.value = file;
                        },
                        onSave: controller.saveProfile,
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Email text display
                  Text(
                    controller.emailController.text,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileItem(
              context,
              icon: Icons.person_outline,
              title: 'Name',
              value: controller.nameController.text,
              onTap: () => Get.to(
                () => EditFieldView(
                  title: 'Name',
                  hint: 'Your Name',
                  controller: controller.nameController,
                  maxLength: 25,
                  helperText: 'Change your display name',
                  onSave: controller.saveProfile,
                ),
              ),
            ),
            _buildProfileItem(
              context,
              icon: Icons.phone_outlined,
              title: 'Phone Number',
              value: controller.phoneController.text.isEmpty
                  ? 'Not set yet'
                  : controller.phoneController.text,
              onTap: () => Get.to(
                () => EditFieldView(
                  title: 'Phone Number',
                  hint: 'Enter your phone number',
                  helperText: 'Max 13 digits (e.g., 081234567890)',
                  controller: controller.phoneController,
                  keyboardType:
                      TextInputType.number, // Changed from TextInputType.phone
                  maxLength: 13, // Add this
                  onSave: controller.saveProfile,
                ),
              ),
            ),

            _buildProfileItem(
              context,
              icon: Icons.wc_outlined,
              title: 'Gender',
              value: controller.genderController.text,
              onTap: () => Get.to(
                () => EditFieldView(
                  title: 'Gender',
                  hint: 'Choose your gender',
                  helperText: 'Specify your gender',
                  controller: controller.genderController,
                  isGender: true,
                  onSave: controller.saveProfile,
                ),
              ),
            ),
            _buildProfileItem(
              context,
              icon: Icons.location_on_outlined,
              title: 'Address',
              value: controller.addressController.text,
              onTap: () => Get.to(
                () => EditFieldView(
                  title: 'Address',
                  hint: 'Address',
                  helperText: 'Specify your address',
                  isAddress: true,
                  streetController: controller.streetController,
                  cityController: controller.cityController,
                  provinceController: controller.provinceController,
                  onSave: controller.saveProfile,
                ),
              ),
            ),
            _buildProfileItem(
              context,
              icon: Icons.cake_outlined,
              title: 'Birthdate',
              value: controller.birthdateController.text,
              onTap: () => Get.to(
                () => EditFieldView(
                  title: 'Birthdate',
                  hint: 'Choose your birthdate',
                  controller: controller.birthdateController,
                  isBirthdate: true,
                  onSave: controller.saveProfile,
                ),
              ),
            ),
            _buildProfileItem(
              context,
              icon: Icons.account_balance_outlined,
              title: 'Account Number',
              value: controller.accountNumberController.text,
              onTap: () => Get.to(
                () => EditFieldView(
                  title: 'Account Number',
                  hint: 'Account Number',
                  helperText: 'Enter your bank account number',
                  controller: controller.accountNumberController,
                  keyboardType: TextInputType.number,
                  onSave: controller.saveProfile,
                ),
              ),
            ),
            _buildProfileItem(
              context,
              icon: Icons.account_balance,
              title: 'Bank Type',
              value: controller.bankTypeController.text,
              onTap: () => Get.to(
                () => EditFieldView(
                  title: 'Bank Type',
                  hint: 'Choose your bank type',
                  helperText: 'Enter your bank type',
                  controller: controller.bankTypeController,
                  isBankType: true,
                  onSave: controller.saveProfile,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondary),
      title: Text(title),
      subtitle: Text(value.isNotEmpty ? value : '-'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
