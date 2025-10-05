import 'dart:io';
import 'package:dio/dio.dart';
import '../models/field_create_response.dart';
import '../models/field_delete_response.dart';
import '../models/field_model.dart';
import '../models/field_update_response.dart';
import '../network/api_client.dart';

class FieldRepository {
  FieldRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<FieldCreateResponse> createField({
    required String fieldName,
    required String openingTime,
    required String closingTime,
    required int pricePerHour,
    required String description,
    required String fieldType,
    required File fieldPhoto,
    required String status,
    required int maxPerson,
    required int placeId,
    required int userId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'field_name': fieldName,
        'opening_time': openingTime,
        'closing_time': closingTime,
        'price_per_hour': pricePerHour,
        'description': description,
        'field_type': fieldType,
        'status': status,
        'max_person': maxPerson,
        'id_place': placeId,
        'id_users': userId,
        'field_photo': await MultipartFile.fromFile(
          fieldPhoto.path,
          filename: _extractFileName(fieldPhoto.path),
        ),
      });

      final response = await _apiClient.raw.post<Map<String, dynamic>>(
        'fields',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = FieldCreateResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const FieldException('Gagal membuat field.');
      }

      throw FieldException(
        _extractMessage(body) ?? 'Gagal membuat field (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const FieldException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw FieldException(message ?? 'Gagal membuat field.');
    } on FormatException catch (e) {
      throw FieldException(e.message);
    }
  }

  Future<FieldUpdateResponse> updateField({
    required int fieldId,
    required String fieldName,
    required String openingTime,
    required String closingTime,
    required int pricePerHour,
    required String description,
    required String fieldType,
    required String status,
    required int maxPerson,
    required int placeId,
    required int userId,
    File? fieldPhoto,
  }) async {
    try {
      final formData = FormData.fromMap({
        'field_name': fieldName,
        'opening_time': openingTime,
        'closing_time': closingTime,
        'price_per_hour': pricePerHour,
        'description': description,
        'field_type': fieldType,
        'status': status,
        'max_person': maxPerson,
        'id_place': placeId,
        'id_users': userId,
        if (fieldPhoto != null)
          'field_photo': await MultipartFile.fromFile(
            fieldPhoto.path,
            filename: _extractFileName(fieldPhoto.path),
          ),
      });

      final response = await _apiClient.raw.put<Map<String, dynamic>>(
        'fields/$fieldId',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = FieldUpdateResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const FieldException('Gagal memperbarui field.');
      }

      throw FieldException(
        _extractMessage(body) ??
            'Gagal memperbarui field (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const FieldException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw FieldException(message ?? 'Gagal memperbarui field.');
    } on FormatException catch (e) {
      throw FieldException(e.message);
    }
  }

  Future<List<FieldModel>> getFieldsByPlace({required int placeId}) async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'fields/place/$placeId',
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(FieldModel.fromJson)
              .toList();
        }
        return const <FieldModel>[];
      }

      throw FieldException(
        _extractMessage(body) ??
            'Gagal mengambil data field (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const FieldException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw FieldException(message ?? 'Gagal mengambil data field.');
    } on FormatException catch (e) {
      throw FieldException(e.message);
    }
  }

  Future<FieldModel> getFieldDetail(int fieldId) async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'fields/$fieldId',
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return FieldModel.fromJson(data);
        }
        throw const FieldException('Data field tidak valid.');
      }

      throw FieldException(
        _extractMessage(body) ??
            'Gagal mengambil detail field (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const FieldException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw FieldException(message ?? 'Gagal mengambil detail field.');
    } on FormatException catch (e) {
      throw FieldException(e.message);
    }
  }

  Future<FieldDeleteResponse> deleteField({
    required int fieldId,
    required int userId,
  }) async {
    try {
      final response = await _apiClient.raw.delete<Map<String, dynamic>>(
        'fields/$fieldId',
        data: {'id_users': userId},
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = FieldDeleteResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const FieldException('Gagal menghapus field.');
      }

      throw FieldException(
        _extractMessage(body) ?? 'Gagal menghapus field (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const FieldException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw FieldException(message ?? 'Gagal menghapus field.');
    } on FormatException catch (e) {
      throw FieldException(e.message);
    }
  }

  String _extractFileName(String path) {
    final segments = path.split(RegExp(r'[\\/]'));
    return segments.isNotEmpty ? segments.last : 'field-photo.jpg';
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

class FieldException implements Exception {
  const FieldException(this.message);

  final String message;

  @override
  String toString() => 'FieldException: $message';
}