class BookingRequest {
  final int idUsers;
  final int fieldId;
  final DateTime bookingDatetimeStart;
  final DateTime bookingDatetimeEnd;
  final String snapToken;
  final String note;
  final List<Map<String, dynamic>> addOns;

  BookingRequest({
    required this.idUsers,
    required this.fieldId,
    required this.bookingDatetimeStart,
    required this.bookingDatetimeEnd,
    required this.snapToken,
    required this.note,
    required this.addOns,
  });

  Map<String, dynamic> toJson() {
    // Format datetime: "2025-10-06 15:00:00" sesuai contoh API
    String formatDateTime(DateTime dt) {
      return '${dt.year.toString().padLeft(4, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}:'
          '${dt.second.toString().padLeft(2, '0')}';
    }

    final json = {
      'id_users': idUsers,
      'field_id': fieldId,
      'booking_datetime_start': formatDateTime(bookingDatetimeStart),
      'booking_datetime_end': formatDateTime(bookingDatetimeEnd),
      'snap_token': snapToken,
      'note': note,
    };

    // Hanya tambahkan add_ons jika tidak kosong
    if (addOns.isNotEmpty) {
      json['add_ons'] = addOns;
    }

    return json;
  }
}
