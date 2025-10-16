import 'dart:io';

import 'package:dio/dio.dart';

import '../models/place_create_response.dart';
import '../models/place_model.dart';
import '../network/api_client.dart';
import '../models/place_update_response.dart';

class PlaceRepository {
  PlaceRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PlaceCreateResponse> createPlace({
    required String placeName,
    required String address,
    required int userId,
    File? placePhoto,
  }) async {
    try {
      final formData = FormData.fromMap({
        'place_name': placeName,
        'address': address,
        'balance': 0,
        'id_users': userId,
        if (placePhoto != null)
          'place_photo': await MultipartFile.fromFile(
            placePhoto.path,
            filename: _extractFileName(placePhoto.path),
          ),
      });

      final response = await _apiClient.raw.post<Map<String, dynamic>>(
        'places',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = PlaceCreateResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const PlaceException('Gagal membuat place.');
      }

      throw PlaceException(
        _extractMessage(body) ?? 'Gagal membuat place (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const PlaceException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw PlaceException(message ?? 'Gagal membuat place.');
    } on FormatException catch (e) {
      throw PlaceException(e.message);
    }
  }

  Future<List<PlaceModel>> getPlacesByOwner({required int userId}) async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'places/owner/$userId',
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(PlaceModel.fromJson)
              .toList();
        }
        return const <PlaceModel>[];
      }

      throw PlaceException(
        _extractMessage(body) ??
            'Gagal mengambil data place (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const PlaceException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw PlaceException(message ?? 'Gagal mengambil data place.');
    } on FormatException catch (e) {
      throw PlaceException(e.message);
    }
  }

  Future<List<PlaceModel>> getAllPlaces() async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>('places');

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(PlaceModel.fromJson)
              .toList();
        }
        return const <PlaceModel>[];
      }

      throw PlaceException(
        _extractMessage(body) ??
            'Gagal mengambil data place (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const PlaceException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw PlaceException(message ?? 'Gagal mengambil data place.');
    } on FormatException catch (e) {
      throw PlaceException(e.message);
    }
  }

  Future<PlaceUpdateResponse> updatePlace({
    required int placeId,
    required String placeName,
    required String address,
    required int userId,
    File? placePhoto,
  }) async {
    try {
      final payload = {
        'place_name': placeName,
        'address': address,
        'id_users': userId,
      };

      FormData? formData;
      dynamic requestBody;
      Options? options;

      if (placePhoto != null) {
        formData = FormData.fromMap({
          ...payload,
          'place_photo': await MultipartFile.fromFile(
            placePhoto.path,
            filename: _extractFileName(placePhoto.path),
          ),
        });
        requestBody = formData;
        options = Options(contentType: 'multipart/form-data');
      } else {
        requestBody = payload;
      }

      final response = await _apiClient.raw.put<Map<String, dynamic>>(
        'places/$placeId',
        data: requestBody,
        options: options,
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = PlaceUpdateResponse.fromJson(body);
        if (parsed.success) {
          return parsed;
        }
        throw const PlaceException('Gagal memperbarui data tempat.');
      }

      throw PlaceException(
        _extractMessage(body) ??
            'Gagal memperbarui data tempat (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const PlaceException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw PlaceException(message ?? 'Gagal memperbarui data tempat.');
    } on FormatException catch (e) {
      throw PlaceException(e.message);
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

class PlaceException implements Exception {
  const PlaceException(this.message);

  final String message;

  @override
  String toString() => 'PlaceException: $message';
}
