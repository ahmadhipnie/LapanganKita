import 'dart:io';

import 'package:dio/dio.dart';

import 'package:lapangan_kita/app/data/models/promosi_model.dart';
import 'package:lapangan_kita/app/data/models/promosi_slider_image.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';

class PromosiRepository {
  PromosiRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PromosiModel>> getPromosiList() async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'promosi',
      );
      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(PromosiModel.fromJson)
              .toList();
        }
        return const <PromosiModel>[];
      }

      throw PromosiException(
        _extractMessage(body) ??
            'Gagal memuat data promosi (status $statusCode).',
      );
    } on DioException catch (e) {
      if (_isTimeout(e)) {
        throw const PromosiException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw PromosiException(message ?? 'Gagal memuat data promosi.');
    } on FormatException catch (e) {
      throw PromosiException(e.message);
    }
  }

  Future<PromosiModel> getPromosiDetail(int id) async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'promosi/$id',
      );
      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return PromosiModel.fromJson(data);
        }
        throw const PromosiException('Data promosi tidak ditemukan.');
      }

      throw PromosiException(
        _extractMessage(body) ??
            'Gagal memuat detail promosi (status $statusCode).',
      );
    } on DioException catch (e) {
      if (_isTimeout(e)) {
        throw const PromosiException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw PromosiException(message ?? 'Gagal memuat detail promosi.');
    } on FormatException catch (e) {
      throw PromosiException(e.message);
    }
  }

  Future<List<PromosiSliderImage>> getSliderImages() async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'promosi/slider',
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final images = body['images'];
        if (images is List) {
          return images
              .whereType<Map<String, dynamic>>()
              .map(PromosiSliderImage.fromJson)
              .toList();
        }
        return const <PromosiSliderImage>[];
      }

      throw PromosiException(
        _extractMessage(body) ??
            'Gagal memuat slider promosi (status $statusCode).',
      );
    } on DioException catch (e) {
      if (_isTimeout(e)) {
        throw const PromosiException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw PromosiException(message ?? 'Gagal memuat slider promosi.');
    } on FormatException catch (e) {
      throw PromosiException(e.message);
    }
  }

  Future<PromosiModel> createPromosi(File file) async {
    try {
      final fileName = file.path.split(RegExp(r'[\\\/]')).last;
      final formData = FormData.fromMap({
        'file_photo': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.raw.post<Map<String, dynamic>>(
        'promosi',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return PromosiModel.fromJson(data);
        }
        throw const PromosiException('Respons server tidak valid.');
      }

      throw PromosiException(
        _extractMessage(body) ?? 'Gagal membuat promosi (status $statusCode).',
      );
    } on DioException catch (e) {
      if (_isTimeout(e)) {
        throw const PromosiException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw PromosiException(message ?? 'Gagal membuat promosi.');
    } on FormatException catch (e) {
      throw PromosiException(e.message);
    }
  }

  Future<PromosiModel> updatePromosi({required int id, File? file}) async {
    if (file == null) {
      throw const PromosiException(
        'Silakan pilih gambar promosi terlebih dahulu.',
      );
    }

    try {
      final fileName = file.path.split(RegExp(r'[\\/]')).last;
      final formData = FormData();
      formData.files.add(
        MapEntry(
          'file_photo',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ),
      );

      final response = await _apiClient.raw.put<Map<String, dynamic>>(
        'promosi/$id',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return PromosiModel.fromJson(data);
        }
        throw const PromosiException('Respons server tidak valid.');
      }

      if (statusCode == 404) {
        throw const PromosiException('Endpoint promosi tidak ditemukan.');
      }

      throw PromosiException(
        _extractMessage(body) ??
            'Gagal memperbarui promosi (status $statusCode).',
      );
    } on DioException catch (e) {
      if (_isTimeout(e)) {
        throw const PromosiException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final response = e.response;
      if (response?.statusCode == 404) {
        throw const PromosiException('Endpoint promosi tidak ditemukan.');
      }

      final message = _extractMessage(response?.data) ?? e.message;
      throw PromosiException(message ?? 'Gagal memperbarui promosi.');
    } on FormatException catch (e) {
      throw PromosiException(e.message);
    }
  }

  Future<void> deletePromosi(int id) async {
    try {
      final response = await _apiClient.raw.delete<Map<String, dynamic>>(
        'promosi/$id',
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300) {
        return;
      }

      throw PromosiException(
        _extractMessage(body) ??
            'Gagal menghapus promosi (status $statusCode).',
      );
    } on DioException catch (e) {
      if (_isTimeout(e)) {
        throw const PromosiException(
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw PromosiException(message ?? 'Gagal menghapus promosi.');
    }
  }

  bool _isTimeout(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
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

class PromosiException implements Exception {
  const PromosiException(this.message);

  final String message;

  @override
  String toString() => 'PromosiException: $message';
}
