class RefundModel {
  const RefundModel({
    required this.id,
    required this.bookingId,
    required this.totalRefund,
    required this.filePhoto,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.fieldId,
    required this.bookingTotalPrice,
    required this.bookingStatus,
    required this.bookingCreatedAt,
    required this.userName,
    required this.userEmail,
    required this.fieldName,
    required this.fieldType,
    required this.placeName,
    required this.placeAddress,
    required this.fieldOwnerName,
    required this.bankType,
    required this.accountNumber,
  });

  final int id;
  final int bookingId;
  final int totalRefund;
  final String? filePhoto;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int userId;
  final int fieldId;
  final int bookingTotalPrice;
  final String bookingStatus;
  final DateTime bookingCreatedAt;
  final String userName;
  final String userEmail;
  final String fieldName;
  final String fieldType;
  final String placeName;
  final String placeAddress;
  final String fieldOwnerName;
  final String bankType;
  final String accountNumber;

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (value is DateTime) return value.toLocal();
      final parsed = DateTime.tryParse(value.toString());
      return (parsed ?? DateTime.fromMillisecondsSinceEpoch(0)).toLocal();
    }

    String readString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return RefundModel(
      id: parseInt(json['id']),
      bookingId: parseInt(json['id_booking']),
      totalRefund: parseInt(json['total_refund']),
      filePhoto: json['file_photo']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      userId: parseInt(json['id_users']),
      fieldId: parseInt(json['field_id']),
      bookingTotalPrice: parseInt(json['booking_total_price']),
      bookingStatus: readString(json['booking_status']),
      bookingCreatedAt: parseDate(json['booking_created_at']),
      userName: readString(json['user_name']),
      userEmail: readString(json['user_email']),
      fieldName: readString(json['field_name']),
      fieldType: readString(json['field_type']),
      placeName: readString(json['place_name']),
      placeAddress: readString(json['place_address']),
      fieldOwnerName: readString(json['field_owner_name']),
      bankType: readString(json['bank_type']),
      accountNumber: readString(json['account_number']),
    );
  }

  String get statusLabel {
    final normalized = bookingStatus.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) return 'Unknown';
    return normalized
        .split(RegExp(r'\s+'))
        .where((element) => element.isNotEmpty)
        .map(
          (word) =>
              word.substring(0, 1).toUpperCase() +
              word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  String get fieldLocation {
    if (placeAddress.trim().isNotEmpty) {
      return placeAddress;
    }
    if (placeName.trim().isNotEmpty) {
      return placeName;
    }
    return '-';
  }

  String get customerLabel {
    if (userEmail.trim().isEmpty) {
      return userName;
    }
    return '$userName (${userEmail.trim()})';
  }

  String get normalizedBankType {
    final value = bankType.trim();
    if (value.isEmpty) {
      return '';
    }
    final lowered = value.toLowerCase();
    if (lowered == 'null' || lowered == '-') {
      return '';
    }
    return value;
  }

  String get normalizedAccountNumber {
    final value = accountNumber.trim();
    if (value.isEmpty) {
      return '';
    }
    final lowered = value.toLowerCase();
    if (lowered == 'null') {
      return '';
    }
    return value;
  }
}
