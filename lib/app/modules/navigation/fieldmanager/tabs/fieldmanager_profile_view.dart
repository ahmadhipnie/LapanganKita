import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

import '../tabs_controller/fieldmanager_profile_controller.dart';

class FieldManagerProfileView extends GetView<FieldManagerProfileController> {
  const FieldManagerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Profile Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  color: Color(0xFF2563EB),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Obx(
                          () => CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: c.avatarUrl.value.isNotEmpty
                                ? NetworkImage(c.avatarUrl.value)
                                : null,
                            child: c.avatarUrl.value.isEmpty
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
                                  c.name.value,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(
                                () => Text(
                                  c.email.value,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            Get.toNamed('/fieldmanager/edit-profile');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Account & Security
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 1,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF2563EB),
                        ),
                        title: const Text('My Account'),
                        subtitle: const Text('Make changes to your account'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Get.toNamed('/fieldmanager/edit-profile');
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
                          // Show confirmation dialog
                          showDialog(
                            context: context,
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
                // More Section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 1,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.help_outline,
                          color: Color(0xFF2563EB),
                        ),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                          color: Color(0xFF2563EB),
                        ),
                        title: const Text('About App'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
