import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';
import 'edit_profile_fieldmanager_controller.dart';
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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: AppColors.secondary),
                  ),
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
            icon: Icons.email_outlined,
            title: 'Email',
            value: controller.emailController.text,
            onTap: () => Get.to(
              () => EditFieldView(
                title: 'Email',
                hint: 'Email',
                helperText: 'Change your email address',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
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
                hint: 'Pilih Jenis Kelamin',
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
                hint: 'Pilih Jenis Bank',
                helperText: 'Enter your bank type',
                controller: controller.bankTypeController,
                isBankType: true,
                onSave: controller.saveProfile,
              ),
            ),
          ),
        ],
      ),
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
