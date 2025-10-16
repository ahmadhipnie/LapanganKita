import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../edit_profile_controller.dart';

class EditImageFieldView extends StatefulWidget {
  final String title;
  final String? currentImageUrl;
  final File? currentImageFile;
  final VoidCallback? onSave; // Keep this!
  final Function(File?)? onImageSelected;

  const EditImageFieldView({
    super.key,
    required this.title,
    this.currentImageUrl,
    this.currentImageFile,
    this.onSave,
    this.onImageSelected,
  });

  @override
  State<EditImageFieldView> createState() => _EditImageFieldViewState();
}

class _EditImageFieldViewState extends State<EditImageFieldView> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.currentImageFile;
  }

  Future<void> _pickImage({bool fromCamera = false}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        if (widget.onImageSelected != null) {
          widget.onImageSelected!(_selectedImage);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline, color: Colors.red),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });

    if (widget.onImageSelected != null) {
      widget.onImageSelected!(null);
    }
  }

  void _showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Wrap(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF2563EB),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                _pickImage(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2563EB)),
              title: const Text('Take a Photo'),
              onTap: () {
                Get.back();
                _pickImage(fromCamera: true);
              },
            ),
            if (widget.currentImageUrl?.isNotEmpty == true ||
                _selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  _removeImage();
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return CircleAvatar(
        radius: 80,
        backgroundImage: FileImage(_selectedImage!),
      );
    }

    if (widget.currentImageUrl?.isNotEmpty == true) {
      return CachedNetworkImage(
        imageUrl: widget.currentImageUrl!,
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(radius: 80, backgroundImage: imageProvider),
        placeholder: (context, url) => CircleAvatar(
          radius: 80,
          backgroundColor: Colors.grey[300],
          child: const CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: 80,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, size: 80, color: Colors.white),
        ),
      );
    }

    return CircleAvatar(
      radius: 80,
      backgroundColor: Colors.grey[300],
      child: const Icon(Icons.person, size: 80, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditProfileFieldmanagerController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Center(child: _buildImagePreview()),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showImagePickerOptions,
                icon: const Icon(Icons.photo_camera, color: Color(0xFF2563EB)),
                label: const Text(
                  'Select Photo',
                  style: TextStyle(color: Color(0xFF2563EB)),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Choose a profile photo from gallery or camera',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // Save Button - calls onSave which triggers saveProfile in controller
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          // Call onSave - controller handles Get.back() on success
                          if (widget.onSave != null) {
                            widget.onSave!();
                          }
                        },
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
