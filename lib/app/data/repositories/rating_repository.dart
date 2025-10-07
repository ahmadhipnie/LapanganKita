import '../models/customer/rating/rating_model.dart';
import '../network/api_client.dart';

class RatingRepository {
  final ApiClient _apiClient;

  RatingRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Submit rating for a booking
  Future<RatingResponse> submitRating({
    required String idBooking,
    required int ratingValue,
    required String review,
  }) async {
    try {
      // Create JSON data matching the required format
      final data = {
        'id_booking': idBooking,
        'rating_value': ratingValue,
        'review': review,
      };

      print('🔄 Submitting rating with JSON data: $data');

      final response = await _apiClient.post('ratings', data: data);

      print(
        '✅ Rating submission response: ${response.statusCode} - ${response.data}',
      );
      return RatingResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Rating submission error: $e');
      throw Exception('Failed to submit rating: $e');
    }
  }

  /// Get all ratings from the API
  Future<RatingsListResponse> getAllRatings() async {
    try {
      print('🔄 Fetching all ratings from API');

      final response = await _apiClient.get('ratings');

      print(
        '✅ Ratings fetch response: ${response.statusCode} - Count: ${response.data['count']}',
      );
      return RatingsListResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Rating fetch error: $e');
      throw Exception('Failed to get ratings: $e');
    }
  }

  /// Get ratings for a specific booking (optional, for future use)
  Future<RatingResponse> getRatingByBooking(String bookingId) async {
    try {
      final response = await _apiClient.get('ratings/booking/$bookingId');
      return RatingResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get rating: $e');
    }
  }

  /// Get rating summary for a specific place
  PlaceRatingSummary getPlaceRatingSummary(
    String placeName,
    List<RatingDetailData> allRatings,
  ) {
    // Filter ratings for this place
    final placeRatings = allRatings
        .where((rating) => rating.placeName == placeName)
        .toList();

    if (placeRatings.isEmpty) {
      return PlaceRatingSummary(
        placeName: placeName,
        averageRating: 0.0,
        totalReviews: 0,
        reviews: [],
      );
    }

    // Calculate average rating
    final totalRating = placeRatings.fold<double>(
      0,
      (sum, rating) => sum + rating.ratingValue,
    );
    final averageRating = totalRating / placeRatings.length;

    return PlaceRatingSummary(
      placeName: placeName,
      averageRating: averageRating,
      totalReviews: placeRatings.length,
      reviews: placeRatings,
    );
  }
}
