import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/profile/customer_profile_controller.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

class CustomerProfileView extends GetView<CustomerProfileController> {
  const CustomerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.neutralColor,
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  color: AppColors.primary,
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
                                  controller.name.value,
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
                                  controller.username.value,
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
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Account & Security
                Card(
                  color: AppColors.neutralColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 1,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                          color: AppColors.secondary,
                        ),
                        title: const Text('My Account'),
                        subtitle: const Text('Make changes to your account'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.secondary,
                        ),
                        title: const Text('Saved Beneficiary'),
                        subtitle: const Text('Manage your saved account'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 0),
                      Obx(
                        () => SwitchListTile.adaptive(
                          activeThumbColor: AppColors.secondary,
                          inactiveTrackColor: Colors.grey[300],
                          secondary: const Icon(
                            Icons.fingerprint,
                            color: AppColors.secondary,
                          ),
                          title: const Text('Face ID / Touch ID'),
                          subtitle: const Text('Manage your device security'),
                          value: controller.faceIdEnabled.value,
                          onChanged: (val) =>
                              controller.faceIdEnabled.value = val,
                        ),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(
                          Icons.security_outlined,
                          color: AppColors.secondary,
                        ),
                        title: const Text('Two-Factor Authentication'),
                        subtitle: const Text(
                          'Further secure your account for safety',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
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
                                  ),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    // TODO: Implement logout logic
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
                  color: AppColors.neutralColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 1,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.help_outline,
                          color: AppColors.secondary,
                        ),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                          color: AppColors.secondary,
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
