import 'field_model.dart';

class FieldCreateResponse {
  const FieldCreateResponse({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final FieldModel? data;

  factory FieldCreateResponse.fromJson(Map<String, dynamic> json) {
    return FieldCreateResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? FieldModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
