import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/owner_booking_model.dart';
import '../tabs_controller/fieldmanager_booking_controller.dart';

class FieldManagerBookingView extends GetView<FieldManagerBookingController> {
  const FieldManagerBookingView({super.key});

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }

  void showBookingDetail(
    BuildContext context,
    FieldManagerBookingController c,
    OwnerBooking booking,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Status', c.statusLabel(booking)),
              _detailRow('Customer', booking.userName),
              _detailRow('Email', booking.userEmail),
              _detailRow('Field', booking.fieldName),
              _detailRow('Place', booking.placeName),
              _detailRow('Date', c.formatDate(booking.bookingStart)),
              _detailRow(
                'Time',
                c.formatTimeRange(booking.bookingStart, booking.bookingEnd),
              ),
              _detailRow('Order ID', booking.orderId),
              _detailRow('Total Price', c.formatPrice(booking.totalPrice)),
              _detailRow(
                'Notes',
                booking.note != null && booking.note!.trim().isNotEmpty
                    ? booking.note!
                    : 'No notes provided.',
              ),
              if (booking.details.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Add-ons',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...booking.details.map(
                  (detail) => _detailRow(
                    detail.addOnName ?? 'Add-on',
                    '${detail.quantity} x ${c.formatPrice(detail.pricePerHour ?? 0)} = ${c.formatPrice(detail.totalPrice)}',
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void confirmAction(
    BuildContext context,
    FieldManagerBookingController c,
    OwnerBooking booking,
    OwnerBookingStatus action,
  ) {
    final isAccept = action == OwnerBookingStatus.accepted;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAccept ? 'Accept Booking' : 'Reject Booking'),
        content: Text(
          isAccept
              ? 'Are you sure you want to accept this booking?'
              : 'Are you sure you want to reject this booking?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              c.updateStatus(booking.id, action);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isAccept ? 'Booking accepted' : 'Booking rejected',
                  ),
                ),
              );
            },
            child: Text(isAccept ? 'Accept' : 'Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey[50],
            child: SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search customer, field, or order...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 0,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 15),
                      onChanged: (val) => c.searchQuery.value = val,
                    ),
                  ),
                  Obx(
                    () => Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: c.filterStatus.value,
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All')),
                            DropdownMenuItem(
                              value: 'Pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'Accepted',
                              child: Text('Accepted'),
                            ),
                            DropdownMenuItem(
                              value: 'Rejected',
                              child: Text('Rejected'),
                            ),
                          ],
                          onChanged: (val) =>
                              c.filterStatus.value = val ?? 'All',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          icon: const Icon(Icons.arrow_drop_down, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (c.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: c.fetchBookings,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                );
              }

              final bookings = c.filteredBookings;
              if (bookings.isEmpty) {
                return const Center(child: Text('No booking data available.'));
              }

              return RefreshIndicator(
                onRefresh: c.refreshBookings,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final status = booking.normalizedStatus;
                    final statusColor = c.statusColor(status);

                    return GestureDetector(
                      onTap: () => showBookingDetail(context, c, booking),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.fieldName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      c.statusLabel(booking),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Customer: ${booking.userName}'),
                              Text(
                                'Date: ${c.formatDate(booking.bookingStart)}',
                              ),
                              Text(
                                'Time: ${c.formatTimeRange(booking.bookingStart, booking.bookingEnd)}',
                              ),
                              Text(
                                'Total: ${c.formatPrice(booking.totalPrice)}',
                              ),
                              const SizedBox(height: 12),
                              if (status == OwnerBookingStatus.pending)
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        onPressed: () => confirmAction(
                                          context,
                                          c,
                                          booking,
                                          OwnerBookingStatus.accepted,
                                        ),
                                        child: const Text(
                                          'Accept',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () => confirmAction(
                                          context,
                                          c,
                                          booking,
                                          OwnerBookingStatus.rejected,
                                        ),
                                        child: const Text(
                                          'Reject',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
