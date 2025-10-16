class FieldDeleteResponse {
  const FieldDeleteResponse({required this.success, required this.message});

  final bool success;
  final String message;

  factory FieldDeleteResponse.fromJson(Map<String, dynamic> json) {
    return FieldDeleteResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
    );
  }
}
