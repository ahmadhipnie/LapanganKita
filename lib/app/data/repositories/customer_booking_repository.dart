import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/customer/booking/booking_request.dart';
import '../models/customer/booking/booking_response.dart';
import '../network/api_client.dart';

class CustomerBookingRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<BookingResponse> createBooking(BookingRequest request) async {
    try {

      final response = await _apiClient.post(
        'bookings',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend bisa return data langsung atau wrapped dalam 'data' key
        final responseData = response.data is Map
            ? (response.data['data'] ?? response.data)
            : response.data;

        return BookingResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } on DioException catch (e) {

      // Extract backend error message if available
      String errorMessage = 'Booking failed';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage =
              e.response!.data['message'] ??
              e.response!.data['error'] ??
              'Booking failed: ${e.response!.statusCode}';
        } else {
          errorMessage = e.response!.data.toString();
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Booking failed: $e');
    }
  }
}
