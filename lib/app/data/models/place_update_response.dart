import 'place_model.dart';

class PlaceUpdateResponse {
  const PlaceUpdateResponse({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final PlaceModel? data;

  factory PlaceUpdateResponse.fromJson(Map<String, dynamic> json) {
    return PlaceUpdateResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? PlaceModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
