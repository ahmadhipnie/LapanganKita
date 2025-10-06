import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/customer/booking/booking_request.dart';
import '../models/customer/booking/booking_response.dart';
import '../network/api_client.dart';

class CustomerBookingRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<BookingResponse> createBooking(BookingRequest request) async {
    try {
      print('===== SENDING TO BACKEND =====');
      print('Endpoint: bookings');
      print('Data: ${request.toJson()}');
      print('==============================');

      final response = await _apiClient.post(
        'bookings',
        data: request.toJson(),
      );

      print('===== BACKEND RESPONSE =====');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Type: ${response.data.runtimeType}');
      print('============================');

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
      print('===== DIO ERROR DETAILS =====');
      print('Status Code: ${e.response?.statusCode}');
      print('Error Response: ${e.response?.data}');
      print('Error Message: ${e.message}');
      print('============================');

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
      print('===== GENERAL ERROR =====');
      print('Error: $e');
      print('========================');
      throw Exception('Booking failed: $e');
    }
  }
}
