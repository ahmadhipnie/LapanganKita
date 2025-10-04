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
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const AddOnException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw AddOnException(message ?? 'Gagal mengambil data add-on.');
    } on FormatException catch (e) {
      throw AddOnException(e.message);
    }
  }

  Future<AddOnResponse> createAddOn(AddOnPayload payload) async {
    try {
      final formData = FormData.fromMap({
        'add_on_name': payload.name,
        'price_per_hour': payload.pricePerHour,
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

      final response = await _apiClient.raw.post<Map<String, dynamic>>(
        'add-ons',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = AddOnResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const AddOnException('Gagal membuat add-on.');
      }

      throw AddOnException(
        _extractMessage(body) ?? 'Gagal membuat add-on (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const AddOnException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw AddOnException(message ?? 'Gagal membuat add-on.');
    } on FormatException catch (e) {
      throw AddOnException(e.message);
    }
  }

  Future<AddOnResponse> updateAddOn(AddOnUpdatePayload payload) async {
    try {
      final formMap = {
        'id_add_on': payload.id,
        'add_on_name': payload.name,
        'price_per_hour': payload.pricePerHour,
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
        options: Options(contentType: 'multipart/form-data'),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = AddOnResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const AddOnException('Gagal memperbarui add-on.');
      }

      throw AddOnException(
        _extractMessage(body) ??
            'Gagal memperbarui add-on (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const AddOnException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw AddOnException(message ?? 'Gagal memperbarui add-on.');
    } on FormatException catch (e) {
      throw AddOnException(e.message);
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
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const AddOnException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw AddOnException(message ?? 'Gagal menghapus add-on.');
    } on FormatException catch (e) {
      throw AddOnException(e.message);
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
