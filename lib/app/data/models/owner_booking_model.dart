enum OwnerBookingStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  completed,
  unknown;

  static OwnerBookingStatus fromRaw(String? raw) {
    final normalized = raw?.toLowerCase().trim();
    switch (normalized) {
      case 'pending':
        return OwnerBookingStatus.pending;
      case 'accepted':
        return OwnerBookingStatus.accepted;
      case 'rejected':
        return OwnerBookingStatus.rejected;
      case 'cancelled':
        return OwnerBookingStatus.cancelled;
      case 'completed':
        return OwnerBookingStatus.completed;
      default:
        return OwnerBookingStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case OwnerBookingStatus.pending:
        return 'Pending';
      case OwnerBookingStatus.accepted:
        return 'Accepted';
      case OwnerBookingStatus.rejected:
        return 'Rejected';
      case OwnerBookingStatus.cancelled:
        return 'Cancelled';
      case OwnerBookingStatus.completed:
        return 'Completed';
      case OwnerBookingStatus.unknown:
        return 'Unknown';
    }
  }
}

class OwnerBookingDetail {
  const OwnerBookingDetail({
    required this.id,
    required this.bookingId,
    required this.addOnId,
    required this.quantity,
    required this.totalPrice,
    this.createdAt,
    this.updatedAt,
    this.addOnName,
    this.addOnDescription,
    this.pricePerHour,
  });

  final int id;
  final int bookingId;
  final int addOnId;
  final int quantity;
  final num totalPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? addOnName;
  final String? addOnDescription;
  final num? pricePerHour;

  factory OwnerBookingDetail.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString())?.toLocal();
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    num parseNum(dynamic value) {
      if (value is num) return value;
      if (value is String) {
        return num.tryParse(value) ?? 0;
      }
      return 0;
    }

    return OwnerBookingDetail(
      id: parseInt(json['id']),
      bookingId: parseInt(json['id_booking']),
      addOnId: parseInt(json['id_add_on']),
      quantity: parseInt(json['quantity']),
      totalPrice: parseNum(json['total_price']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      addOnName: json['add_on_name']?.toString(),
      addOnDescription: json['add_on_description']?.toString(),
      pricePerHour: json['price_per_hour'] is num
          ? json['price_per_hour'] as num
          : num.tryParse(json['price_per_hour']?.toString() ?? ''),
    );
  }
}

class OwnerBooking {
  const OwnerBooking({
    required this.id,
    required this.bookingStart,
    required this.bookingEnd,
    required this.orderId,
    required this.snapToken,
    required this.totalPrice,
    required this.note,
    required this.status,
    required this.fieldId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userEmail,
    required this.fieldName,
    required this.fieldType,
    required this.placeName,
    required this.placeAddress,
    required this.details,
  });

  final int id;
  final DateTime bookingStart;
  final DateTime bookingEnd;
  final String orderId;
  final String snapToken;
  final num totalPrice;
  final String? note;
  final String status;
  final int fieldId;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userName;
  final String userEmail;
  final String fieldName;
  final String fieldType;
  final String placeName;
  final String placeAddress;
  final List<OwnerBookingDetail> details;

  OwnerBookingStatus get normalizedStatus => OwnerBookingStatus.fromRaw(status);

  factory OwnerBooking.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value.toLocal();
      return DateTime.tryParse(value.toString())?.toLocal() ?? DateTime.now();
    }

    DateTime parseDateNullable(dynamic value, {required DateTime fallback}) {
      final parsed = DateTime.tryParse(value?.toString() ?? '');
      return (parsed ?? fallback).toLocal();
    }

    int parseInt(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? fallback;
      }
      return fallback;
    }

    num parseNum(dynamic value, {num fallback = 0}) {
      if (value is num) return value;
      if (value is String) {
        return num.tryParse(value) ?? fallback;
      }
      return fallback;
    }

    final detailsRaw = json['detail_bookings'];
    final parsedDetails = detailsRaw is List
        ? detailsRaw
              .whereType<Map<String, dynamic>>()
              .map(OwnerBookingDetail.fromJson)
              .toList()
        : const <OwnerBookingDetail>[];

    final createdAt = parseDateNullable(
      json['created_at'],
      fallback: DateTime.now(),
    );
    final updatedAt = parseDateNullable(
      json['updated_at'],
      fallback: createdAt,
    );

    return OwnerBooking(
      id: parseInt(json['id']),
      bookingStart: parseDate(json['booking_datetime_start']),
      bookingEnd: parseDate(json['booking_datetime_end']),
      orderId: json['order_id']?.toString() ?? '-',
      snapToken: json['snap_token']?.toString() ?? '',
      totalPrice: parseNum(json['total_price']),
      note: json['note']?.toString(),
      status: json['status']?.toString() ?? 'unknown',
      fieldId: parseInt(json['field_id']),
      userId: parseInt(json['id_users']),
      createdAt: createdAt,
      updatedAt: updatedAt,
      userName: json['user_name']?.toString() ?? '-',
      userEmail: json['user_email']?.toString() ?? '-',
      fieldName: json['field_name']?.toString() ?? '-',
      fieldType: json['field_type']?.toString() ?? '-',
      placeName: json['place_name']?.toString() ?? '-',
      placeAddress: json['place_address']?.toString() ?? '-',
      details: parsedDetails,
    );
  }

  OwnerBooking copyWith({String? status}) {
    return OwnerBooking(
      id: id,
      bookingStart: bookingStart,
      bookingEnd: bookingEnd,
      orderId: orderId,
      snapToken: snapToken,
      totalPrice: totalPrice,
      note: note,
      status: status ?? this.status,
      fieldId: fieldId,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userName: userName,
      userEmail: userEmail,
      fieldName: fieldName,
      fieldType: fieldType,
      placeName: placeName,
      placeAddress: placeAddress,
      details: details,
    );
  }
}
