import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_detail_controller.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerBookingDetailView
    extends GetView<CustomerBookingDetailController> {
  const CustomerBookingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            surfaceTintColor: AppColors.secondary,
            backgroundColor: AppColors.neutralColor,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                controller.court.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    color: Colors.grey[300],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        'Maybe image is not found or crash ><',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
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
                  _buildEquipmentRental(),
                  const SizedBox(height: 16),
                  _buildLocationMap(),
                  const SizedBox(height: 80), // Space untuk bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(),
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

  Widget _buildEquipmentRental() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Equipment Rental',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...controller.court.equipment.map((equipment) {
          return Obx(() {
            final quantity = controller.selectedEquipment[equipment.name] ?? 0;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(equipment.name),
              subtitle: Text(
                equipment.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.formatRupiah(equipment.price),
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: quantity > 0
                        ? () => controller.decrementEquipment(equipment.name)
                        : null,
                  ),
                  Text('$quantity', style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () =>
                        controller.incrementEquipment(equipment.name),
                  ),
                ],
              ),
            );
          });
        }),
      ],
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
