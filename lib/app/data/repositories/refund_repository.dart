import 'dart:io';

import 'package:dio/dio.dart';

import '../models/refund_model.dart';
import '../network/api_client.dart';

class RefundRepository {
  RefundRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<RefundModel>> getRefunds() async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'refunds',
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final success = body['success'];
        if (success is bool && !success) {
          throw RefundException(
            _extractMessage(body) ?? 'Failed to fetch refunds.',
          );
        }

        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(RefundModel.fromJson)
              .toList();
        }

        return const <RefundModel>[];
      }

      throw RefundException(
        _extractMessage(body) ??
            'Failed to fetch refunds (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const RefundException(
          'Unable to reach the server. Please check your connection.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw RefundException(message ?? 'Failed to fetch refunds.');
    } on FormatException catch (e) {
      throw RefundException(e.message);
    }
  }

  Future<RefundProcessResult> createRefund({
    required int bookingId,
    required num totalRefund,
    required File proofFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'id_booking': bookingId,
        'total_refund': totalRefund,
        'file_photo': await MultipartFile.fromFile(proofFile.path),
      });

      final response = await _apiClient.raw.post<Map<String, dynamic>>(
        'refunds',
        data: formData,
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final success = body['success'];
        if (success is bool && !success) {
          throw RefundException(
            _extractMessage(body) ?? 'Failed to process refund.',
          );
        }

        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return RefundProcessResult.fromJson(data);
        }

        throw const RefundException('Refund processed but response invalid.');
      }

      throw RefundException(
        _extractMessage(body) ??
            'Failed to process refund (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const RefundException(
          'Unable to reach the server. Please check your connection.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw RefundException(message ?? 'Failed to process refund.');
    } on FormatException catch (e) {
      throw RefundException(e.message);
    }
  }

  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      final errors = body['errors'];
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
    if (body is String && body.isNotEmpty) {
      return body;
    }
    return null;
  }
}

class RefundException implements Exception {
  const RefundException(this.message);

  final String message;

  @override
  String toString() => 'RefundException: $message';
}

class RefundProcessResult {
  const RefundProcessResult({
    required this.refundId,
    required this.bookingId,
    required this.totalRefund,
    required this.filePhoto,
    required this.message,
  });

  factory RefundProcessResult.fromJson(Map<String, dynamic> json) {
    return RefundProcessResult(
      refundId: json['refund_id'] is String
          ? int.tryParse(json['refund_id'])
          : json['refund_id'] as int?,
      bookingId: json['id_booking'] is String
          ? int.tryParse(json['id_booking'])
          : json['id_booking'] as int?,
      totalRefund: json['total_refund'] is String
          ? num.tryParse(json['total_refund']) ?? 0
          : (json['total_refund'] as num?) ?? 0,
      filePhoto: json['file_photo'] as String?,
      message: json['message'] as String? ?? '',
    );
  }

  final int? refundId;
  final int? bookingId;
  final num totalRefund;
  final String? filePhoto;
  final String message;
}
