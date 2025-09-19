import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_controller.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_model.dart';
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
    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        booking.courtImageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.courtName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Booking Code: ${booking.id}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Date', _formatDate(booking.date)),
                _buildDetailRow('Time', _formatTimeRange(booking)),
                _buildDetailRow('Duration', '${booking.duration} hour(s)'),
                const SizedBox(height: 16),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                  collapsedShape: const RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                  title: const Text(
                    'Price Breakdown',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildPriceBreakdown(booking),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildPriceRow(
                  'Total Amount',
                  booking.totalAmount,
                  isTotal: true,
                ),
              ],
            ),
          ),
          Positioned(top: 8, right: 8, child: _buildStatusChip(booking.status)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'approved':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(BookingHistory booking) {
    return Column(
      children: [
        _buildPriceRow(
          'Court (${booking.duration} hour(s))',
          booking.courtPrice * booking.duration,
        ),
        if (booking.equipment.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Equipment:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...booking.equipment.entries.map((entry) {
            if (entry.value > 0) {
              return _buildPriceRow(
                '${entry.key} (x${entry.value})',
                booking.equipmentTotal / entry.value * entry.value,
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  String _formatTimeRange(BookingHistory booking) {
    final startTime = booking.startTime;
    final startHour = int.parse(startTime.split(':')[0]);
    final endHour = startHour + booking.duration;

    return '$startTime - ${endHour.toString().padLeft(2, '0')}:00';
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(amount);
  }
}
