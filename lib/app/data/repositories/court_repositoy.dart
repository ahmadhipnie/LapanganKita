import 'package:dio/dio.dart';
import '../models/customer/booking/court_model.dart';
import '../network/api_client.dart';

class CourtRepository {
  CourtRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Court>> getCourts() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('fields');

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final apiResponse = ApiResponse.fromJson(body);

        if (apiResponse.success) {
          // Convert data to Court objects
          final courts = apiResponse.data.map<Court>((courtData) {
            return Court.fromJson(courtData as Map<String, dynamic>);
          }).toList();

          return courts;
        } else {
          throw CourtException(apiResponse.message);
        }
      }

      final message =
          _extractMessage(body) ??
          'Failed to fetch courts with status $statusCode';
      throw CourtException(message);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const CourtException(
          'Unable to reach the server. Check your connection.',
        );
      }

      final message =
          _extractMessage(e.response?.data) ??
          e.message ??
          'Failed to fetch courts.';
      throw CourtException(message);
    } on FormatException catch (e) {
      throw CourtException('Data format error: ${e.message}');
    } catch (e) {
      throw CourtException('Unexpected error: $e');
    }
  }

  Future<List<Court>> getCourtsByPlace({required int placeId}) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        'fields/place/$placeId',
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final apiResponse = ApiResponse.fromJson(body);

        if (apiResponse.success) {
          final courts = apiResponse.data.map<Court>((courtData) {
            return Court.fromJson(courtData as Map<String, dynamic>);
          }).toList();
          return courts;
        } else {
          throw CourtException(apiResponse.message);
        }
      }

      final message =
          _extractMessage(body) ??
          'Failed to fetch courts with status $statusCode';
      throw CourtException(message);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const CourtException(
          'Unable to reach the server. Check your connection.',
        );
      }
      final message =
          _extractMessage(e.response?.data) ??
          e.message ??
          'Failed to fetch courts.';
      throw CourtException(message);
    } on FormatException catch (e) {
      throw CourtException('Data format error: ${e.message}');
    } catch (e) {
      throw CourtException('Unexpected error: $e');
    }
  }

  Future<Court> getCourtDetail(int courtId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        'fields/$courtId',
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final apiResponse = ApiResponse.fromJson(body);

        if (apiResponse.success) {
          return Court.fromJson(apiResponse.data as Map<String, dynamic>);
        } else {
          throw CourtException(apiResponse.message);
        }
      }

      final message =
          _extractMessage(body) ??
          'Failed to fetch court detail with status $statusCode';
      throw CourtException(message);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const CourtException(
          'Unable to reach the server. Check your connection.',
        );
      }
      final message =
          _extractMessage(e.response?.data) ??
          e.message ??
          'Failed to fetch court detail.';
      throw CourtException(message);
    } on FormatException catch (e) {
      throw CourtException('Data format error: ${e.message}');
    } catch (e) {
      throw CourtException('Unexpected error: $e');
    }
  }

  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.map((e) => e.toString()).join(', ');
      }
      if (errors is Map && errors.isNotEmpty) {
        return errors.values
            .expand((value) => value is Iterable ? value : [value])
            .map((e) => e.toString())
            .join(', ');
      }
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    return null;
  }
}

class CourtException implements Exception {
  const CourtException(this.message);

  final String message;

  @override
  String toString() => 'CourtException: $message';
}
