import 'package:dio/dio.dart';

import '../models/add_on_model.dart';
import '../network/api_client.dart';

class AddOnRepository {
  AddOnRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AddOnModel>> getAddOnsByPlace({required int placeId}) async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'add-ons/place/$placeId',
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
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .map(AddOnModel.fromJson)
              .toList();
        }
        return const <AddOnModel>[];
      }

      throw AddOnException(
        _extractMessage(body) ??
            'Gagal mengambil data add-on (status $statusCode).',
      );
    } on DioException catch (e) {
      print('Get AddOns - DioException type: ${e.type}');
      print('Get AddOns - DioException message: ${e.message}');
      print('Get AddOns - DioException response: ${e.response?.data}');
      
      if (e.type == DioExceptionType.sendTimeout) {
        throw const AddOnException(
          'Permintaan terlalu lama. Periksa koneksi internet Anda.',
        );
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AddOnException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      
      // Handle other DioException types
      if (e.response != null) {
        final message = _extractMessage(e.response?.data);
        throw AddOnException(message ?? 'Gagal mengambil data add-on (${e.response?.statusCode}).');
      }
      
      final message = e.message;
      throw AddOnException(message ?? 'Gagal mengambil data add-on.');
    } on FormatException catch (e) {
      print('Get AddOns - FormatException: ${e.message}');
      throw AddOnException(e.message);
    } catch (e) {
      print('Get AddOns - Unexpected error: $e');
      throw AddOnException('Error: $e');
    }
  }

  Future<AddOnResponse> createAddOn(AddOnPayload payload) async {
    try {
      final formData = FormData.fromMap({
        'add_on_name': payload.name,
        'price': payload.price,
        'category': payload.category,
        'add_on_description': payload.description,
        'stock': payload.stock,
        'place_id': payload.placeId,
        'id_users': payload.userId,
        if (payload.photo != null)
          'add_on_photo': await MultipartFile.fromFile(
            payload.photo!.path,
            filename: _extractFileName(payload.photo!.path),
          ),
      });

      print('Creating add-on with data: ${formData.fields}');
      
      final response = await _apiClient.raw.post<Map<String, dynamic>>(
        'add-ons',
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
        final parsed = AddOnResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const AddOnException('Failed to create add-on.');
      }

      throw AddOnException(
        _extractMessage(body) ?? 'Failed to create add-on (status $statusCode).',
      );
    } on DioException catch (e) {
      print('DioException type: ${e.type}');
      print('DioException message: ${e.message}');
      print('DioException response: ${e.response?.data}');
      print('DioException statusCode: ${e.response?.statusCode}');
      
      if (e.type == DioExceptionType.sendTimeout) {
        throw const AddOnException(
          'Upload took too long. Try using a smaller photo or check your internet connection..',
        );
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AddOnException(
          'Unable to connect to server. Check your connection..',
        );
      }
      
      // Handle other DioException types
      if (e.response != null) {
        final message = _extractMessage(e.response?.data);
        throw AddOnException(message ?? 'Failed to create add-on (${e.response?.statusCode}).');
      }
      
      final message = e.message;
      throw AddOnException(message ?? 'Failed to create add-on.');
    } on FormatException catch (e) {
      print('FormatException: ${e.message}');
      throw AddOnException(e.message);
    } catch (e) {
      print('Unexpected error: $e');
      throw AddOnException('Error: $e');
    }
  }

  Future<AddOnResponse> updateAddOn(AddOnUpdatePayload payload) async {
    try {
      final formMap = {
        'id_add_on': payload.id,
        'add_on_name': payload.name,
        'price': payload.price,
        'category': payload.category,
        'add_on_description': payload.description,
        'stock': payload.stock,
        'id_users': payload.userId,
        if (payload.placeId != null) 'place_id': payload.placeId,
      };

      final formData = FormData.fromMap({
        ...formMap,
        if (payload.photo != null)
          'add_on_photo': await MultipartFile.fromFile(
            payload.photo!.path,
            filename: _extractFileName(payload.photo!.path),
          ),
      });

      final response = await _apiClient.raw.put<Map<String, dynamic>>(
        'add-ons/${payload.id}',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 2), // Increase timeout for file upload
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = AddOnResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const AddOnException('Failed to update add-on.');
      }

      throw AddOnException(
        _extractMessage(body) ??
            'Gagal memperbarui add-on (status $statusCode).',
      );
    } on DioException catch (e) {
      print('Update AddOn - DioException type: ${e.type}');
      print('Update AddOn - DioException message: ${e.message}');
      print('Update AddOn - DioException response: ${e.response?.data}');
      
      if (e.type == DioExceptionType.sendTimeout) {
        throw const AddOnException(
          'Upload terlalu lama. Coba gunakan foto yang lebih kecil atau periksa koneksi internet Anda.',
        );
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AddOnException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      
      // Handle other DioException types
      if (e.response != null) {
        final message = _extractMessage(e.response?.data);
        throw AddOnException(message ?? 'Gagal memperbarui add-on (${e.response?.statusCode}).');
      }
      
      final message = e.message;
      throw AddOnException(message ?? 'Gagal memperbarui add-on.');
    } on FormatException catch (e) {
      print('Update AddOn - FormatException: ${e.message}');
      throw AddOnException(e.message);
    } catch (e) {
      print('Update AddOn - Unexpected error: $e');
      throw AddOnException('Error: $e');
    }
  }

  Future<AddOnResponse> deleteAddOn({
    required int addOnId,
    required int userId,
  }) async {
    try {
      final response = await _apiClient.raw.delete<Map<String, dynamic>>(
        'add-ons/$addOnId',
        data: {'id_users': userId},
        queryParameters: {'id_users': userId},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = AddOnResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const AddOnException('Gagal menghapus add-on.');
      }

      throw AddOnException(
        _extractMessage(body) ?? 'Gagal menghapus add-on (status $statusCode).',
      );
    } on DioException catch (e) {
      print('Delete AddOn - DioException type: ${e.type}');
      print('Delete AddOn - DioException message: ${e.message}');
      print('Delete AddOn - DioException response: ${e.response?.data}');
      
      if (e.type == DioExceptionType.sendTimeout) {
        throw const AddOnException(
          'Permintaan terlalu lama. Periksa koneksi internet Anda.',
        );
      }
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AddOnException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      
      // Handle other DioException types
      if (e.response != null) {
        final message = _extractMessage(e.response?.data);
        throw AddOnException(message ?? 'Gagal menghapus add-on (${e.response?.statusCode}).');
      }
      
      final message = e.message;
      throw AddOnException(message ?? 'Gagal menghapus add-on.');
    } on FormatException catch (e) {
      print('Delete AddOn - FormatException: ${e.message}');
      throw AddOnException(e.message);
    } catch (e) {
      print('Delete AddOn - Unexpected error: $e');
      throw AddOnException('Error: $e');
    }
  }

  String _extractFileName(String path) {
    final segments = path.split(RegExp(r'[\\/]'));
    return segments.isNotEmpty ? segments.last : 'upload.jpg';
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

class AddOnException implements Exception {
  const AddOnException(this.message);

  final String message;

  @override
  String toString() => 'AddOnException: $message';
}
