import 'package:dio/dio.dart';
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
      // Create URL-encoded data string exactly like Postman
      final data =
          'id_booking=$idBooking&rating_value=$ratingValue&review=${Uri.encodeComponent(review)}';

      print('🔄 Submitting rating with URL-encoded data: $data');

      final response = await _apiClient.raw.post(
        'ratings',
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      print(
        '✅ Rating submission response: ${response.statusCode} - ${response.data}',
      );
      return RatingResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Rating submission error: $e');
      throw Exception('Failed to submit rating: $e');
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
}
