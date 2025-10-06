// customer_history_model.dart
import 'package:flutter/material.dart';

class BookingHistory {
  final int id;
  final String courtName;
  final String location;
  final String orderId;
  final List<String> types;
  final DateTime date;
  final String startTime;
  final int duration;
  final double totalAmount;
  final String status; // waiting_confirmation, approved, rejected, completed
  final Map<String, int> equipment;
  final double courtPrice;
  final double equipmentTotal;

  BookingHistory({
    required this.id,
    required this.courtName,
    required this.location,
    required this.orderId,
    required this.types,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.totalAmount,
    required this.status,
    required this.equipment,
    required this.courtPrice,
    required this.equipmentTotal,
  });

  // Factory method to create from API response
  factory BookingHistory.fromApiResponse(Map<String, dynamic> data) {
    final bookingDate = DateTime.parse(data['booking_datetime_start']);
    final startTime = _formatTime(
      DateTime.parse(data['booking_datetime_start']),
    );
    final duration = _calculateDuration(
      DateTime.parse(data['booking_datetime_start']),
      DateTime.parse(data['booking_datetime_end']),
    );

    // Parse equipment/add-ons
    final equipment = <String, int>{};
    double equipmentTotal = 0;

    if (data['detail_bookings'] != null && data['detail_bookings'] is List) {
      for (final detail in data['detail_bookings']) {
        if (detail['add_on_name'] != null) {
          final equipmentName = detail['add_on_name'].toString();
          final quantity = detail['quantity'] ?? 1;
          final price = (detail['total_price'] ?? 0).toDouble();

          equipment[equipmentName] = quantity;
          equipmentTotal += price;
        }
      }
    }

    // Calculate court price per hour
    final totalPrice = (data['total_price'] ?? 0).toDouble();
    final courtPrice = _calculateCourtPrice(
      totalPrice,
      equipmentTotal,
      duration,
    );

    return BookingHistory(
      id: data['id'] ?? 0,
      courtName: data['field_name'] ?? 'Unknown Court',
      location: data['place_address'] ?? 'Unknown Location',
      orderId: data['order_id'] ?? 'unknown_id',
      types: [data['field_type'] ?? 'General'],
      date: bookingDate,
      startTime: startTime,
      duration: duration,
      totalAmount: totalPrice,
      status: _mapStatus(data['status']),
      equipment: equipment,
      courtPrice: courtPrice,
      equipmentTotal: equipmentTotal,
    );
  }

  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static int _calculateDuration(DateTime start, DateTime end) {
    return end.difference(start).inHours;
  }

  static double _calculateCourtPrice(
    double totalPrice,
    double equipmentTotal,
    int duration,
  ) {
    final courtTotal = totalPrice - equipmentTotal;
    // Return price per hour
    return duration > 0 ? courtTotal / duration : courtTotal;
  }

  static String _mapStatus(String apiStatus) {
    switch (apiStatus) {
      case 'waiting_confirmation':
        return 'pending';
      case 'approved':
        return 'approved';
      case 'rejected':
        return 'rejected';
      case 'completed':
        return 'completed';
      default:
        return 'pending';
    }
  }

  // Get icon for category
  IconData getCategoryIcon() {
    if (types.isEmpty) return Icons.sports;
    
    final category = types.first.toLowerCase();
    switch (category) {
      case 'tennis':
        return Icons.sports_tennis;
      case 'padel':
        return Icons.sports_tennis;
      case 'futsal':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'badminton':
        return Icons.sports;
      case 'mini soccer':
        return Icons.sports_soccer;
      default:
        return Icons.sports;
    }
  }

  // Get color for category
  Color getCategoryColor() {
    if (types.isEmpty) return Colors.grey;
    
    final category = types.first.toLowerCase();
    switch (category) {
      case 'tennis':
        return Colors.green;
      case 'padel':
        return Colors.orange;
      case 'futsal':
        return Colors.blue;
      case 'basketball':
        return Colors.red;
      case 'volleyball':
        return Colors.purple;
      case 'badminton':
        return Colors.teal;
      case 'mini soccer':
        return Colors.blue.shade700;
      default:
        return Colors.grey;
    }
  }

  // Helper method to calculate court total (courtPrice * duration)
  double get courtTotal => courtPrice * duration;
}