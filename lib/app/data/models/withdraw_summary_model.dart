class WithdrawBalanceSummary {
  const WithdrawBalanceSummary({
    required this.userInfo,
    required this.balanceSummary,
    required this.places,
    required this.history,
  });

  final WithdrawUserInfo userInfo;
  final WithdrawBalanceInfo balanceSummary;
  final List<WithdrawPlaceDetail> places;
  final WithdrawHistorySummary history;

  factory WithdrawBalanceSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return WithdrawBalanceSummary(
        userInfo: WithdrawUserInfo.fromJson(
          data['user_info'] as Map<String, dynamic>? ?? const {},
        ),
        balanceSummary: WithdrawBalanceInfo.fromJson(
          data['balance_summary'] as Map<String, dynamic>? ?? const {},
        ),
        places: (data['places_detail'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(WithdrawPlaceDetail.fromJson)
            .toList(),
        history: WithdrawHistorySummary.fromJson(
          data['withdraw_history'] as Map<String, dynamic>? ?? const {},
        ),
      );
    }

    return const WithdrawBalanceSummary(
      userInfo: WithdrawUserInfo.empty,
      balanceSummary: WithdrawBalanceInfo.empty,
      places: <WithdrawPlaceDetail>[],
      history: WithdrawHistorySummary.empty,
    );
  }
}

class WithdrawUserInfo {
  const WithdrawUserInfo({required this.name, required this.email});

  static const empty = WithdrawUserInfo(name: '-', email: '-');

  final String name;
  final String email;

  factory WithdrawUserInfo.fromJson(Map<String, dynamic> json) {
    return WithdrawUserInfo(
      name: json['user_name']?.toString() ?? '-',
      email: json['user_email']?.toString() ?? '-',
    );
  }
}

class WithdrawBalanceInfo {
  const WithdrawBalanceInfo({
    required this.totalBalance,
    required this.totalPlaces,
    required this.canWithdraw,
  });

  static const empty = WithdrawBalanceInfo(
    totalBalance: 0,
    totalPlaces: 0,
    canWithdraw: false,
  );

  final int totalBalance;
  final int totalPlaces;
  final bool canWithdraw;

  factory WithdrawBalanceInfo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase();
        return normalized == 'true' || normalized == '1' || normalized == 'yes';
      }
      return false;
    }

    return WithdrawBalanceInfo(
      totalBalance: parseInt(json['total_balance']),
      totalPlaces: parseInt(json['total_places']),
      canWithdraw: parseBool(json['can_withdraw']),
    );
  }
}

class WithdrawPlaceDetail {
  const WithdrawPlaceDetail({
    required this.placeId,
    required this.placeName,
    required this.balance,
  });

  final int placeId;
  final String placeName;
  final int balance;

  factory WithdrawPlaceDetail.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return WithdrawPlaceDetail(
      placeId: parseInt(json['place_id']),
      placeName: json['place_name']?.toString() ?? '-',
      balance: parseInt(json['balance']),
    );
  }
}

class WithdrawHistorySummary {
  const WithdrawHistorySummary({
    required this.totalWithdraws,
    required this.totalWithdrawn,
  });

  static const empty = WithdrawHistorySummary(
    totalWithdraws: 0,
    totalWithdrawn: 0,
  );

  final int totalWithdraws;
  final int totalWithdrawn;

  factory WithdrawHistorySummary.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return WithdrawHistorySummary(
      totalWithdraws: parseInt(json['total_withdraws']),
      totalWithdrawn: parseInt(json['total_withdrawn']),
    );
  }
}
