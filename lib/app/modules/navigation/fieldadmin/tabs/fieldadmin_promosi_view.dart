import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lapangan_kita/app/data/models/promosi_model.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_promosi_controller.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

class FieldadminPromosiView extends GetView<FieldadminPromosiController> {
  const FieldadminPromosiView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: c.isSubmitting.value
              ? null
              : () => _showCreatePromosiSheet(context, c),
          icon: c.isSubmitting.value
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.add_a_photo_outlined, color: Colors.white),
          label: const Text(
            'Add Promotion',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final isLoading = c.isLoading.value;
          final items = c.promosiItems;
          final error = c.errorMessage.value;

          if (isLoading && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (error.isNotEmpty && items.isEmpty) {
            return _ErrorState(message: error, onRetry: c.fetchPromosiList);
          }

          return RefreshIndicator(
            onRefresh: c.refreshPromosi,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                const _Header(),
                const SizedBox(height: 16),
                if (error.isNotEmpty)
                  _InfoBanner(
                    message: error,
                    icon: Icons.info_outline,
                    backgroundColor: const Color(0xFFFFF7ED),
                    iconColor: const Color(0xFFD97706),
                    textColor: const Color(0xFF92400E),
                  ),
                if (items.isEmpty)
                  const _EmptyState()
                else ...[
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _PromosiCard(item: item, controller: c),
                    ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Ads Field',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 4),
        Text(
          'Manage promotional materials to be displayed to users.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.message,
    this.icon = Icons.info_outline,
    this.backgroundColor = const Color(0xFFF0F9FF),
    this.iconColor = const Color(0xFF0284C7),
    this.textColor = const Color(0xFF075985),
  });

  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC2626)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(Icons.photo_library_outlined, size: 48, color: Colors.white),
          SizedBox(height: 12),
          Text(
            'There are no promotions yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Add promotional banners to attract users.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _PromosiCard extends StatelessWidget {
  const _PromosiCard({required this.item, required this.controller});

  final PromosiModel item;
  final FieldadminPromosiController controller;

  @override
  Widget build(BuildContext context) {
    final isDeleting = controller.isDeleting(item.id);
    final isUpdating = controller.isUpdating(item.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: item.filePhotoUrl.isNotEmpty
                  ? Image.network(
                      item.filePhotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF1F5F9),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.black38,
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.black26,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Updated ${item.formattedDate()}',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isUpdating
                      ? null
                      : () => _showEditPromosiSheet(context, controller, item),
                  icon: isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                  onPressed: isDeleting
                      ? null
                      : () => _confirmDelete(context, controller, item),
                  icon: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _showCreatePromosiSheet(
  BuildContext context,
  FieldadminPromosiController controller,
) {
  XFile? selectedFile;

  Get.bottomSheet(
    SafeArea(
      child: StatefulBuilder(
        builder: (context, setState) {
          return Obx(() {
            final isSubmitting = controller.isSubmitting.value;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Add Promotion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: isSubmitting
                        ? null
                        : () async {
                            final file = await controller.pickImage();
                            if (file != null) {
                              setState(() => selectedFile = file);
                            }
                          },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(selectedFile!.path),
                                fit: BoxFit.cover,
                                height: 160,
                                width: double.infinity,
                              ),
                            )
                          else ...[
                            const Icon(
                              Icons.cloud_upload_outlined,
                              size: 40,
                              color: Colors.black26,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isSubmitting
                                  ? 'Processing upload...'
                                  : 'Tap to select promotion image',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting ? null : Get.back,
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting || selectedFile == null
                              ? null
                              : () async {
                                  final success = await controller
                                      .createPromosi(selectedFile!);
                                  if (success) {
                                    if (Get.isBottomSheetOpen ?? false) {
                                      Get.back();
                                    }
                                    Get.snackbar(
                                      'Promotion Added',
                                      'New promotion created successfully.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFDCFCE7),
                                      colorText: const Color(0xFF14532D),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        },
      ),
    ),
    isScrollControlled: true,
  );
}

void _showEditPromosiSheet(
  BuildContext context,
  FieldadminPromosiController controller,
  PromosiModel item,
) {
  XFile? selectedFile;

  Get.bottomSheet(
    SafeArea(
      child: StatefulBuilder(
        builder: (context, setState) {
          return Obx(() {
            final isUpdating = controller.isUpdating(item.id);
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Edit Promotion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: isUpdating
                        ? null
                        : () async {
                            final file = await controller.pickImage();
                            if (file != null) {
                              setState(() => selectedFile = file);
                            }
                          },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(selectedFile!.path),
                                fit: BoxFit.cover,
                                height: 160,
                                width: double.infinity,
                              ),
                            )
                          else if (item.filePhotoUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.filePhotoUrl,
                                fit: BoxFit.cover,
                                height: 160,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFF1F5F9),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                            )
                          else ...[
                            const Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: Colors.black26,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap to select new image',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isUpdating ? null : Get.back,
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isUpdating
                              ? null
                              : () async {
                                  if (selectedFile == null) {
                                    Get.snackbar(
                                      'Image not selected',
                                      'Please select a new image before saving.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFFFF7ED),
                                      colorText: const Color(0xFF92400E),
                                    );
                                    return;
                                  }

                                  final success = await controller
                                      .updatePromosi(
                                        item.id,
                                        file: selectedFile,
                                      );
                                  if (success) {
                                    if (Get.isBottomSheetOpen ?? false) {
                                      Get.back();
                                    }
                                    Get.snackbar(
                                      'Promotion Updated',
                                      'Promotion banner updated successfully.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFDCFCE7),
                                      colorText: const Color(0xFF14532D),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: isUpdating
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        },
      ),
    ),
    isScrollControlled: true,
  );
}

void _confirmDelete(
  BuildContext context,
  FieldadminPromosiController controller,
  PromosiModel item,
) {
  Get.dialog(
    AlertDialog(
      title: const Text('Delete Promotion?'),
      content: const Text(
        'This action will delete the promotion banner and cannot be undone.',
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        Obx(() {
          final isDeleting = controller.isDeleting(item.id);
          return TextButton(
            onPressed: isDeleting
                ? null
                : () async {
                    final success = await controller.deletePromosi(item.id);
                    if (success) {
                      if (Get.isDialogOpen ?? false) {
                        Get.back();
                      }
                      Get.snackbar(
                        'Promotion Deleted',
                        'Promotion banner has been deleted.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFFFECACA),
                        colorText: const Color(0xFF7F1D1D),
                      );
                    }
                  },
            child: isDeleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Delete', style: TextStyle(color: Colors.red.shade700)),
          );
        }),
      ],
    ),
  );
}
