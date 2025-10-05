import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../models/owner_booking_model.dart';
import '../models/performance_report_model.dart';
import '../network/api_client.dart';

class ReportRepository {
  ReportRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PerformanceReport> getOwnerPerformanceReport({
    required int ownerId,
  }) async {
    try {
      final response = await _apiClient.raw.get<Map<String, dynamic>>(
        'bookings/owner/bookings/',
        queryParameters: {'owner_id': ownerId},
      );

      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final success = body['success'];
        if (success is bool && !success) {
          throw ReportException(
            _extractMessage(body) ?? 'Failed to fetch performance report.',
          );
        }

        final extracted = _extractBookingPayload(body['data']);

        if (extracted != null) {
          final bookings = extracted.map(OwnerBooking.fromJson).toList();
          return _buildReportFromBookings(bookings);
        }

        if (body['data'] is Map<String, dynamic>) {
          return PerformanceReport.fromJson(
            body['data'] as Map<String, dynamic>,
          );
        }

        return const PerformanceReport(
          profitToday: 0,
          profitWeek: 0,
          profitMonth: 0,
          transactions: <PerformanceTransaction>[],
        );
      }

      throw ReportException(
        _extractMessage(body) ??
            'Failed to fetch performance report (status $statusCode).',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const ReportException(
          'Unable to reach the server. Please check your connection.',
        );
      }
      final message = _extractMessage(e.response?.data) ?? e.message;
      throw ReportException(message ?? 'Failed to fetch performance report.');
    } on FormatException catch (e) {
      throw ReportException(e.message);
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

  List<Map<String, dynamic>>? _extractBookingPayload(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      final nested = data['data'] ?? data['results'] ?? data['items'];
      if (nested is List) {
        return nested.whereType<Map<String, dynamic>>().toList();
      }
    }

    return null;
  }

  PerformanceReport _buildReportFromBookings(List<OwnerBooking> bookings) {
    if (bookings.isEmpty) {
      return const PerformanceReport(
        profitToday: 0,
        profitWeek: 0,
        profitMonth: 0,
        transactions: <PerformanceTransaction>[],
      );
    }

    final completedBookings = bookings
        .where(
          (booking) => booking.normalizedStatus == OwnerBookingStatus.completed,
        )
        .toList();

    if (completedBookings.isEmpty) {
      return const PerformanceReport(
        profitToday: 0,
        profitWeek: 0,
        profitMonth: 0,
        transactions: <PerformanceTransaction>[],
      );
    }

    completedBookings.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfToday.subtract(
      Duration(days: startOfToday.weekday - 1),
    );
    final startOfMonth = DateTime(now.year, now.month, 1);

    var profitToday = 0;
    var profitWeek = 0;
    var profitMonth = 0;

    final dateFormatter = DateFormat('dd MMM yyyy');
    final timeFormatter = DateFormat('HH:mm');

    final transactions = <PerformanceTransaction>[];

    for (final booking in completedBookings) {
      final bookingDate = booking.updatedAt;
      final amount = _normalizeAmount(booking.totalPrice);

      if (!bookingDate.isBefore(startOfToday)) {
        profitToday += amount;
      }

      if (!bookingDate.isBefore(startOfWeek)) {
        profitWeek += amount;
      }

      if (!bookingDate.isBefore(startOfMonth)) {
        profitMonth += amount;
      }

      final fieldName = booking.fieldName.trim();
      final title = fieldName.isEmpty
          ? 'Booking #${booking.id}'
          : 'Booking $fieldName';

      final formattedDate =
          '${dateFormatter.format(bookingDate)}, ${timeFormatter.format(bookingDate)}';

      final reference = booking.orderId.trim();
      final normalizedReference = reference.isEmpty || reference == '-'
          ? null
          : reference;

      transactions.add(
        PerformanceTransaction(
          title: title,
          date: formattedDate,
          amount: amount,
          reference: normalizedReference,
          status: booking.normalizedStatus.label,
        ),
      );
    }

    return PerformanceReport(
      profitToday: profitToday,
      profitWeek: profitWeek,
      profitMonth: profitMonth,
      transactions: transactions,
    );
  }

  int _normalizeAmount(num value) {
    if (value is int) return value;
    return value.round();
  }
}

class ReportException implements Exception {
  const ReportException(this.message);

  final String message;

  @override
  String toString() => 'ReportException: $message';
}
