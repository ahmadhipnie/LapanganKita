import 'package:dio/dio.dart';

import '../models/withdraw_model.dart';
import '../models/withdraw_summary_model.dart';
import '../network/api_client.dart';

class WithdrawRepository {
  WithdrawRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<WithdrawModel>> getWithdraws() async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'withdraws',
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(WithdrawModel.fromJson)
              .toList();
        }
        return const <WithdrawModel>[];
      }

      throw WithdrawException(
        _extractMessage(body) ??
            'Gagal memuat data withdraw (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const WithdrawException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw WithdrawException(message ?? 'Gagal memuat data withdraw.');
    } on FormatException catch (e) {
      throw WithdrawException(e.message);
    }
  }

  Future<WithdrawModel?> createWithdraw({
    required int userId,
    required int amount,
    required String proofPath,
  }) async {
    try {
      final fileName = proofPath.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'id_users': userId,
        'amount': amount,
        'file_photo': await MultipartFile.fromFile(
          proofPath,
          filename: fileName,
        ),
      });

      final response = await _apiClient.raw.post<Map<String, dynamic>>(
        'withdraws',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return _mapCreatedWithdraw(data);
        }
        return null;
      }

      throw WithdrawException(
        _extractMessage(body) ?? 'Gagal membuat withdraw (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const WithdrawException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw WithdrawException(message ?? 'Gagal membuat withdraw.');
    } on FormatException catch (e) {
      throw WithdrawException(e.message);
    }
  }

  Future<WithdrawBalanceSummary> getBalanceSummary({
    required int userId,
  }) async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'withdraws/balance',
        queryParameters: {'user_id': userId},
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        return WithdrawBalanceSummary.fromJson(body);
      }

      throw WithdrawException(
        _extractMessage(body) ??
            'Gagal memuat ringkasan saldo withdraw (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const WithdrawException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw WithdrawException(
        message ?? 'Gagal memuat ringkasan saldo withdraw.',
      );
    } on FormatException catch (e) {
      throw WithdrawException(e.message);
    }
  }

  Future<List<WithdrawModel>> getUserWithdraws({required int userId}) async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'withdraws/user',
        queryParameters: {'user_id': userId},
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(WithdrawModel.fromJson)
              .toList();
        }
        return const <WithdrawModel>[];
      }

      throw WithdrawException(
        _extractMessage(body) ??
            'Gagal memuat data withdraw pengguna (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const WithdrawException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw WithdrawException(
        message ?? 'Gagal memuat data withdraw pengguna.',
      );
    } on FormatException catch (e) {
      throw WithdrawException(e.message);
    }
  }

  Future<WithdrawModel> updateWithdraw({
    required int withdrawId,
    String? status,
    String? note,
    String? proofPath,
  }) async {
    try {
      final formDataMap = <String, dynamic>{};

      if (status != null && status.isNotEmpty) {
        formDataMap['status'] = status;
      }
      if (note != null && note.isNotEmpty) {
        formDataMap['note'] = note;
      }
      if (proofPath != null && proofPath.isNotEmpty) {
        final fileName = proofPath.split(RegExp(r'[\\/]')).last;
        formDataMap['file_photo'] = await MultipartFile.fromFile(
          proofPath,
          filename: fileName,
        );
      }

      final response = await _apiClient.raw.put<Map<String, dynamic>>(
        'withdraws/$withdrawId',
        data: FormData.fromMap(formDataMap),
        options: Options(contentType: 'multipart/form-data'),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return WithdrawModel.fromJson(data);
        }
        throw const WithdrawException('Respons server tidak valid.');
      }

      throw WithdrawException(
        _extractMessage(body) ??
            'Gagal memperbarui data withdraw (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const WithdrawException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw WithdrawException(message ?? 'Gagal memperbarui data withdraw.');
    } on FormatException catch (e) {
      throw WithdrawException(e.message);
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

  WithdrawModel? _mapCreatedWithdraw(Map<String, dynamic> payload) {
    final userInfo = payload['user_info'];

    final normalized = <String, dynamic>{
      'id': payload['withdraw_id'] ?? payload['id'],
      'id_users': payload['id_users'],
      'amount': payload['amount'],
      'file_photo': payload['file_photo'],
      'file_photo_url': payload['file_photo_url'] ?? payload['file_photo'],
      'created_at': payload['created_at'],
      'updated_at': payload['updated_at'],
      'user_name': userInfo is Map<String, dynamic>
          ? userInfo['user_name']
          : payload['user_name'],
      'user_email': userInfo is Map<String, dynamic>
          ? userInfo['user_email']
          : payload['user_email'],
    };

    return WithdrawModel.fromJson(normalized);
  }
}

class WithdrawException implements Exception {
  const WithdrawException(this.message);

  final String message;

  @override
  String toString() => 'WithdrawException: $message';
}
