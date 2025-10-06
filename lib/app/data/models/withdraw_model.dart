import 'package:intl/intl.dart';

class WithdrawModel {
  const WithdrawModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.filePhoto,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userEmail,
    required this.filePhotoUrl,
    required this.bankType,
    required this.accountNumber,
  });

  final int id;
  final int userId;
  final int amount;
  final String? filePhoto;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userName;
  final String userEmail;
  final String? filePhotoUrl;
  final String bankType;
  final String accountNumber;

  factory WithdrawModel.fromJson(Map<String, dynamic> json) {
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

    return WithdrawModel(
      id: parseInt(json['id']),
      userId: parseInt(json['id_users']),
      amount: parseInt(json['amount']),
      filePhoto: json['file_photo']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      userName: readString(json['user_name']),
      userEmail: readString(json['user_email']),
      filePhotoUrl: json['file_photo_url']?.toString(),
      bankType: readString(json['bank_type']),
      accountNumber: readString(json['account_number']),
    );
  }

  bool get isProcessed => filePhoto != null && filePhoto!.trim().isNotEmpty;

  String get displayStatus => isProcessed ? 'Processed' : 'Pending';

  String formattedDate({String pattern = 'dd MMM yyyy, HH:mm'}) {
    try {
      final formatter = DateFormat(pattern, 'id_ID');
      return formatter.format(createdAt.toLocal());
    } catch (_) {
      final fallbackFormatter = DateFormat(pattern);
      return fallbackFormatter.format(createdAt.toLocal());
    }
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
