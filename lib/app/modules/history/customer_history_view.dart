import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_controller.dart';
import 'package:lapangan_kita/app/data/models/customer/history/customer_history_model.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

/// View untuk menampilkan riwayat booking customer
/// Menampilkan list booking dengan filter status dan search functionality
class CustomerHistoryView extends GetView<CustomerHistoryController> {
  const CustomerHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: _buildAppBar(),
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
                SliverToBoxAdapter(child: _buildSearchBar()),
                SliverToBoxAdapter(child: _buildFilterRow()),
                _buildBookingList(),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ==================== UI Components ====================

  /// AppBar dengan title dan subtitle
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  /// Search bar untuk mencari booking
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Obx(
        () => TextField(
          controller: controller.searchController,
          onChanged: (value) => controller.updateSearchQuery(value),
          decoration: InputDecoration(
            hintText: 'Search by court name, location, or order ID...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            suffixIcon: controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () => controller.clearSearch(),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.secondary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// Filter chips untuk filter berdasarkan status
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

  /// Single filter chip
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

  /// List booking dengan empty state
  Widget _buildBookingList() {
    return Obx(() {
      if (controller.bookings.isEmpty) {
        return _buildEmptyState(
          icon: Icons.history,
          title: 'No booking history yet',
          subtitle: 'Your bookings will appear here',
        );
      }

      final filteredBookings = _getFilteredBookings();

      if (filteredBookings.isEmpty) {
        return _buildEmptyState(
          icon: Icons.search_off,
          title: controller.searchQuery.value.isNotEmpty
              ? 'No results found for "${controller.searchQuery.value}"'
              : 'No ${controller.selectedFilter.value} bookings',
          subtitle: '',
          actionLabel: controller.searchQuery.value.isNotEmpty
              ? 'Clear Search'
              : 'Show All Bookings',
          onAction: () {
            if (controller.searchQuery.value.isNotEmpty) {
              controller.clearSearch();
            } else {
              controller.setFilter('all');
            }
          },
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
    });
  }

  /// Empty state widget
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== Booking Card ====================

  /// Card booking dengan responsive layout
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
                    _buildCardHeader(booking, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    _buildDetailsSection(booking, isSmallScreen),
                    if (booking.status == 'completed') ...[
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      _buildRatingButton(booking, isSmallScreen),
                    ],
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    _buildPriceBreakdownSection(booking, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    _buildTotalAmountSection(booking, isSmallScreen),
                  ],
                ),
              ),
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

  /// Header card dengan icon dan info court
  Widget _buildCardHeader(BookingHistory booking, bool isSmallScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isSmallScreen ? 60 : 80,
          height: isSmallScreen ? 60 : 80,
          decoration: BoxDecoration(
            color: booking.getCategoryColor().withOpacity(0.15),
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            border: Border.all(
              color: booking.getCategoryColor().withOpacity(0.3),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                'Order Id: ${booking.orderId}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isSmallScreen ? 11 : 13,
                  fontFamily: 'monospace',
                ),
              ),
              SizedBox(height: isSmallScreen ? 4 : 6),
              _buildTypesSection(booking, isSmallScreen),
            ],
          ),
        ),
      ],
    );
  }

  /// Types badges (court type)
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

  /// Details section (date, time, duration, note)
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

  /// Single detail row
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

  /// Rating button untuk completed bookings
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

  /// Price breakdown expansion tile
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

  /// Price breakdown content
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

  /// Single price row
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

  /// Total amount section
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

  /// Status chip badge
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

  // ==================== Rating Dialog ====================

  /// Show rating dialog for completed bookings
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
                _buildBookingInfo(booking),
                const SizedBox(height: 20),
                _buildRatingStars(selectedRating),
                const SizedBox(height: 20),
                _buildReviewField(reviewController),
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

  /// Booking info in rating dialog
  Widget _buildBookingInfo(BookingHistory booking) {
    return Container(
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
    );
  }

  /// Rating stars widget
  Widget _buildRatingStars(RxInt selectedRating) {
    return Column(
      children: [
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
      ],
    );
  }

  /// Review text field
  Widget _buildReviewField(TextEditingController reviewController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// Submit rating
  void _submitRating(BookingHistory booking, int rating, String review) async {
    final success = await controller.submitRating(
      bookingId: booking.id.toString(),
      ratingValue: rating,
      review: review.trim(),
    );

    if (success) {
      Get.back();
    }
  }

  // ==================== Helper Methods ====================

  /// Get filtered bookings berdasarkan status dan search query
  List<BookingHistory> _getFilteredBookings() {
    final allBookings = List<BookingHistory>.from(controller.bookings);

    // Sort: pending first, then by date
    allBookings.sort((a, b) {
      if (a.status == 'pending' && b.status != 'pending') return -1;
      if (a.status != 'pending' && b.status == 'pending') return 1;
      return b.date.compareTo(a.date);
    });

    // Filter by status
    List<BookingHistory> filtered;
    if (controller.selectedFilter.value == 'all') {
      filtered = allBookings;
    } else {
      filtered = allBookings
          .where((booking) => booking.status == controller.selectedFilter.value)
          .toList();
    }

    // Filter by search query
    return controller.getSearchFilteredBookings(filtered);
  }

  /// Format date
  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  /// Format time range
  String _formatTimeRange(BookingHistory booking) {
    return '${booking.startTime} - ${booking.endTime}';
  }

  /// Format currency
  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(amount);
  }
}
