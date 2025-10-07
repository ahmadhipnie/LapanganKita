// rating_model.dart
class RatingRequest {
  final String idBooking;
  final int ratingValue;
  final String review;

  RatingRequest({
    required this.idBooking,
    required this.ratingValue,
    required this.review,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_booking': idBooking,
      'rating_value': ratingValue,
      'review': review,
    };
  }
}

class RatingResponse {
  final bool success;
  final String message;
  final RatingData? data;

  RatingResponse({required this.success, required this.message, this.data});

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? RatingData.fromJson(json['data']) : null,
    );
  }
}

class RatingData {
  final int id;
  final String idBooking;
  final int ratingValue;
  final String review;
  final DateTime? createdAt;

  RatingData({
    required this.id,
    required this.idBooking,
    required this.ratingValue,
    required this.review,
    this.createdAt,
  });

  factory RatingData.fromJson(Map<String, dynamic> json) {
    return RatingData(
      id: json['id'] ?? 0,
      idBooking: json['id_booking']?.toString() ?? '',
      ratingValue: json['rating_value'] ?? 0,
      review: json['review'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
