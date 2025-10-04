import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'field_add_controller.dart';

class FieldAddView extends GetView<FieldAddController> {
  const FieldAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Field'),
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
                        'Add New Field',
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
                              Obx(
                                () => DropdownButtonFormField<String>(
                                  value: controller.fieldType.value.isEmpty
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
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
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
                              Obx(() {
                                final photo = controller.fieldPhoto.value;
                                return Row(
                                  children: [
                                    if (photo != null)
                                      Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          GestureDetector(
                                            onTap: controller.pickFieldPhoto,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                photo,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed:
                                                  controller.removeFieldPhoto,
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      GestureDetector(
                                        onTap: controller.pickFieldPhoto,
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF2563EB),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.add_a_photo,
                                                size: 32,
                                                color: Color(0xFF2563EB),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Upload Photo',
                                                style: TextStyle(
                                                  color: Color(0xFF2563EB),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }),
                              const SizedBox(height: 24),
                              Obx(
                                () => SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: controller.isSubmitting.value
                                        ? null
                                        : () async {
                                            await controller.submit();
                                          },
                                    child: controller.isSubmitting.value
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            'Save Field',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
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
