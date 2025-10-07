import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_controller.dart';
import 'package:lapangan_kita/app/data/models/customer/history/customer_history_model.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

class CustomerHistoryView extends GetView<CustomerHistoryController> {
  const CustomerHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Bookings'),
            const Text(
              'Manage your court reservations and booking history',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppColors.neutralColor,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => controller.refreshData(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Filter Row
                SliverToBoxAdapter(child: _buildFilterRow()),
                // Content
                Obx(() {
                  if (controller.bookings.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No booking history yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your bookings will appear here',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => controller.refreshData(),
                              child: const Text('Refresh Data'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filteredBookings = _getFilteredBookings();

                  if (filteredBookings.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_alt_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No ${controller.selectedFilter.value} bookings',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => controller.setFilter('all'),
                              child: const Text('Show All Bookings'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final booking = filteredBookings[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildBookingCard(booking),
                      );
                    }, childCount: filteredBookings.length),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: controller.selectedFilter.value == 'all',
                onSelected: () => controller.setFilter('all'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Pending',
                isSelected: controller.selectedFilter.value == 'pending',
                onSelected: () => controller.setFilter('pending'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Approved',
                isSelected: controller.selectedFilter.value == 'approved',
                onSelected: () => controller.setFilter('approved'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Completed',
                isSelected: controller.selectedFilter.value == 'completed',
                onSelected: () => controller.setFilter('completed'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Rejected',
                isSelected: controller.selectedFilter.value == 'rejected',
                onSelected: () => controller.setFilter('rejected'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.secondary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[800],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  List<BookingHistory> _getFilteredBookings() {
    final allBookings = List<BookingHistory>.from(controller.bookings);

    // Urutkan: pending di atas, lalu diurutkan berdasarkan tanggal (terbaru di atas)
    allBookings.sort((a, b) {
      // Prioritas status: pending > lainnya
      if (a.status == 'pending' && b.status != 'pending') return -1;
      if (a.status != 'pending' && b.status == 'pending') return 1;

      // Jika status sama, urutkan berdasarkan tanggal (terbaru di atas)
      return b.date.compareTo(a.date);
    });

    if (controller.selectedFilter.value == 'all') {
      return allBookings;
    }

    return allBookings
        .where((booking) => booking.status == controller.selectedFilter.value)
        .toList();
  }

  Widget _buildBookingCard(BookingHistory booking) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 380;

        return Card(
          color: Colors.white,
          margin: EdgeInsets.zero,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row - Responsif
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Container - Ukuran responsif
                        Container(
                          width: isSmallScreen ? 60 : 80,
                          height: isSmallScreen ? 60 : 80,
                          decoration: BoxDecoration(
                            color: booking.getCategoryColor().withOpacity(0.15),
                            borderRadius: BorderRadius.circular(
                              isSmallScreen ? 8 : 12,
                            ),
                            border: Border.all(
                              color: booking.getCategoryColor().withOpacity(
                                0.3,
                              ),
                              width: isSmallScreen ? 1.5 : 2,
                            ),
                          ),
                          child: Icon(
                            booking.getCategoryIcon(),
                            size: isSmallScreen ? 28 : 40,
                            color: booking.getCategoryColor(),
                          ),
                        ),

                        SizedBox(width: isSmallScreen ? 8 : 12),

                        // Content - Flexible dan responsif
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Court Name - Font size responsif
                              Text(
                                booking.courtName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 14 : 16,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              SizedBox(height: isSmallScreen ? 2 : 4),

                              // Location - Font size responsif
                              Text(
                                booking.location,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              SizedBox(height: isSmallScreen ? 2 : 4),

                              // Order ID - Font size responsif
                              Text(
                                'ID: ${booking.orderId}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isSmallScreen ? 11 : 13,
                                  fontFamily: 'monospace',
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 4 : 6),

                              // Types - Layout responsif
                              _buildTypesSection(booking, isSmallScreen),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isSmallScreen ? 8 : 12),

                    // Details Section - Layout responsif
                    _buildDetailsSection(booking, isSmallScreen),

                    // Create Post Button - Hanya untuk status approved
                    if (booking.status == 'approved') ...[
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      _buildCreatePostButton(booking, isSmallScreen),
                    ],

                    // Rating Button - Hanya untuk status completed
                    if (booking.status == 'completed') ...[
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      _buildRatingButton(booking, isSmallScreen),
                    ],

                    // Price Breakdown - Expansion tile responsif
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    _buildPriceBreakdownSection(booking, isSmallScreen),

                    // Total Amount - Responsif
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    _buildTotalAmountSection(booking, isSmallScreen),
                  ],
                ),
              ),

              // Status Chip - Posisi dan ukuran responsif
              Positioned(
                top: isSmallScreen ? 8 : 12,
                right: isSmallScreen ? 8 : 12,
                child: _buildStatusChip(booking.status, isSmallScreen),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypesSection(BookingHistory booking, bool isSmallScreen) {
    if (booking.types.isEmpty) return const SizedBox();

    return Wrap(
      spacing: isSmallScreen ? 6 : 8,
      runSpacing: isSmallScreen ? 4 : 6,
      children: booking.types.map((type) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8 : 10,
            vertical: isSmallScreen ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            type,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Details Section yang responsif
  Widget _buildDetailsSection(BookingHistory booking, bool isSmallScreen) {
    return Column(
      children: [
        _buildDetailRow('Date', _formatDate(booking.date), isSmallScreen),
        _buildDetailRow('Time', _formatTimeRange(booking), isSmallScreen),
        _buildDetailRow(
          'Duration',
          '${booking.duration} hour${booking.duration > 1 ? 's' : ''}',
          isSmallScreen,
        ),
        if (booking.note.isNotEmpty)
          _buildDetailRow('Note', booking.note, isSmallScreen, maxLines: 2),
      ],
    );
  }

  Widget _buildRatingButton(BookingHistory booking, bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showRatingDialog(booking),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[50],
          foregroundColor: Colors.orange[700],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            side: BorderSide(color: Colors.orange[200]!, width: 1),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 10 : 12,
            horizontal: isSmallScreen ? 12 : 16,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rate, size: isSmallScreen ? 16 : 18),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Flexible(
              child: Text(
                'Rate Experience',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Detail Row yang responsif
  Widget _buildDetailRow(
    String label,
    String value,
    bool isSmallScreen, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 2 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Flexible(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostButton(BookingHistory booking, bool isSmallScreen) {
    final hasPosted = booking.hasPosted;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasPosted ? null : () => _showCreatePostModal(booking),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasPosted ? Colors.grey[300] : Colors.blue[50],
          foregroundColor: hasPosted ? Colors.grey[600] : Colors.blue[700],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            side: BorderSide(
              color: hasPosted ? Colors.grey[400]! : Colors.blue[200]!,
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 10 : 12,
            horizontal: isSmallScreen ? 12 : 16,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasPosted ? Icons.check_circle : Icons.add,
              size: isSmallScreen ? 16 : 18,
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Flexible(
              child: Text(
                hasPosted ? 'Posted' : 'Create Post',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdownSection(
    BookingHistory booking,
    bool isSmallScreen,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 4 : 8,
        ),
        childrenPadding: EdgeInsets.only(
          left: isSmallScreen ? 12 : 16,
          right: isSmallScreen ? 12 : 16,
          bottom: isSmallScreen ? 8 : 12,
        ),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(
          'Price Breakdown',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
        children: [_buildPriceBreakdown(booking, isSmallScreen)],
      ),
    );
  }

  Widget _buildPriceBreakdown(BookingHistory booking, bool isSmallScreen) {
    return Column(
      children: [
        _buildPriceRow(
          'Court (${booking.duration} hour${booking.duration > 1 ? 's' : ''})',
          booking.courtTotal,
          isSmallScreen,
        ),
        if (booking.details.isNotEmpty) ...[
          SizedBox(height: isSmallScreen ? 6 : 8),
          Padding(
            padding: EdgeInsets.only(bottom: isSmallScreen ? 4 : 6),
            child: Text(
              'Additional Services:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
          ),
          ...booking.details.map((detail) {
            return _buildPriceRow(
              '${detail.addOnName} (x${detail.quantity})',
              detail.totalPrice,
              isSmallScreen,
            );
          }),
          _buildPriceRow(
            'Total Additional Services',
            booking.equipmentTotal,
            isSmallScreen,
          ),
        ],
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    bool isSmallScreen, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 2 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmountSection(BookingHistory booking, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey[800],
            ),
          ),
          Text(
            _formatCurrency(booking.totalAmount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 14 : 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isSmallScreen) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'approved':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        displayText = 'APPROVED';
        break;
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        displayText = 'REJECTED';
        break;
      case 'completed':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        displayText = 'COMPLETED';
        break;
      case 'pending':
      default:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        displayText = 'PENDING';
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: isSmallScreen ? 9 : 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Widget _buildDetailRow(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(label, style: TextStyle(color: Colors.grey[600])),
  //         Text(
  //           value,
  //           style: const TextStyle(fontWeight: FontWeight.w500),
  //           maxLines: 1,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildPriceBreakdown(BookingHistory booking) {
  //   return Column(
  //     children: [
  //       _buildPriceRow(
  //         'Court (${booking.duration} hour(s))',
  //         booking.courtTotal,
  //       ),
  //       if (booking.details.isNotEmpty) ...[
  //         const SizedBox(height: 8),
  //         const Text(
  //           'Additional Services:',
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         ...booking.details.map((detail) {
  //           return _buildPriceRow(
  //             '${detail.addOnName} (x${detail.quantity})',
  //             detail.totalPrice,
  //           );
  //         }),
  //         _buildPriceRow('Total Additional Services', booking.equipmentTotal),
  //       ],
  //     ],
  //   );
  // }

  // Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           label,
  //           style: TextStyle(
  //             fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
  //           ),
  //         ),
  //         Text(
  //           _formatCurrency(amount),
  //           style: TextStyle(
  //             fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  String _formatTimeRange(BookingHistory booking) {
    return '${booking.startTime} - ${booking.endTime}';
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  // Widget _buildCreatePostButton(BookingHistory booking) {
  //   // ✅ Cek apakah sudah posting
  //   final hasPosted = booking.hasPosted;

  //   return SizedBox(
  //     width: double.infinity,
  //     child: ElevatedButton(
  //       onPressed: hasPosted
  //           ? null // ✅ Disable button jika sudah posting
  //           : () {
  //               _showCreatePostModal(booking);
  //             },
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: hasPosted
  //             ? Colors.grey[300] // ✅ Warna abu-abu jika disabled
  //             : Colors.blue[50],
  //         foregroundColor: hasPosted
  //             ? Colors.grey[600] // ✅ Warna text abu-abu jika disabled
  //             : Colors.blue[700],
  //         elevation: 0,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //           side: BorderSide(
  //             color: hasPosted
  //                 ? Colors.grey[400]! // ✅ Border abu-abu jika disabled
  //                 : Colors.blue[200]!,
  //             width: 1,
  //           ),
  //         ),
  //         padding: const EdgeInsets.symmetric(vertical: 12),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             hasPosted ? Icons.check_circle : Icons.add, // ✅ Icon berbeda
  //             size: 18,
  //           ),
  //           const SizedBox(width: 8),
  //           Text(
  //             hasPosted
  //                 ? 'You have posted' // ✅ Text berbeda jika sudah posting
  //                 : 'Create Community Post',
  //             style: TextStyle(
  //               fontWeight: FontWeight.w600,
  //               fontSize: 14,
  //               color: hasPosted ? Colors.grey[600] : Colors.blue[700],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // customer_history_view.dart - Ganti method _showCreatePostModal dengan yang baru
  void _showCreatePostModal(BookingHistory booking) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final RxString selectedImagePath = ''.obs;

    // Set default title berdasarkan booking
    titleController.text = 'Looking for players at ${booking.courtName}';

    // Cek ukuran layar untuk menentukan tinggi modal
    final mediaQuery = MediaQuery.of(Get.context!);
    final isSmallScreen = mediaQuery.size.height < 600;
    final maxHeight = mediaQuery.size.height * 0.85;

    Get.bottomSheet(
      Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: isSmallScreen ? mediaQuery.size.height * 0.9 : maxHeight,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Community Post',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content yang bisa di-scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Court Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sports,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                booking.types.isNotEmpty
                                    ? booking.types.first
                                    : 'General',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            booking.courtName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(booking.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTimeRange(booking),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Form Fields
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Post Title *',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'Enter post title...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue[700]!,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            hintText:
                                'Describe your game, skill level, what you\'re looking for...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue[700]!,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          maxLines: 4,
                          style: const TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 20),

                        // Image Upload Section
                        const Text(
                          'Add Photo ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => GestureDetector(
                            onTap: () async {
                              await _pickImage(selectedImagePath);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[50],
                              ),
                              child: selectedImagePath.value.isEmpty
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 32,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to add photo',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        // Display selected image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.file(
                                            File(selectedImagePath.value),
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        // Remove button
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              selectedImagePath.value = '';
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 16,
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

                        const SizedBox(height: 8),
                        Text(
                          'Recommended: 1080x720 px',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Obx(
                () => Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Post Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                if (titleController.text.trim().isEmpty) {
                                  Get.snackbar(
                                    'Required',
                                    'Please enter a post title',
                                    backgroundColor: Colors.red[50],
                                    colorText: Colors.red[700],
                                    snackPosition: SnackPosition.TOP,
                                  );
                                  return;
                                }

                                try {
                                  await controller.createCommunityPost(
                                    bookingId: booking.id,
                                    title: titleController.text.trim(),
                                    description: descriptionController.text
                                        .trim(),
                                    imagePath: selectedImagePath.value.isEmpty
                                        ? null
                                        : selectedImagePath.value,
                                  );

                                  // ✅ SUCCESS: Tutup modal dan show snackbar
                                  Get.back(); // Tutup modal bottom sheet

                                  Get.snackbar(
                                    'Success 🎉',
                                    'Community post created successfully!',
                                    backgroundColor: Colors.green[50],
                                    colorText: Colors.green[700],
                                    snackPosition: SnackPosition.TOP,
                                    duration: const Duration(seconds: 3),
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    shouldIconPulse: true,
                                    margin: const EdgeInsets.all(16),
                                    borderRadius: 12,
                                  );
                                } catch (e) {
                                  // ✅ ERROR: Show error snackbar tanpa menutup modal
                                  print(e);
                                  Get.snackbar(
                                    'Error',
                                    'Failed to create post: need image',

                                    backgroundColor: Colors.red[50],
                                    colorText: Colors.red[700],
                                    snackPosition: SnackPosition.TOP,
                                    duration: const Duration(seconds: 4),
                                    icon: const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                    margin: const EdgeInsets.all(16),
                                    borderRadius: 12,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
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
                                'Create Post',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }

  void _showRatingDialog(BookingHistory booking) {
    final TextEditingController reviewController = TextEditingController();
    final RxInt selectedRating = 0.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(Icons.star_rate, color: Colors.orange[600], size: 32),
            const SizedBox(height: 8),
            const Text(
              'Rate Your Experience',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Booking info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.courtName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        _formatDate(booking.date),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Rating stars
                const Text(
                  'Rate your experience (1-5 stars):',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => selectedRating.value = index + 1,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < selectedRating.value
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.orange[600],
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                // Review text field
                const Text(
                  'Write a review (optional):',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reviewController,
                  maxLines: null,
                  minLines: 2,
                  maxLength: 200,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: selectedRating.value > 0
                  ? () => _submitRating(
                      booking,
                      selectedRating.value,
                      reviewController.text,
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Submit Rating'),
            ),
          ),
        ],
      ),
    );
  }

  void _submitRating(BookingHistory booking, int rating, String review) async {
    try {
      final success = await controller.submitRating(
        bookingId: booking.id.toString(),
        ratingValue: rating,
        review: review.trim(),
      );

      // Close dialog only if submission was successful
      if (success) {
        Get.back();
      }
    } catch (e) {
      // Error handling is already done in controller
      print('Rating submission error: $e');
    }
  }

  // Tambahkan method untuk memilih gambar
  Future<void> _pickImage(RxString selectedImagePath) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 720,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[700],
      );
    }
  }
}
