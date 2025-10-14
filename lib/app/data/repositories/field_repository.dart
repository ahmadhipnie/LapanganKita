import 'dart:io';
import 'package:dio/dio.dart';
import '../models/field_create_response.dart';
import '../models/field_delete_response.dart';
import '../models/field_model.dart';
import '../models/field_update_response.dart';
import '../models/field_verification_response.dart';
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

      print('Creating field with data: ${formData.fields}');
      
      final response = await _apiClient.raw.post<Map<String, dynamic>>(
        'fields',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 2), // Increase timeout for file upload
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      print('Response status: $statusCode, body: $body');

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = FieldCreateResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const FieldException('Failed to create field.');
      }

      throw FieldException(
        _extractMessage(body) ?? 'Failed to create field (status $statusCode).',
      );
    } on DioException catch (e) {
      print('DioException type: ${e.type}');
      print('DioException message: ${e.message}');
      print('DioException response: ${e.response?.data}');
      print('DioException statusCode: ${e.response?.statusCode}');
      
      if (e.type == DioExceptionType.sendTimeout) {
        throw const FieldException(
          'Upload took too long. Try using a smaller photo or check your internet connection..',
        );
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const FieldException(
          'Unable to connect to server. Check your connection..',
        );
      }
      
      // Handle other DioException types
      if (e.response != null) {
        final message = _extractMessage(e.response?.data);
        throw FieldException(message ?? 'Failed to create field (${e.response?.statusCode}).');
      }
      
      final message = e.message;
      throw FieldException(message ?? 'Failed to create field.');
    } on FormatException catch (e) {
      print('FormatException: ${e.message}');
      throw FieldException(e.message);
    } catch (e) {
      print('Unexpected error: $e');
      throw FieldException('Error: $e');
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

      print('Updating field with data: ${formData.fields}');
      
      final response = await _apiClient.raw.put<Map<String, dynamic>>(
        'fields/$fieldId',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 2), // Increase timeout for file upload
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      print('Response status: $statusCode, body: $body');

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = FieldUpdateResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const FieldException('Gagal memperbarui lapangan.');
      }

      throw FieldException(
        _extractMessage(body) ??
            'Gagal memperbarui lapangan (status $statusCode).',
      );
    } on DioException catch (e) {
      print('Update Field - DioException type: ${e.type}');
      print('Update Field - DioException message: ${e.message}');
      print('Update Field - DioException response: ${e.response?.data}');
      
      if (e.type == DioExceptionType.sendTimeout) {
        throw const FieldException(
          'Upload terlalu lama. Coba gunakan foto yang lebih kecil atau periksa koneksi internet Anda.',
        );
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const FieldException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      
      // Handle other DioException types
      if (e.response != null) {
        final message = _extractMessage(e.response?.data);
        throw FieldException(message ?? 'Gagal memperbarui lapangan (${e.response?.statusCode}).');
      }
      
      final message = e.message;
      throw FieldException(message ?? 'Gagal memperbarui lapangan.');
    } on FormatException catch (e) {
      print('Update Field - FormatException: ${e.message}');
      throw FieldException(e.message);
    } catch (e) {
      print('Update Field - Unexpected error: $e');
      throw FieldException('Error: $e');
    }
  }

  Future<List<FieldModel>> getFieldsByPlace({required int placeId}) async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'fields/place/$placeId',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
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
            'Gagal mengambil data lapangan (status $statusCode).',
      );
    } on DioException catch (e) {
      print('Get Fields - DioException type: ${e.type}');
      print('Get Fields - DioException message: ${e.message}');
      print('Get Fields - DioException response: ${e.response?.data}');
      
      if (e.type == DioExceptionType.sendTimeout) {
        throw const FieldException(
          'Permintaan terlalu lama. Periksa koneksi internet Anda.',
        );
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const FieldException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      
      // Handle other DioException types
      if (e.response != null) {
        final message = _extractMessage(e.response?.data);
        throw FieldException(message ?? 'Gagal mengambil data lapangan (${e.response?.statusCode}).');
      }
      
      final message = e.message;
      throw FieldException(message ?? 'Gagal mengambil data lapangan.');
    } on FormatException catch (e) {
      print('Get Fields - FormatException: ${e.message}');
      throw FieldException(e.message);
    } catch (e) {
      print('Get Fields - Unexpected error: $e');
      throw FieldException('Error: $e');
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
        throw const FieldException('Field data is invalid.');
      }

      throw FieldException(
        _extractMessage(body) ??
            'Failed to fetch field details (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const FieldException(
          'Unable to connect to server. Check your connection..',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw FieldException(message ?? 'Failed to fetch field details.');
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
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = FieldDeleteResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const FieldException('Gagal menghapus lapangan.');
      }

      throw FieldException(
        _extractMessage(body) ?? 'Gagal menghapus lapangan (status $statusCode).',
      );
    } on DioException catch (e) {
      print('Delete Field - DioException type: ${e.type}');
      print('Delete Field - DioException message: ${e.message}');
      print('Delete Field - DioException response: ${e.response?.data}');
      
      if (e.type == DioExceptionType.sendTimeout) {
        throw const FieldException(
          'Permintaan terlalu lama. Periksa koneksi internet Anda.',
        );
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const FieldException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      
      // Handle other DioException types
      if (e.response != null) {
        final message = _extractMessage(e.response?.data);
        throw FieldException(message ?? 'Gagal menghapus lapangan (${e.response?.statusCode}).');
      }
      
      final message = e.message;
      throw FieldException(message ?? 'Gagal menghapus lapangan.');
    } on FormatException catch (e) {
      print('Delete Field - FormatException: ${e.message}');
      throw FieldException(e.message);
    } catch (e) {
      print('Delete Field - Unexpected error: $e');
      throw FieldException('Error: $e');
    }
  }

  Future<FieldVerificationResponse> verifyField({
    required int fieldId,
    required String isVerifiedAdmin, // "approved" or "rejected"
    required int adminId,
  }) async {
    try {
      final response = await _apiClient.raw.patch<Map<String, dynamic>>(
        'fields/$fieldId/verification',
        data: {
          'is_verified_admin': isVerifiedAdmin,
          'admin_id': adminId,
        },
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = FieldVerificationResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw FieldException(
          parsed.message.isNotEmpty 
              ? parsed.message 
              : 'Gagal memverifikasi field.',
        );
      }

      throw FieldException(
        _extractMessage(body) ??
            'Failed to verify field (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const FieldException(
          'Unable to connect to server. Check your connection..',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw FieldException(message ?? 'Failed to verify field.');
    } on FormatException catch (e) {
      throw FieldException(e.message);
    }
  }

  Future<List<FieldModel>> getAllFields() async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'fields',
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
            'Failed to fetch field data (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const FieldException(
          'Unable to connect to server. Check your connection..',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw FieldException(message ?? 'Failed to fetch field data.');
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
