import 'user_model.dart';

class OtpVerifyResponse {
  const OtpVerifyResponse({
    required this.success,
    required this.message,
    this.user,
  });

  final bool success;
  final String message;
  final UserModel? user;

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
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

    return OtpVerifyResponse(
      success: parseBool(json['success']),
      message: json['message']?.toString() ?? '',
      user: json['data'] is Map<String, dynamic>
          ? UserModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
