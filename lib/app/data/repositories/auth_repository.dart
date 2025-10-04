import 'package:dio/dio.dart';

import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/otp_verify_response.dart';
import '../network/api_client.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        'users/login',
        data: {'email': email, 'password': password},
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        return LoginResponse.fromJson(body);
      }

      final message =
          _extractMessage(body) ?? 'Login failed with status $statusCode';
      throw AuthException(message);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const AuthException(
          'Unable to reach the server. Check connection.',
        );
      }

      final message =
          _extractMessage(e.response?.data) ?? e.message ?? 'Login failed.';
      throw AuthException(message);
    } on FormatException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<OtpVerifyResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        'users/verify-otp',
        data: {'email': email, 'otp': otp},
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        return OtpVerifyResponse.fromJson(body);
      }

      final message =
          _extractMessage(body) ??
          'OTP verification failed with status $statusCode';
      throw AuthException(message);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const AuthException(
          'Unable to reach the server. Check connection.',
        );
      }

      final message =
          _extractMessage(e.response?.data) ??
          e.message ??
          'OTP verification failed.';
      throw AuthException(message);
    } on FormatException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<RegisterResponse> register({required RegisterRequest request}) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        'users',
        data: request.toJson(),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        return RegisterResponse.fromJson(body);
      }

      final message =
          _extractMessage(body) ??
          'Registration failed with status $statusCode';
      throw AuthException(message);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const AuthException(
          'Unable to reach the server. Check connection.',
        );
      }

      final message =
          _extractMessage(e.response?.data) ??
          e.message ??
          'Registration failed.';
      throw AuthException(message);
    } on FormatException catch (e) {
      throw AuthException(e.message);
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

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}
