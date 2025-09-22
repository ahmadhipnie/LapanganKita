import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_field_fieldmanager_controller.dart';

class EditFieldFieldmanagerView
    extends GetView<EditFieldFieldmanagerController> {
  const EditFieldFieldmanagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Field'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Blue background
            Container(
              width: double.infinity,
              height: 220,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
            // Form content
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Title
                  Column(
                    children: [
                      const Text(
                        'Edit Field',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: controller.nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Field Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              // Status dropdown
                              DropdownButtonFormField<String>(
                                value: controller.status.value.isEmpty
                                    ? null
                                    : controller.status.value,
                                items: controller.statusList
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    controller.status.value = v ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: controller.openHourController,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Open Hour',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.access_time),
                                      ),
                                      onTap: () =>
                                          controller.pickOpenHour(context),
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                          controller.closeHourController,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Close Hour',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.access_time),
                                      ),
                                      onTap: () =>
                                          controller.pickCloseHour(context),
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: controller.priceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Price per Hour',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: controller.maxPersonController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Max Person',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                initialValue: controller.fieldType.value.isEmpty
                                    ? null
                                    : controller.fieldType.value,
                                items: controller.fieldTypeList
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    controller.fieldType.value = v ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Field Type',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: controller.descController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Field Photos',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Obx(
                                () => Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ...controller.images.map(
                                      (img) => Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              img,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  controller.removeImage(img),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: controller.pickImages,
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_a_photo,
                                          size: 32,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Delete button
                              SizedBox(
                                height: 44,
                                child: OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    'Delete Field',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: const Text(
                                          'Are you sure you want to delete this field?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      controller.deleteField();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (controller.formKey.currentState
                                            ?.validate() ??
                                        false) {
                                      // TODO: Implement update logic
                                      Get.back();
                                      Get.snackbar(
                                        'Success',
                                        'Field updated successfully!',
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Update',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
