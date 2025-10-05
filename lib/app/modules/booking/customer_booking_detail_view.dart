import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_detail_controller.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/add_on_model.dart';
// import '../../data/models/customer/booking/court_model.dart';
import '../../data/network/api_client.dart';

class CustomerBookingDetailView
    extends GetView<CustomerBookingDetailController> {
  const CustomerBookingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        title: Text(
          controller.court.placeName,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        titleSpacing: 0,
        backgroundColor: AppColors.neutralColor, // atau warna lain dari theme
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshAddOns();
        },
        color: AppColors.primary,
        backgroundColor: AppColors.neutralColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              SizedBox(
                height: 350, // atur tinggi sesuai kebutuhan
                width: double.infinity,
                child: _buildCachedImage(controller.court.imageUrl),
              ),
              // Content section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildDescription(),
                    const SizedBox(height: 16),
                    _buildOpeningHours(),
                    const SizedBox(height: 16),
                    _buildDateTimeSelection(),
                    const SizedBox(height: 16),
                    _buildAddOnsSection(),
                    const SizedBox(height: 16),
                    _buildLocationMap(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildCachedImage(String imagePath) {
    final ApiClient apiClient = Get.find<ApiClient>();
    final imageUrl = apiClient.getImageUrl(imagePath);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Court Image',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.court.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              controller.court.location,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: controller.court.types
              .map(
                (type) => Chip(
                  label: Text(type, style: TextStyle(color: Colors.white)),
                  backgroundColor: AppColors.secondary,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          controller.court.description,
          textAlign: TextAlign.justify,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOpeningHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opening Hours',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Monday - Sunday',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              controller.court.openingHours['monday-sunday'] ?? "24 Hours",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Time & Duration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Date Picker
        _buildDatePicker(),
        const SizedBox(height: 16),

        // Duration Dropdown
        _buildDurationDropdown(),
        const SizedBox(height: 16),

        // Time Selection Grid
        _buildTimeGrid(),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(
          () => InkWell(
            onTap: () => _showDatePicker(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration (hours)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(
          () => DropdownButtonFormField<String>(
            dropdownColor: AppColors.neutralColor,
            initialValue: controller.selectedDuration.value,
            items: controller.durationOptions.map((duration) {
              return DropdownMenuItem(
                value: duration,
                child: Text('$duration hour${duration != "1" ? "s" : ""}'),
              );
            }).toList(),
            onChanged: (value) => controller.selectDuration(value!),
            decoration: InputDecoration(
              // Border saat normal
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue), // Warna biru
                borderRadius: BorderRadius.circular(4),
              ),
              // Border saat focused
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ), // Biru lebih tebal saat focus
                borderRadius: BorderRadius.circular(4),
              ),
              // Border default (fallback)
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue), // Warna biru
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeGrid() {
    final controller = Get.find<CustomerBookingDetailController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() {
          final selectedDuration = int.parse(controller.selectedDuration.value);

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.availableTimes.asMap().entries.map((entry) {
              final time = entry.value;

              // Cek apakah waktu ini dan durasi berikutnya tersedia
              final isAvailable = controller.isTimeAvailableWithDuration(
                time,
                selectedDuration,
              );
              final isSelected = controller.isTimeInSelectedRange(time);
              final isStartTime = controller.selectedStartTime.value == time;

              return FilterChip(
                label: Text(time),
                selected: isSelected,
                onSelected: isAvailable
                    ? (_) {
                        if (isStartTime) {
                          // Unselect jika sudah terpilih
                          controller.unselectStartTime();
                        } else {
                          // Select waktu baru
                          controller.selectStartTime(time);
                        }
                      }
                    : null,
                backgroundColor: isAvailable
                    ? Colors.grey[200]
                    : Colors.red[100],
                selectedColor: AppColors.secondary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isAvailable
                      ? Colors.black
                      : Colors.grey,
                ),
                disabledColor: AppColors.neutralColor,
                tooltip: isAvailable
                    ? null
                    : 'Not available for selected duration',
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            const Text('Available'),
            const SizedBox(width: 8),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: AppColors.neutralColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            const Text('Unavailable'),
            const SizedBox(width: 8),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            const Text('Selected'),
          ],
        ),
      ],
    );
  }

  Widget _buildAddOnItem(
    AddOnModel addOn,
    int quantity,
    bool isOutOfStock,
    int availableStock,
  ) {
    final ApiClient apiClient = Get.find<ApiClient>();
    final String imageUrl = addOn.photo != null && addOn.photo!.isNotEmpty
        ? apiClient.getImageUrl(addOn.photo!)
        : '';

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.local_offer,
                            size: 28,
                            color: Colors.grey,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.local_offer,
                            size: 28,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : const Icon(Icons.local_offer, size: 28, color: Colors.grey),
            ),
            const SizedBox(width: 12),

            // Content Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addOn.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    addOn.description,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? Colors.red[50]
                              : Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isOutOfStock ? Colors.red : Colors.green,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          isOutOfStock
                              ? 'Out of stock'
                              : 'Stock: $availableStock',
                          style: TextStyle(
                            fontSize: 11,
                            color: isOutOfStock ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Price and Quantity Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.formatRupiah(addOn.pricePerHour.toDouble()),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: quantity <= 0
                            ? null
                            : () => controller.decrementAddOn(addOn.name),
                        color: quantity <= 0 ? Colors.grey : AppColors.primary,
                      ),
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: isOutOfStock || availableStock <= 0
                            ? null
                            : () => controller.incrementAddOn(addOn.name),
                        color: (isOutOfStock || availableStock <= 0)
                            ? Colors.grey
                            : AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOnsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Obx(() {
          if (controller.court.placeId == 0) {
            return _buildPlaceIdNotAvailable();
          }

          if (controller.isLoadingAddOns.value) {
            return _buildLoadingAddOns();
          }

          if (controller.availableAddOns.isEmpty) {
            return _buildNoAddOnsAvailable();
          }

          return _buildAddOnsList();
        }),
      ],
    );
  }

  Widget _buildPlaceIdNotAvailable() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'Additional services not available for this court',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildLoadingAddOns() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(Get.context!).size.height * 0.3,
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text(
              'Loading additional services...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAddOnsAvailable() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No additional services available',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOnsList() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(Get.context!).size.height * 0.4,
      ),
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.availableAddOns.length,
        itemBuilder: (context, index) {
          final addOn = controller.availableAddOns[index];
          return Obx(() {
            final quantity = controller.getAddOnQuantity(addOn.name);
            final isOutOfStock = addOn.stock <= 0;
            final availableStock = addOn.stock - quantity;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildAddOnItem(
                addOn,
                quantity,
                isOutOfStock,
                availableStock,
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildLocationMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            // Tambahkan boxShadow untuk efek depth
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  "assets/images/map_bg.jpg",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  // Tambahkan error builder untuk handling jika image tidak ditemukan
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[200]),
                ),
              ),
              // Overlay gelap untuk kontras teks yang lebih baik
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.3), // Overlay transparan
                ),
              ),
              // Content di atas background
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 50, color: Colors.white),
                    const SizedBox(height: 12),
                    // Tampilkan alamat singkat
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        controller.court.location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _openMaps,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        // Tambahkan shadow pada button untuk kontras
                        elevation: 4,
                        // Tambahkan padding yang lebih nyaman
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Open in Google Maps',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.formatRupiah(controller.totalPrice.value),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Court: ${controller.formatRupiah(controller.court.price)} (1h x ${controller.formatRupiah(controller.court.price)})',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: controller.bookNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Book Now!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      controller.selectDate(picked);
    }
  }

  Future<void> _openMaps() async {
    // Pastikan controller.court.mapsUrl berisi link Google Maps
    // Contoh: "https://maps.app.goo.gl/N9VYw66ZFU7BD6cg8"
    final String mapsUrl = controller.court.mapsUrl;

    if (mapsUrl.isEmpty) {
      Get.snackbar(
        'Error',
        'Link Google Maps tidak tersedia',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final Uri mapsUri = Uri.parse(mapsUrl);

    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
      } else {
        Get.snackbar(
          'Error',
          'Tidak dapat membuka Google Maps',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
