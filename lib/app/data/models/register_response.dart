import 'user_model.dart';

class RegisterResponse {
  const RegisterResponse({
    required this.success,
    required this.message,
    this.user,
    this.emailSent,
    this.note,
  });

  final bool success;
  final String message;
  final UserModel? user;
  final bool? emailSent;
  final String? note;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase();
        if (normalized == 'true' || normalized == 'success') {
          return true;
        }
        if (normalized == 'false' || normalized == 'failed') {
          return false;
        }
      }
      return false;
    }

    bool? parseNullableBool(dynamic value) {
      if (value == null) return null;
      return parseBool(value);
    }

    return RegisterResponse(
      success: parseBool(json['success']),
      message: json['message']?.toString() ?? '',
      user: json['data'] is Map<String, dynamic>
          ? UserModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      emailSent: parseNullableBool(json['emailSent']),
      note: json['note']?.toString(),
    );
  }
}
