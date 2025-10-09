import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_detail_controller.dart';
import 'package:lapangan_kita/app/modules/booking/webview_maps.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

import '../../data/models/add_on_model.dart';
import '../../data/models/customer/rating/rating_model.dart';
import '../../data/network/api_client.dart';

class CustomerBookingDetailView
    extends GetView<CustomerBookingDetailController> {
  const CustomerBookingDetailView({super.key});

  // PERBAIKAN: Tambahkan responsive helper methods
  double get _screenWidth => MediaQuery.of(Get.context!).size.width;
  double get _screenHeight => MediaQuery.of(Get.context!).size.height;
  bool get _isSmallScreen => _screenWidth < 600;
  // bool get _isLargeScreen => _screenWidth > 1200;
  double get _responsivePadding => _isSmallScreen ? 16.0 : 24.0;
  double get _responsiveImageHeight => _isSmallScreen ? 350 : 400;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        title: Text(
          controller.court.placeName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: _isSmallScreen
                ? 18
                : 20, // PERBAIKAN: Font size responsif
          ),
        ),
        titleSpacing: 0,
        backgroundColor: AppColors.neutralColor,
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
              // Image section - PERBAIKAN: Height responsif
              SizedBox(
                height: _responsiveImageHeight,
                width: double.infinity,
                child: _buildCachedImage(controller.court.imageUrl),
              ),
              // Content section - PERBAIKAN: Padding responsif
              Padding(
                padding: EdgeInsets.all(_responsivePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: _responsivePadding),
                    _buildDescription(),
                    SizedBox(height: _responsivePadding),
                    _buildOpeningHours(),
                    SizedBox(height: _responsivePadding),
                    _buildDateTimeSelection(),
                    SizedBox(height: _responsivePadding),
                    _buildAddOnsSection(),
                    SizedBox(height: _responsivePadding),
                    _buildLocationMap(),
                    SizedBox(height: _responsivePadding),
                    _buildRatingsSummary(),
                    SizedBox(height: _responsivePadding),
                    _buildReviewsSection(),
                    SizedBox(height: 60),
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
            Icon(
              Icons.sports_soccer,
              size: _isSmallScreen ? 60 : 80, // PERBAIKAN: Icon size responsif
              color: Colors.grey[400],
            ),
            SizedBox(height: _isSmallScreen ? 12 : 16),
            Text(
              'Court Image',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: _isSmallScreen
                    ? 16
                    : 18, // PERBAIKAN: Font size responsif
              ),
            ),
            SizedBox(height: _isSmallScreen ? 8 : 12),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: _isSmallScreen
                    ? 14
                    : 16, // PERBAIKAN: Font size responsif
              ),
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
          style: TextStyle(
            fontSize: _isSmallScreen
                ? 24
                : 28, // PERBAIKAN: Font size responsif
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: _isSmallScreen ? 8 : 12),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: _isSmallScreen ? 16 : 18, // PERBAIKAN: Icon size responsif
              color: Colors.grey,
            ),
            SizedBox(width: _isSmallScreen ? 4 : 6),
            Expanded(
              child: Text(
                controller.court.location,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: _isSmallScreen
                      ? 14
                      : 16, // PERBAIKAN: Font size responsif
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: _isSmallScreen ? 8 : 12),
        Wrap(
          spacing: _isSmallScreen ? 8 : 12, // PERBAIKAN: Spacing responsif
          runSpacing: _isSmallScreen ? 8 : 12,
          children: controller.court.types
              .map(
                (type) => Chip(
                  label: Text(
                    type,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _isSmallScreen
                          ? 12
                          : 14, // PERBAIKAN: Font size responsif
                    ),
                  ),
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
        Text(
          'Description',
          style: TextStyle(
            fontSize: _isSmallScreen
                ? 18
                : 20, // PERBAIKAN: Font size responsif
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: _isSmallScreen ? 8 : 12),
        Text(
          controller.court.description,
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: _isSmallScreen
                ? 14
                : 16, // PERBAIKAN: Font size responsif
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildOpeningHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opening Hours',
          style: TextStyle(
            fontSize: _isSmallScreen
                ? 18
                : 20, // PERBAIKAN: Font size responsif
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: _isSmallScreen ? 8 : 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Monday - Sunday',
              style: TextStyle(
                fontSize: _isSmallScreen
                    ? 14
                    : 16, // PERBAIKAN: Font size responsif
                color: Colors.grey,
              ),
            ),
            Text(
              controller.court.openingHours['monday-sunday'] ?? "24 Hours",
              style: TextStyle(
                fontSize: _isSmallScreen
                    ? 14
                    : 16, // PERBAIKAN: Font size responsif
                color: Colors.grey,
              ),
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
        Text(
          'Select Time & Duration',
          style: TextStyle(
            fontSize: _isSmallScreen
                ? 18
                : 20, // PERBAIKAN: Font size responsif
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: _isSmallScreen ? 16 : 20),

        // Date Picker
        _buildDatePicker(),
        SizedBox(height: _isSmallScreen ? 16 : 20),

        // Duration Dropdown
        _buildDurationDropdown(),
        SizedBox(height: _isSmallScreen ? 16 : 20),

        // Time Selection Grid
        _buildTimeGrid(),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _isSmallScreen
                ? 14
                : 16, // PERBAIKAN: Font size responsif
          ),
        ),
        SizedBox(height: _isSmallScreen ? 8 : 12),
        Obx(
          () => InkWell(
            onTap: () => _showDatePicker(),
            child: Container(
              padding: EdgeInsets.all(
                _isSmallScreen ? 12 : 16,
              ), // PERBAIKAN: Padding responsif
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                    style: TextStyle(
                      fontSize: _isSmallScreen
                          ? 16
                          : 18, // PERBAIKAN: Font size responsif
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: _isSmallScreen
                        ? 20
                        : 24, // PERBAIKAN: Icon size responsif
                  ),
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
        Text(
          'Duration (hours)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _isSmallScreen
                ? 14
                : 16, // PERBAIKAN: Font size responsif
          ),
        ),
        SizedBox(height: _isSmallScreen ? 8 : 12),
        Obx(
          () => DropdownButtonFormField<String>(
            dropdownColor: AppColors.neutralColor,
            initialValue: controller.selectedDuration.value,
            items: controller.durationOptions.map((duration) {
              return DropdownMenuItem(
                value: duration,
                child: Text(
                  '$duration hour${duration != "1" ? "s" : ""}',
                  style: TextStyle(
                    fontSize: _isSmallScreen
                        ? 14
                        : 16, // PERBAIKAN: Font size responsif
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) => controller.selectDuration(value!),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(4),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: _isSmallScreen
                    ? 12
                    : 16, // PERBAIKAN: Padding responsif
                vertical: _isSmallScreen ? 8 : 12,
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
        Text(
          'Start Time',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _isSmallScreen
                ? 14
                : 16, // PERBAIKAN: Font size responsif
          ),
        ),
        SizedBox(height: _isSmallScreen ? 8 : 12),

        Obx(() {
          final selectedDuration = int.parse(controller.selectedDuration.value);

          return Wrap(
            spacing: _isSmallScreen ? 8 : 12, // PERBAIKAN: Spacing responsif
            runSpacing: _isSmallScreen ? 8 : 12,
            children: controller.availableTimes.asMap().entries.map((entry) {
              final time = entry.value;

              // Cek apakah waktu ini dan durasi berikutnya tersedia
              final isAvailable = controller.isTimeAvailableWithDuration(
                time,
                selectedDuration,
              );
              final isSelected = controller.isTimeInSelectedRange(time);
              final isStartTime = controller.selectedStartTime.value == time;

              // Tentukan tooltip message
              String? tooltipMessage;
              if (!isAvailable) {
                if (selectedDuration == 1) {
                  tooltipMessage = 'Time slot is booked';
                } else {
                  tooltipMessage =
                      'Not available for $selectedDuration hours duration';
                }
              }

              return FilterChip(
                label: Text(
                  time,
                  style: TextStyle(
                    fontSize: _isSmallScreen
                        ? 12
                        : 14, // PERBAIKAN: Font size responsif
                  ),
                ),
                selected: isSelected,
                onSelected: isAvailable
                    ? (_) {
                        if (isStartTime) {
                          controller.unselectStartTime();
                        } else {
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
                  fontSize: _isSmallScreen
                      ? 12
                      : 14, // PERBAIKAN: Font size responsif
                ),
                disabledColor: AppColors.neutralColor,
                tooltip: tooltipMessage,
              );
            }).toList(),
          );
        }),
        SizedBox(height: _isSmallScreen ? 8 : 12),
        Wrap(
          spacing: _isSmallScreen ? 8 : 12, // PERBAIKAN: Spacing responsif
          runSpacing: _isSmallScreen ? 8 : 12,
          children: [
            _buildLegendItem(Colors.grey[200]!, 'Available', _isSmallScreen),
            _buildLegendItem(
              AppColors.neutralColor,
              'Unavailable',
              _isSmallScreen,
            ),
            _buildLegendItem(AppColors.secondary, 'Selected', _isSmallScreen),
          ],
        ),
      ],
    );
  }

  // PERBAIKAN: Helper method untuk legend item yang responsif
  Widget _buildLegendItem(Color color, String text, bool isSmall) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSmall ? 16 : 20,
          height: isSmall ? 16 : 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: color == AppColors.neutralColor
                ? Border.all(color: Colors.grey)
                : null,
          ),
        ),
        SizedBox(width: isSmall ? 4 : 6),
        Text(text, style: TextStyle(fontSize: isSmall ? 12 : 14)),
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
        padding: EdgeInsets.all(
          _isSmallScreen ? 16 : 20,
        ), // PERBAIKAN: Padding responsif
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section - PERBAIKAN: Size responsif
            Container(
              width: _isSmallScreen ? 70 : 80,
              height: _isSmallScreen ? 70 : 80,
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
                          child: Icon(
                            Icons.local_offer,
                            size: _isSmallScreen
                                ? 28
                                : 32, // PERBAIKAN: Icon size responsif
                            color: Colors.grey,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.local_offer,
                            size: _isSmallScreen
                                ? 28
                                : 32, // PERBAIKAN: Icon size responsif
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.local_offer,
                      size: _isSmallScreen
                          ? 28
                          : 32, // PERBAIKAN: Icon size responsif
                      color: Colors.grey,
                    ),
            ),
            SizedBox(
              width: _isSmallScreen ? 12 : 16,
            ), // PERBAIKAN: Spacing responsif
            // Content Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addOn.name,
                    style: TextStyle(
                      fontSize: _isSmallScreen
                          ? 16
                          : 18, // PERBAIKAN: Font size responsif
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _isSmallScreen ? 4 : 6),
                  Text(
                    addOn.description,
                    style: TextStyle(
                      fontSize: _isSmallScreen
                          ? 13
                          : 15, // PERBAIKAN: Font size responsif
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _isSmallScreen ? 6 : 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _isSmallScreen
                              ? 8
                              : 10, // PERBAIKAN: Padding responsif
                          vertical: _isSmallScreen ? 2 : 4,
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
                            fontSize: _isSmallScreen
                                ? 11
                                : 13, // PERBAIKAN: Font size responsif
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
            SizedBox(
              width: _isSmallScreen ? 12 : 16,
            ), // PERBAIKAN: Spacing responsif
            // Price and Quantity Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.formatRupiah(addOn.pricePerHour.toDouble()),
                  style: TextStyle(
                    fontSize: _isSmallScreen
                        ? 15
                        : 17, // PERBAIKAN: Font size responsif
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: _isSmallScreen ? 8 : 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          size: _isSmallScreen
                              ? 18
                              : 20, // PERBAIKAN: Icon size responsif
                        ),
                        padding: EdgeInsets.all(
                          _isSmallScreen ? 6 : 8,
                        ), // PERBAIKAN: Padding responsif
                        constraints: BoxConstraints(
                          minWidth: _isSmallScreen
                              ? 32
                              : 36, // PERBAIKAN: Size responsif
                          minHeight: _isSmallScreen ? 32 : 36,
                        ),
                        onPressed: quantity <= 0
                            ? null
                            : () => controller.decrementAddOn(addOn.name),
                        color: quantity <= 0 ? Colors.grey : AppColors.primary,
                      ),
                      Container(
                        width: _isSmallScreen
                            ? 30
                            : 36, // PERBAIKAN: Width responsif
                        alignment: Alignment.center,
                        child: Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: _isSmallScreen
                                ? 14
                                : 16, // PERBAIKAN: Font size responsif
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          size: _isSmallScreen
                              ? 18
                              : 20, // PERBAIKAN: Icon size responsif
                        ),
                        padding: EdgeInsets.all(
                          _isSmallScreen ? 6 : 8,
                        ), // PERBAIKAN: Padding responsif
                        constraints: BoxConstraints(
                          minWidth: _isSmallScreen
                              ? 32
                              : 36, // PERBAIKAN: Size responsif
                          minHeight: _isSmallScreen ? 32 : 36,
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
        Text(
          'Additional Services',
          style: TextStyle(
            fontSize: _isSmallScreen
                ? 18
                : 20, // PERBAIKAN: Font size responsif
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _isSmallScreen ? 8.0 : 12.0),
      child: Text(
        'Additional services not available for this court',
        style: TextStyle(
          fontSize: _isSmallScreen ? 14 : 16, // PERBAIKAN: Font size responsif
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildLoadingAddOns() {
    return Container(
      constraints: BoxConstraints(maxHeight: _screenHeight * 0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: _isSmallScreen ? 8 : 12),
            Text(
              'Loading additional services...',
              style: TextStyle(
                fontSize: _isSmallScreen
                    ? 14
                    : 16, // PERBAIKAN: Font size responsif
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAddOnsAvailable() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: _isSmallScreen ? 16 : 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: _isSmallScreen ? 48 : 56, // PERBAIKAN: Icon size responsif
              color: Colors.grey,
            ),
            SizedBox(height: _isSmallScreen ? 8 : 12),
            Text(
              'No additional services available',
              style: TextStyle(
                fontSize: _isSmallScreen
                    ? 14
                    : 16, // PERBAIKAN: Font size responsif
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOnsList() {
    return Container(
      constraints: BoxConstraints(maxHeight: _screenHeight * 0.4),
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
              margin: EdgeInsets.only(
                bottom: _isSmallScreen ? 8 : 12,
              ), // PERBAIKAN: Margin responsif
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
        Text(
          'Location',
          style: TextStyle(
            fontSize: _isSmallScreen
                ? 18
                : 20, // PERBAIKAN: Font size responsif
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: _isSmallScreen ? 8 : 12),
        Container(
          height: _isSmallScreen ? 200 : 250, // PERBAIKAN: Height responsif
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  "assets/images/map_bg.jpg",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[200]),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: _isSmallScreen
                          ? 50
                          : 60, // PERBAIKAN: Icon size responsif
                      color: Colors.white,
                    ),
                    SizedBox(height: _isSmallScreen ? 12 : 16),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _isSmallScreen ? 16 : 24,
                      ),
                      child: Text(
                        controller.court.location,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _isSmallScreen
                              ? 14
                              : 16, // PERBAIKAN: Font size responsif
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: _isSmallScreen ? 12 : 16),
                    ElevatedButton(
                      onPressed: _openMaps,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        padding: EdgeInsets.symmetric(
                          horizontal: _isSmallScreen
                              ? 20
                              : 24, // PERBAIKAN: Padding responsif
                          vertical: _isSmallScreen ? 10 : 12,
                        ),
                      ),
                      child: Text(
                        'Open in Google Maps',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: _isSmallScreen
                              ? 14
                              : 16, // PERBAIKAN: Font size responsif
                        ),
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
      padding: EdgeInsets.all(
        _isSmallScreen ? 16 : 20,
      ), // PERBAIKAN: Padding responsif
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
                    style: TextStyle(
                      fontSize: _isSmallScreen
                          ? 20
                          : 24, // PERBAIKAN: Font size responsif
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Court: ${controller.formatRupiah(controller.court.price)} (1h x ${controller.formatRupiah(controller.court.price)})',
                  style: TextStyle(
                    fontSize: _isSmallScreen
                        ? 12
                        : 14, // PERBAIKAN: Font size responsif
                    color: Colors.grey,
                  ),
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
              padding: EdgeInsets.symmetric(
                horizontal: _isSmallScreen
                    ? 20
                    : 24, // PERBAIKAN: Padding responsif
                vertical: _isSmallScreen ? 12 : 16,
              ),
            ),
            child: Text(
              'Book Now!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: _isSmallScreen
                    ? 14
                    : 16, // PERBAIKAN: Font size responsif
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (methods lainnya seperti _showDatePicker, _openMaps, dll tetap sama)
  // Hanya tambahkan responsive properties di method yang memerlukan

  Widget _buildRatingsSummary() {
    return Obx(() {
      if (controller.isLoadingRatings.value) {
        return _buildRatingSkeleton();
      }

      if (!controller.hasRatings) {
        return _buildNoRatingCard();
      }

      final summary = controller.placeRatingSummary.value!;
      return _buildRatingSummaryCard(summary);
    });
  }

  Widget _buildRatingSkeleton() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(_isSmallScreen ? 16 : 20),
        child: Row(
          children: [
            Container(
              width: _isSmallScreen ? 60 : 70,
              height: _isSmallScreen ? 60 : 70,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(width: _isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: _isSmallScreen ? 16 : 18,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: _isSmallScreen ? 8 : 12),
                  Container(
                    width: 80,
                    height: _isSmallScreen ? 12 : 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRatingCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(_isSmallScreen ? 16 : 20),
        child: Row(
          children: [
            Icon(
              Icons.star_border,
              size: _isSmallScreen ? 40 : 48, // PERBAIKAN: Icon size responsif
              color: Colors.grey,
            ),
            SizedBox(width: _isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Reviews Yet',
                    style: TextStyle(
                      fontSize: _isSmallScreen
                          ? 16
                          : 18, // PERBAIKAN: Font size responsif
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: _isSmallScreen ? 4 : 6),
                  Text(
                    'Be the first to review this place!',
                    style: TextStyle(
                      fontSize: _isSmallScreen
                          ? 12
                          : 14, // PERBAIKAN: Font size responsif
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummaryCard(PlaceRatingSummary summary) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(_isSmallScreen ? 16 : 20),
        child: Row(
          children: [
            // Rating score circle - PERBAIKAN: Size responsif
            Container(
              width: _isSmallScreen ? 60 : 70,
              height: _isSmallScreen ? 60 : 70,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    summary.formattedAverageRating,
                    style: TextStyle(
                      fontSize: _isSmallScreen
                          ? 20
                          : 24, // PERBAIKAN: Font size responsif
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < summary.averageRating.round()
                            ? Icons.star
                            : Icons.star_border,
                        size: _isSmallScreen
                            ? 8
                            : 10, // PERBAIKAN: Icon size responsif
                        color: Colors.white,
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(width: _isSmallScreen ? 12 : 16),

            // Rating info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Reviews',
                    style: TextStyle(
                      fontSize: _isSmallScreen
                          ? 16
                          : 18, // PERBAIKAN: Font size responsif
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: _isSmallScreen ? 4 : 6),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < summary.averageRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: _isSmallScreen
                              ? 16
                              : 18, // PERBAIKAN: Icon size responsif
                          color: AppColors.secondary,
                        );
                      }),
                      SizedBox(width: _isSmallScreen ? 8 : 12),
                      Text(
                        '${summary.totalReviews} review${summary.totalReviews > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: _isSmallScreen
                              ? 14
                              : 16, // PERBAIKAN: Font size responsif
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // View all reviews button
            if (summary.totalReviews > 0)
              TextButton(
                onPressed: () {
                  if (controller.placeReviews.isNotEmpty) {
                    _showAllReviewsModal(controller.placeReviews);
                  }
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: _isSmallScreen
                        ? 12
                        : 14, // PERBAIKAN: Font size responsif
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
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
    try {
      final controller = Get.find<CustomerBookingDetailController>();

      Get.to(
        () => GoogleSearchWebView(
          courtName: controller.court.placeName,
          courtLocation: controller.court.location,
        ),
        transition: Transition.cupertino,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to open map location',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildReviewsSection() {
    return Obx(() {
      if (controller.isLoadingRatings.value) {
        return _buildReviewsSkeleton();
      }

      if (!controller.hasRatings) {
        return const SizedBox.shrink();
      }

      final reviews = controller.placeReviews;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: TextStyle(
              fontSize: _isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: _isSmallScreen ? 12 : 16),

          // Tampilkan 5 review pertama
          ...reviews.take(5).map((review) => _buildReviewCard(review)),

          if (reviews.length > 5)
            Padding(
              padding: EdgeInsets.only(
                top: _isSmallScreen ? 12 : 16,
                bottom: _isSmallScreen ? 16 : 20,
              ),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _showAllReviewsModal(reviews);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _isSmallScreen ? 28 : 32,
                          vertical: _isSmallScreen ? 12 : 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.rate_review,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: _isSmallScreen ? 8 : 10),
                            Text(
                              'View All ${reviews.length} Reviews',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: _isSmallScreen ? 15 : 16,
                              ),
                            ),
                            SizedBox(width: _isSmallScreen ? 6 : 8),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildReviewsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (index) => _buildReviewSkeleton()),
      ],
    );
  }

  Widget _buildReviewSkeleton() {
    return Container(
      margin: EdgeInsets.only(bottom: _isSmallScreen ? 12 : 16),
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(_isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username and date skeleton
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: _isSmallScreen ? 80 : 100,
                      height: _isSmallScreen ? 14 : 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: _isSmallScreen ? 60 : 80,
                    height: _isSmallScreen ? 12 : 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),

              SizedBox(height: _isSmallScreen ? 8 : 12),

              // Star rating skeleton
              Row(
                children: List.generate(5, (index) {
                  return Container(
                    width: _isSmallScreen ? 14 : 16,
                    height: _isSmallScreen ? 14 : 16,
                    margin: EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              SizedBox(height: _isSmallScreen ? 8 : 12),

              // Review text skeleton
              Container(
                width: double.infinity,
                height: _isSmallScreen ? 12 : 14,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              SizedBox(height: 6),

              Container(
                width: double.infinity * 0.7,
                height: _isSmallScreen ? 12 : 14,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(RatingDetailData review) {
    final dateFormatter = DateFormat('dd MMM yyyy');
    final reviewDate = review.createdAt != null
        ? dateFormatter.format(review.createdAt!)
        : 'Unknown date';

    return Container(
      margin: EdgeInsets.only(bottom: _isSmallScreen ? 12 : 16),
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(_isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ PERBAIKAN: Row dengan Flexible untuk prevent overflow
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Username section dengan Flexible
                  Flexible(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.userName,
                          style: TextStyle(
                            fontSize: _isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        // Star rating
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review.ratingValue
                                  ? Icons.star
                                  : Icons.star_border,
                              size: _isSmallScreen ? 14 : 16,
                              color: AppColors.secondary,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8),

                  // Date section dengan Flexible
                  Flexible(
                    flex: 2,
                    child: Text(
                      reviewDate,
                      style: TextStyle(
                        fontSize: _isSmallScreen ? 11 : 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Review text
              if (review.review.isNotEmpty) ...[
                SizedBox(height: _isSmallScreen ? 8 : 12),
                Text(
                  review.review,
                  style: TextStyle(
                    fontSize: _isSmallScreen ? 13 : 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Field name tag
              if (review.fieldName.isNotEmpty) ...[
                SizedBox(height: _isSmallScreen ? 8 : 10),
                // ✅ PERBAIKAN: Wrap dengan Align dan IntrinsicWidth untuk prevent overflow
                Align(
                  alignment: Alignment.centerLeft,
                  child: IntrinsicWidth(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(Get.context!).size.width * 0.7,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: _isSmallScreen ? 8 : 10,
                        vertical: _isSmallScreen ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${review.fieldName} - ${review.fieldType}',
                        style: TextStyle(
                          fontSize: _isSmallScreen ? 11 : 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAllReviewsModal(List<RatingDetailData> reviews) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: _screenHeight * 0.8, // ✅ Gunakan responsive height
            maxWidth: _isSmallScreen
                ? _screenWidth * 0.95
                : 500, // ✅ Responsive width
          ),
          child: Column(
            children: [
              // Header dengan border bottom
              Container(
                padding: EdgeInsets.all(_isSmallScreen ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'All Reviews (${reviews.length})',
                        style: TextStyle(
                          fontSize: _isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, size: _isSmallScreen ? 20 : 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Reviews list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(_isSmallScreen ? 12 : 16),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    return _buildReviewCard(reviews[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible:
          true, // ✅ Tambahkan ini - bisa ditutup dengan tap di luar
    );
  }
}
