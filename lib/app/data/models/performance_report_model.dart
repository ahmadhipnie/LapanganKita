class PerformanceReport {
  const PerformanceReport({
    required this.profitToday,
    required this.profitWeek,
    required this.profitMonth,
    required this.transactions,
    this.currentBalance,
  });

  final int profitToday;
  final int profitWeek;
  final int profitMonth;
  final List<PerformanceTransaction> transactions;
  final int? currentBalance;

  factory PerformanceReport.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
        final cleaned = value.replaceAll(RegExp(r'[^0-9-]'), '');
        return int.tryParse(cleaned) ?? 0;
      }
      return 0;
    }

    final transactionsRaw = json['transactions'];
    final transactions = transactionsRaw is List
        ? transactionsRaw
              .whereType<Map<String, dynamic>>()
              .map(PerformanceTransaction.fromJson)
              .toList()
        : const <PerformanceTransaction>[];

    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      final parsed = parseInt(value);
      return parsed;
    }

    return PerformanceReport(
      profitToday: parseInt(
        json['today'] ?? json['today_profit'] ?? json['profit_today'],
      ),
      profitWeek: parseInt(
        json['this_week'] ?? json['week'] ?? json['profit_week'],
      ),
      profitMonth: parseInt(
        json['this_month'] ?? json['month'] ?? json['profit_month'],
      ),
      transactions: transactions,
      currentBalance: parseNullableInt(
        json['balance'] ??
            json['current_balance'] ??
            json['saldo'] ??
            json['total_balance'],
      ),
    );
  }

  PerformanceReport copyWith({
    int? profitToday,
    int? profitWeek,
    int? profitMonth,
    List<PerformanceTransaction>? transactions,
    int? currentBalance,
  }) {
    return PerformanceReport(
      profitToday: profitToday ?? this.profitToday,
      profitWeek: profitWeek ?? this.profitWeek,
      profitMonth: profitMonth ?? this.profitMonth,
      transactions: transactions ?? this.transactions,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }
}

class PerformanceTransaction {
  const PerformanceTransaction({
    required this.title,
    required this.date,
    required this.amount,
    this.reference,
    this.status,
  });

  final String title;
  final String date;
  final int amount;
  final String? reference;
  final String? status;

  factory PerformanceTransaction.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
        final cleaned = value.replaceAll(RegExp(r'[^0-9-]'), '');
        return int.tryParse(cleaned) ?? 0;
      }
      return 0;
    }

    String readString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return PerformanceTransaction(
      title: readString(
        json['title'] ?? json['name'] ?? json['description'],
      ).trim().ifEmpty(() => '-'),
      date: readString(
        json['date'] ?? json['created_at'] ?? json['time'],
      ).trim().ifEmpty(() => '-'),
      amount: parseInt(json['amount'] ?? json['total'] ?? json['price']),
      reference: readString(json['reference'] ?? json['order_id']).trim(),
      status: readString(json['status']).trim().ifEmptyOrNull,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'amount': amount,
      'reference': reference,
      'status': status,
    };
  }
}

extension _StringHelpers on String {
  String ifEmpty(String Function() fallback) {
    if (trim().isEmpty) {
      return fallback();
    }
    return this;
  }

  String? get ifEmptyOrNull {
    final trimmed = trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }
}
