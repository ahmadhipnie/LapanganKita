import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../navigation/fieldmanager/tabs_controller/fieldmanager_home_controller.dart';
import '../../routes/app_routes.dart';
import 'place_form_controller.dart';

class PlaceFormView extends GetView<PlaceFormController> {
  const PlaceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Blue background
            Container(
              width: double.infinity,
              height: 450,
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
                        'Add Place',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Create a new place',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
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
                                  labelText: 'Place Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: controller.streetController,
                                decoration: const InputDecoration(
                                  labelText: 'Street',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: controller.cityController,
                                decoration: const InputDecoration(
                                  labelText: 'City',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: controller.provinceController,
                                decoration: const InputDecoration(
                                  labelText: 'Province',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Pictures Place',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Obx(() {
                                final image = controller.placeImage.value;
                                if (image != null) {
                                  return Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          image,
                                          width: 140,
                                          height: 140,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          tooltip: 'Remove photo',
                                          iconSize: 20,
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                          onPressed:
                                              controller.removePlaceImage,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return GestureDetector(
                                  onTap: controller.pickPlaceImage,
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
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
                                          'Upload photo',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 24),
                              const Divider(height: 32),
                              Obx(
                                () => SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  value: controller.isAddOnChecked.value,
                                  onChanged: (val) =>
                                      controller.isAddOnChecked.value = val,
                                  title: const Text('Tambahkan Add-Ons?'),
                                ),
                              ),
                              Obx(
                                () => controller.isAddOnChecked.value
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Form Add-On',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller:
                                                controller.addOnNameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Add-On Name',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller:
                                                controller.addOnPriceController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Price',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Obx(
                                            () => DropdownButtonFormField<String>(
                                              value: controller.addOnCategory.value,
                                              decoration: const InputDecoration(
                                                labelText: 'Category',
                                                border: OutlineInputBorder(),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'once time',
                                                  child: Text('Once Time'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'per hour',
                                                  child: Text('Per Hour'),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                if (value != null) {
                                                  controller.addOnCategory.value = value;
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller:
                                                controller.addOnQtyController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Stock',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller:
                                                controller.addOnDescController,
                                            decoration: const InputDecoration(
                                              labelText: 'Description',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Obx(() {
                                            final image =
                                                controller.addOnImage.value;
                                            if (image != null) {
                                              return Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child: Image.file(
                                                      image,
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () =>
                                                        controller
                                                                .addOnImage
                                                                .value =
                                                            null,
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      decoration:
                                                          const BoxDecoration(
                                                            color:
                                                                Colors.black54,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }

                                            return GestureDetector(
                                              onTap: controller.pickAddOnImage,
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.add_a_photo,
                                                  size: 28,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            );
                                          }),
                                          const SizedBox(height: 24),
                                        ],
                                      )
                                    : const SizedBox(),
                              ),
                              const SizedBox(height: 8),
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
                                            final isValid =
                                                controller.formKey.currentState
                                                    ?.validate() ??
                                                false;
                                            if (!isValid) return;

                                            FocusScope.of(context).unfocus();

                                            final success = await controller
                                                .submit();
                                            if (success) {
                                              final placeArg =
                                                  controller
                                                      .lastCreatedPlace
                                                      .value ??
                                                  (Get.isRegistered<
                                                        FieldManagerHomeController
                                                      >()
                                                      ? Get.find<
                                                              FieldManagerHomeController
                                                            >()
                                                            .place
                                                            .value
                                                      : null);
                                              Get.toNamed(
                                                AppRoutes.FIELD_ADD,
                                                arguments: {
                                                  if (placeArg != null)
                                                    'place': placeArg,
                                                  if (placeArg != null)
                                                    'placeId': placeArg.id,
                                                },
                                              );
                                            }
                                          },
                                    child: controller.isSubmitting.value
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            'Save',
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
