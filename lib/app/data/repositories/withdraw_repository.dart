import 'package:dio/dio.dart';

import '../models/withdraw_model.dart';
import '../models/withdraw_summary_model.dart';
import '../network/api_client.dart';

class WithdrawRepository {
  WithdrawRepository(this._apiClient);

  final ApiClient _apiClient;
  final Map<int, Map<String, String>> _userBankCache =
      <int, Map<String, String>>{};

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
          final payloads = data.whereType<Map<String, dynamic>>().toList(
            growable: false,
          );
          final normalized = await _enrichWithdrawPayloads(payloads);
          return normalized.map(WithdrawModel.fromJson).toList();
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
          final normalized = await _enrichSingleWithdrawPayload(data);
          return WithdrawModel.fromJson(normalized);
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
          final payloads = data.whereType<Map<String, dynamic>>().toList(
            growable: false,
          );
          final normalized = await _enrichWithdrawPayloads(payloads);
          return normalized.map(WithdrawModel.fromJson).toList();
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
          final normalized = await _enrichSingleWithdrawPayload(data);
          return WithdrawModel.fromJson(normalized);
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

  Map<String, dynamic> _normalizeWithdrawPayload(Map<String, dynamic> payload) {
    final userInfo = payload['user_info'];

    String? readMerged(Map<String, dynamic>? source, String key, String? base) {
      if (source != null && source.containsKey(key)) {
        final value = source[key];
        if (value != null) return value;
      }
      return base;
    }

    return <String, dynamic>{
      'id': payload['withdraw_id'] ?? payload['id'],
      'id_users':
          payload['id_users'] ??
          payload['user_id'] ??
          (userInfo is Map<String, dynamic> ? userInfo['id_users'] : null),
      'amount': payload['amount'],
      'file_photo': payload['file_photo'],
      'file_photo_url': payload['file_photo_url'] ?? payload['file_photo'],
      'created_at': payload['created_at'],
      'updated_at': payload['updated_at'],
      'user_name': readMerged(
        userInfo is Map<String, dynamic> ? userInfo : null,
        'user_name',
        payload['user_name'],
      ),
      'user_email': readMerged(
        userInfo is Map<String, dynamic> ? userInfo : null,
        'user_email',
        payload['user_email'],
      ),
      'bank_type': readMerged(
        userInfo is Map<String, dynamic> ? userInfo : null,
        'bank_type',
        payload['bank_type'],
      ),
      'account_number': readMerged(
        userInfo is Map<String, dynamic> ? userInfo : null,
        'account_number',
        payload['account_number'],
      ),
    };
  }

  Future<List<Map<String, dynamic>>> _enrichWithdrawPayloads(
    List<Map<String, dynamic>> payloads,
  ) async {
    final normalized = payloads
        .map(_normalizeWithdrawPayload)
        .toList(growable: false);

    final missingUserIds = <int>{};
    for (final item in normalized) {
      final bank = _sanitizeUserValue(item['bank_type']);
      final account = _sanitizeUserValue(item['account_number']);
      if (_hasMeaningfulValue(bank) && _hasMeaningfulValue(account)) {
        continue;
      }
      final userId = _parseUserId(item['id_users']);
      if (userId != null) {
        missingUserIds.add(userId);
      }
    }

    if (missingUserIds.isNotEmpty) {
      final bankInfoMap = await _loadBankInfoForUsers(missingUserIds);
      if (bankInfoMap.isNotEmpty) {
        for (final item in normalized) {
          final userId = _parseUserId(item['id_users']);
          if (userId == null) continue;
          final info = bankInfoMap[userId];
          if (info == null) continue;

          final existingBank = _sanitizeUserValue(item['bank_type']);
          final existingAccount = _sanitizeUserValue(item['account_number']);
          final fetchedBank = _sanitizeUserValue(info['bank_type']);
          final fetchedAccount = _sanitizeUserValue(info['account_number']);

          if (!_hasMeaningfulValue(existingBank) &&
              _hasMeaningfulValue(fetchedBank)) {
            item['bank_type'] = fetchedBank;
          }
          if (!_hasMeaningfulValue(existingAccount) &&
              _hasMeaningfulValue(fetchedAccount)) {
            item['account_number'] = fetchedAccount;
          }
        }
      }
    }

    return normalized;
  }

