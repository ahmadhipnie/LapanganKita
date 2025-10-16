class BookingResponse {
  final int id;
  final String? orderId;
  final double? totalPrice;
  final String status;
  final String? message;
  final int? idUsers;
  final int? fieldId;
  final DateTime? bookingDatetimeStart;
  final DateTime? bookingDatetimeEnd;
  final String? snapToken;
  final String? note;

  BookingResponse({
    required this.id,
    this.orderId,
    this.totalPrice,
    required this.status,
    this.message,
    this.idUsers,
    this.fieldId,
    this.bookingDatetimeStart,
    this.bookingDatetimeEnd,
    this.snapToken,
    this.note,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    print('===== PARSING BOOKING RESPONSE =====');
    print('Raw JSON: $json');
    print('===================================');

    try {
      // Handle nested data structure
      Map<String, dynamic> data = json;

      // Jika response memiliki 'data' field, gunakan itu
      if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
        data = json['data'];
        print('Using nested data: $data');
      }

      // Backend bisa return 2 format berbeda
      // Format 1: Simple response dengan booking_id
      if (data.containsKey('booking_id')) {
        print('Format 1 detected: using booking_id');
        return BookingResponse(
          id: data['booking_id'] ?? 0,
          orderId: data['order_id']?.toString(),
          totalPrice: _parseDouble(data['total_price']),
          status: data['status']?.toString() ?? 'pending',
          message: data['message']?.toString(),
        );
      }

      // Format 2: Full booking data
      print('Format 2 detected: using direct fields');
      return BookingResponse(
        id: data['id'] ?? 0,
        orderId: data['order_id']?.toString(),
        totalPrice: _parseDouble(data['total_price']),
        status: data['status']?.toString() ?? 'pending',
        message: data['message']?.toString(),
        idUsers: data['id_users'],
        fieldId: data['field_id'],
        bookingDatetimeStart: data['booking_datetime_start'] != null
            ? DateTime.parse(data['booking_datetime_start'].toString())
            : null,
        bookingDatetimeEnd: data['booking_datetime_end'] != null
            ? DateTime.parse(data['booking_datetime_end'].toString())
            : null,
        snapToken: data['snap_token']?.toString(),
        note: data['note']?.toString(),
      );
    } catch (e) {
      print('===== ERROR PARSING RESPONSE =====');
      print('Error: $e');
      print('Stack trace: ${e.toString()}');
      print('==================================');
      rethrow;
    }
  }

  // Helper method untuk parse double dengan aman
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
