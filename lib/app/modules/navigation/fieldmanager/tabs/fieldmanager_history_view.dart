import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/owner_booking_model.dart';
import '../tabs_controller/fieldmanager_history_controller.dart';

class FieldManagerHistoryView extends GetView<FieldManagerHistoryController> {
  const FieldManagerHistoryView({super.key});

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
    FieldManagerHistoryController c,
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
                              value: 'Waiting Confirmation',
                              child: Text('Waiting Confirmation'),
                            ),
                            DropdownMenuItem(
                              value: 'Approved',
                              child: Text('Approved'),
                            ),
                            DropdownMenuItem(
                              value: 'Cancelled',
                              child: Text('Cancelled'),
                            ),
                            DropdownMenuItem(
                              value: 'Completed',
                              child: Text('Completed'),
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
                return const Center(
                  child: Text('No booking history available.'),
                );
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
