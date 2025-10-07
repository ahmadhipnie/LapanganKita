// customer_history_model.dart
import 'package:flutter/material.dart';

class BookingHistoryResponse {
  final bool success;
  final String message;
  final List<BookingHistory> data;

  BookingHistoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BookingHistoryResponse.fromJson(Map<String, dynamic> json) {
    return BookingHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => BookingHistory.fromApiResponse(item))
              .toList() ??
          [],
    );
  }
}

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
  final String status;
  final String note; // ✅ Tambahkan field note
  final List<BookingDetail> details;
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
    required this.note, // ✅ Tambahkan di constructor
    required this.details,
    required this.courtPrice,
    required this.equipmentTotal,
  });

  // Factory method to create from API response
  factory BookingHistory.fromApiResponse(Map<String, dynamic> data) {
    // Parse datetime dengan konversi timezone
    final bookingStartUtc = DateTime.parse(data['booking_datetime_start']);
    final bookingEndUtc = DateTime.parse(data['booking_datetime_end']);

    // Convert UTC to local time
    final bookingStartLocal = bookingStartUtc.toLocal();
    final bookingEndLocal = bookingEndUtc.toLocal();

    final startTime = _formatTime(bookingStartLocal);
    final duration = _calculateDuration(bookingStartLocal, bookingEndLocal);

    // Parse details
    final List<BookingDetail> details = [];
    double equipmentTotal = 0;

    if (data['detail_bookings'] != null && data['detail_bookings'] is List) {
      for (final detail in data['detail_bookings']) {
        final bookingDetail = BookingDetail.fromApiResponse(detail);
        details.add(bookingDetail);
        equipmentTotal += bookingDetail.totalPrice;
      }
    }

    // Calculate court price
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
      date: bookingStartLocal,
      startTime: startTime,
      duration: duration,
      totalAmount: totalPrice,
      status: _mapStatus(data['status']),
      note: data['note']?.toString() ?? '', // ✅ Ambil note dari API
      details: details,
      courtPrice: courtPrice,
      equipmentTotal: equipmentTotal,
    );
  }

  // Get equipment as Map untuk kompatibilitas dengan code existing
  Map<String, int> get equipment {
    final Map<String, int> result = {};
    for (final detail in details) {
      if (detail.addOnName.isNotEmpty) {
        result[detail.addOnName] = detail.quantity;
      }
    }
    return result;
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
    return duration > 0 ? courtTotal / duration : courtTotal;
  }

  static String _mapStatus(String apiStatus) {
    switch (apiStatus) {
      case 'waiting_confirmation':
        return 'pending';
      case 'approved':
        return 'approved';
      case 'cancelled':
        return 'rejected';
      case 'completed':
        return 'completed';
      default:
        return 'pending';
    }
  }

  // Helper methods
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

  double get courtTotal => courtPrice * duration;
  String get endTime =>
      '${(int.parse(startTime.split(':')[0]) + duration).toString().padLeft(2, '0')}:00';
  String get formattedTimeRange => '$startTime - $endTime';

  // ✅ Tambahkan copyWith method untuk memudahkan update
  BookingHistory copyWith({
    int? id,
    String? courtName,
    String? location,
    String? orderId,
    List<String>? types,
    DateTime? date,
    String? startTime,
    int? duration,
    double? totalAmount,
    String? status,
    String? note,
    List<BookingDetail>? details,
    double? courtPrice,
    double? equipmentTotal,
  }) {
    return BookingHistory(
      id: id ?? this.id,
      courtName: courtName ?? this.courtName,
      location: location ?? this.location,
      orderId: orderId ?? this.orderId,
      types: types ?? this.types,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      note: note ?? this.note,
      details: details ?? this.details,
      courtPrice: courtPrice ?? this.courtPrice,
      equipmentTotal: equipmentTotal ?? this.equipmentTotal,
    );
  }
}

class BookingDetail {
  final int id;
  final int bookingId;
  final int addOnId;
  final int quantity;
  final double totalPrice;
  final String addOnName;
  final String addOnDescription;
  final double pricePerHour;

  BookingDetail({
    required this.id,
    required this.bookingId,
    required this.addOnId,
    required this.quantity,
    required this.totalPrice,
    required this.addOnName,
    required this.addOnDescription,
    required this.pricePerHour,
  });

  factory BookingDetail.fromApiResponse(Map<String, dynamic> data) {
    return BookingDetail(
      id: data['id'] ?? 0,
      bookingId: data['id_booking'] ?? 0,
      addOnId: data['id_add_on'] ?? 0,
      quantity: (data['quantity'] ?? 1).toInt(),
      totalPrice: (data['total_price'] ?? 0).toDouble(),
      addOnName: data['add_on_name']?.toString() ?? '',
      addOnDescription: data['add_on_description']?.toString() ?? '',
      pricePerHour: (data['price_per_hour'] ?? 0).toDouble(),
    );
  }

  // Price per item (totalPrice / quantity)
  double get pricePerItem => quantity > 0 ? totalPrice / quantity : 0;
}