  Future<Map<String, dynamic>> _enrichSingleWithdrawPayload(
    Map<String, dynamic> payload,
  ) async {
    final normalized = _normalizeWithdrawPayload(payload);

    final bank = _sanitizeUserValue(normalized['bank_type']);
    final account = _sanitizeUserValue(normalized['account_number']);
    if (_hasMeaningfulValue(bank) && _hasMeaningfulValue(account)) {
      return normalized;
    }

    final userId = _parseUserId(normalized['id_users']);
    if (userId == null) {
      return normalized;
    }

    final info = await _fetchUserBankInfo(userId);
    if (info != null) {
      final fetchedBank = _sanitizeUserValue(info['bank_type']);
      final fetchedAccount = _sanitizeUserValue(info['account_number']);

      if (!_hasMeaningfulValue(bank) && _hasMeaningfulValue(fetchedBank)) {
        normalized['bank_type'] = fetchedBank;
      }
      if (!_hasMeaningfulValue(account) &&
          _hasMeaningfulValue(fetchedAccount)) {
        normalized['account_number'] = fetchedAccount;
      }
    }

    return normalized;
  }

  Future<Map<String, String>?> getUserBankInfo(int userId) async {
    final info = await _fetchUserBankInfo(userId);
    if (info == null) {
      return null;
    }

    final bank = _sanitizeUserValue(info['bank_type']);
    final account = _sanitizeUserValue(info['account_number']);

    if (!_hasMeaningfulValue(bank) && !_hasMeaningfulValue(account)) {
      return null;
    }

    return {
      if (_hasMeaningfulValue(bank)) 'bank_type': bank,
      if (_hasMeaningfulValue(account)) 'account_number': account,
    };
  }

  Future<Map<int, Map<String, String>>> _loadBankInfoForUsers(
    Set<int> userIds,
  ) async {
    final results = <int, Map<String, String>>{};

    await Future.wait(
      userIds.map((userId) async {
        final info = await _fetchUserBankInfo(userId);
        if (info != null) {
          final bank = _sanitizeUserValue(info['bank_type']);
          final account = _sanitizeUserValue(info['account_number']);
          if (_hasMeaningfulValue(bank) || _hasMeaningfulValue(account)) {
            results[userId] = {'bank_type': bank, 'account_number': account};
          }
        }
      }),
    );

    return results;
  }

  Future<Map<String, String>?> _fetchUserBankInfo(int userId) async {
    final cached = _userBankCache[userId];
    if (cached != null) {
      return cached;
    }

    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'users/$userId',
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final success = body['success'];
        if (success is bool && !success) {
          return null;
        }

        final data = body['data'];
        if (data is Map<String, dynamic>) {
          final bank = _sanitizeUserValue(data['bank_type']);
          final account = _sanitizeUserValue(data['account_number']);
          final info = <String, String>{
            'bank_type': bank,
            'account_number': account,
          };
          _userBankCache[userId] = info;
          if (_hasMeaningfulValue(bank) || _hasMeaningfulValue(account)) {
            return info;
          }
        }
      }
    } catch (_) {
      // Ignore fetch errors and fall back to existing data if any.
    }

    return _userBankCache[userId];
  }
}

class WithdrawException implements Exception {
  const WithdrawException(this.message);

  final String message;

  @override
  String toString() => 'WithdrawException: $message';
}

int? _parseUserId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

String _sanitizeUserValue(dynamic value) {
  if (value == null) return '';
  final stringValue = value.toString().trim();
  if (!_hasMeaningfulValue(stringValue)) {
    return '';
  }
  return stringValue;
}

bool _hasMeaningfulValue(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return false;
  }
  final lowered = trimmed.toLowerCase();
  return lowered != 'null' && lowered != '-' && lowered != 'undefined';
}
