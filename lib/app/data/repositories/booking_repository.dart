import 'package:dio/dio.dart';

import '../models/owner_booking_model.dart';
import '../network/api_client.dart';

class BookingRepository {
  BookingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<OwnerBooking>> getBookingsByOwner({required int ownerId}) async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'bookings/owner/bookings/',
        queryParameters: {'owner_id': ownerId},
        options: Options(headers: {'Cache-Control': 'no-cache'}),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final success = body['success'];
        if (success is bool && !success) {
          throw BookingException(
            _extractMessage(body) ?? 'Failed to fetch bookings.',
          );
        }

        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(OwnerBooking.fromJson)
              .toList();
        }

        return const <OwnerBooking>[];
      }

      throw BookingException(
        _extractMessage(body) ??
            'Failed to fetch bookings (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const BookingException(
          'Unable to reach the server. Please check your connection.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw BookingException(message ?? 'Failed to fetch bookings.');
    } on FormatException catch (e) {
      throw BookingException(e.message);
    }
  }

  Future<List<OwnerBooking>> getBookingsAll() async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'bookings',
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final success = body['success'];
        if (success is bool && !success) {
          throw BookingException(
            _extractMessage(body) ?? 'Failed to fetch bookings.',
          );
        }

        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(OwnerBooking.fromJson)
              .toList();
        }

        return const <OwnerBooking>[];
      }

      throw BookingException(
        _extractMessage(body) ??
            'Failed to fetch bookings (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const BookingException(
          'Unable to reach the server. Please check your connection.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw BookingException(message ?? 'Failed to fetch bookings.');
    } on FormatException catch (e) {
      throw BookingException(e.message);
    }
  }

  Future<String> updateBookingStatus({
    required int bookingId,
    required String status,
    required String note,
  }) async {
    try {
      final response = await _apiClient.raw.patch<Map<String, dynamic>>(
        'bookings/$bookingId/status',
        data: {'status': status, 'note': note},
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final success = body['success'];
        if (success == false) {
          throw BookingException(
            _extractMessage(body) ?? 'Failed to update booking status.',
          );
        }

        return _extractMessage(body) ?? 'Booking status updated.';
      }

      throw BookingException(
        _extractMessage(body) ??
            'Failed to update booking status (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const BookingException(
          'Unable to reach the server. Please check your connection.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw BookingException(message ?? 'Failed to update booking status.');
    } on FormatException catch (e) {
      throw BookingException(e.message);
    }
  }

  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}

class BookingException implements Exception {
  const BookingException(this.message);

  final String message;

  @override
  String toString() => 'BookingException: $message';
}
