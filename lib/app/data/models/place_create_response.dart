import 'place_model.dart';

class PlaceCreateResponse {
  const PlaceCreateResponse({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final PlaceModel? data;

  factory PlaceCreateResponse.fromJson(Map<String, dynamic> json) {
    return PlaceCreateResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? PlaceModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
