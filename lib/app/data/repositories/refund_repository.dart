import 'dart:io';

import 'package:dio/dio.dart';

import '../models/refund_model.dart';
import '../network/api_client.dart';

class RefundRepository {
  RefundRepository(this._apiClient);

  final ApiClient _apiClient;
  final Map<int, Map<String, String>> _userBankCache =
      <int, Map<String, String>>{};

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
          final payloads = data.whereType<Map<String, dynamic>>().toList(
            growable: false,
          );
          final normalized = await _enrichRefundPayloads(payloads);
          return normalized.map(RefundModel.fromJson).toList();
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

  Future<List<Map<String, dynamic>>> _enrichRefundPayloads(
    List<Map<String, dynamic>> payloads,
  ) async {
    final normalized = payloads
        .map(_normalizeRefundPayload)
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

    if (missingUserIds.isEmpty) {
      return normalized;
    }

    final bankInfoMap = await _loadBankInfoForUsers(missingUserIds);
    if (bankInfoMap.isEmpty) {
      return normalized;
    }

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

    return normalized;
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
}

class RefundException implements Exception {
  const RefundException(this.message);

  final String message;

  @override
  String toString() => 'RefundException: $message';
}

Map<String, dynamic> _normalizeRefundPayload(Map<String, dynamic> payload) {
  final sources = <Map<String, dynamic>>[
    payload,
    if (payload['user_info'] is Map<String, dynamic>)
      payload['user_info'] as Map<String, dynamic>,
    if (payload['user'] is Map<String, dynamic>)
      payload['user'] as Map<String, dynamic>,
    if (payload['customer'] is Map<String, dynamic>)
      payload['customer'] as Map<String, dynamic>,
    if (payload['account_info'] is Map<String, dynamic>)
      payload['account_info'] as Map<String, dynamic>,
    if (payload['booking'] is Map<String, dynamic>)
      payload['booking'] as Map<String, dynamic>,
    if (payload['booking_user'] is Map<String, dynamic>)
      payload['booking_user'] as Map<String, dynamic>,
  ];

  String? readString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      if (!source.containsKey(key)) continue;
      final value = source[key];
      if (value == null) continue;
      final stringValue = value.toString().trim();
      if (stringValue.isEmpty) continue;
      final lowered = stringValue.toLowerCase();
      if (lowered == '-' || lowered == 'null' || lowered == 'undefined') {
        continue;
      }
      return stringValue;
    }
    return null;
  }

  String resolveValue(List<String> keys) {
    for (final source in sources) {
      final value = readString(source, keys);
      if (value != null) {
        return value;
      }
    }
    return '';
  }

  final normalized = Map<String, dynamic>.from(payload);
  normalized['bank_type'] = resolveValue([
    'bank_type',
    'bankType',
    'bank',
    'bank_name',
    'bankName',
  ]);
  normalized['account_number'] = resolveValue([
    'account_number',
    'accountNumber',
    'no_rekening',
    'rekening',
  ]);

  return normalized;
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
