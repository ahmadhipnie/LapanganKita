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

// New models for GET ratings endpoint
class RatingsListResponse {
  final bool success;
  final String message;
  final int count;
  final List<RatingDetailData> data;

  RatingsListResponse({
    required this.success,
    required this.message,
    required this.count,
    required this.data,
  });

  factory RatingsListResponse.fromJson(Map<String, dynamic> json) {
    return RatingsListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => RatingDetailData.fromJson(item))
          .toList(),
    );
  }
}

class RatingDetailData {
  final int id;
  final int idBooking;
  final int ratingValue;
  final String review;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? bookingDatetimeStart;
  final DateTime? bookingDatetimeEnd;
  final double totalPrice;
  final String userName;
  final String userEmail;
  final String fieldName;
  final String fieldType;
  final String placeName;
  final String placeAddress;
  final String fieldOwnerName;

  RatingDetailData({
    required this.id,
    required this.idBooking,
    required this.ratingValue,
    required this.review,
    this.createdAt,
    this.updatedAt,
    this.bookingDatetimeStart,
    this.bookingDatetimeEnd,
    required this.totalPrice,
    required this.userName,
    required this.userEmail,
    required this.fieldName,
    required this.fieldType,
    required this.placeName,
    required this.placeAddress,
    required this.fieldOwnerName,
  });

  factory RatingDetailData.fromJson(Map<String, dynamic> json) {
    return RatingDetailData(
      id: json['id'] ?? 0,
      idBooking: json['id_booking'] ?? 0,
      ratingValue: json['rating_value'] ?? 0,
      review: json['review'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      bookingDatetimeStart: json['booking_datetime_start'] != null
          ? DateTime.tryParse(json['booking_datetime_start'])
          : null,
      bookingDatetimeEnd: json['booking_datetime_end'] != null
          ? DateTime.tryParse(json['booking_datetime_end'])
          : null,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      fieldName: json['field_name'] ?? '',
      fieldType: json['field_type'] ?? '',
      placeName: json['place_name'] ?? '',
      placeAddress: json['place_address'] ?? '',
      fieldOwnerName: json['field_owner_name'] ?? '',
    );
  }
}

// Rating summary helper class
class PlaceRatingSummary {
  final String placeName;
  final double averageRating;
  final int totalReviews;
  final List<RatingDetailData> reviews;

  PlaceRatingSummary({
    required this.placeName,
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  String get formattedAverageRating => averageRating.toStringAsFixed(1);
}
