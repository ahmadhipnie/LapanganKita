import 'field_model.dart';

class FieldVerificationResponse {
  const FieldVerificationResponse({
    required this.success,
    required this.message,
    this.data,
    this.previousStatus,
    this.newStatus,
  });

  final bool success;
  final String message;
  final FieldModel? data;
  final String? previousStatus;
  final String? newStatus;

  factory FieldVerificationResponse.fromJson(Map<String, dynamic> json) {
    return FieldVerificationResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? FieldModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      previousStatus: json['previous_status']?.toString(),
      newStatus: json['new_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'previous_status': previousStatus,
      'new_status': newStatus,
    };
  }
}
