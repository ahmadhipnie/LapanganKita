import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/profile/customer_profile_controller.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

import '../edit_profile_fieldmanager/edit_fields/change_password_view.dart';

class CustomerProfileView extends GetView<CustomerProfileController> {
  const CustomerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        centerTitle: false,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: AppColors.neutralColor,
      body: Obx(() {
        // Show loading indicator during logout or data loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    color: const Color(0xFF2563EB),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Obx(
                            () => CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.grey[300],
                              backgroundImage:
                                  controller.avatarUrl.value.isNotEmpty
                                  ? NetworkImage(controller.avatarUrl.value)
                                  : null,
                              child: controller.avatarUrl.value.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                  () => Text(
                                    controller.name.value.isEmpty
                                        ? 'Loading...'
                                        : controller.name.value,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(
                                  () => Text(
                                    controller.email.value.isEmpty
                                        ? 'Loading...'
                                        : controller.email.value,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () async {
                              // Navigate and wait for result
                              await Get.toNamed('/fieldmanager/edit-profile');

                              // Reload data when returning (regardless of result)
                              // This ensures fresh data from API
                              controller.reloadUserData();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Account & Security
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF2563EB),
                          ),
                          title: const Text('Change Password'),
                          subtitle: const Text('Update your password'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Get.to(() => const ChangePasswordView());
                          },
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Log out'),
                          subtitle: const Text(
                            'Further secure your account for safety',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible:
                                  false, // Prevent dismiss during logout
                              builder: (ctx) => AlertDialog(
                                title: const Text('Log out'),
                                content: const Text(
                                  'Are you sure you want to log out?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      Navigator.of(ctx).pop();
                                      await controller.logout();
                                    },
                                    child: const Text('Log out'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
