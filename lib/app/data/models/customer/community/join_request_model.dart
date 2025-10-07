class JoinRequest {
  final String id;
  final int userId;
  final String userName;
  final String status;
  final String? note;
  final String? avatarUrl;
  final DateTime requestedAt;
  final String userEmail;
  final String gender;
  final DateTime dateOfBirth;

  const JoinRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.status,
    required this.requestedAt,
    this.note,
    this.avatarUrl,
    required this.userEmail,
    required this.gender,
    required this.dateOfBirth,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic value) => value?.toString() ?? '';

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      return DateTime.parse(value.toString());
    }

    return JoinRequest(
      id: parseId(json['id']),
      userId: int.tryParse(json['id_users']?.toString() ?? '0') ?? 0,
      userName: json['joiner_name']?.toString() ?? 'Unknown User',
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      note: json['note']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      requestedAt: parseDateTime(json['created_at']),
      userEmail: json['joiner_email']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'male',
      dateOfBirth: parseDateTime(json['date_of_birth']),
    );
  }

  JoinRequest copyWith({
    String? id,
    int? userId,
    String? userName,
    String? status,
    String? note,
    String? avatarUrl,
    DateTime? requestedAt,
    String? userEmail,
    String? gender,
    DateTime? dateOfBirth,
  }) {
    return JoinRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      note: note ?? this.note,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      requestedAt: requestedAt ?? this.requestedAt,
      userEmail: userEmail ?? this.userEmail,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get formattedGender {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Laki-laki';
      case 'female':
        return 'Perempuan';
      default:
        return gender;
    }
  }

  int get age {
    final now = DateTime.now();
    final difference = now.difference(dateOfBirth);
    return (difference.inDays / 365).floor();
  }
}

class JoinRequestsResponse {
  final bool success;
  final String message;
  final List<JoinRequest> data;

  const JoinRequestsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory JoinRequestsResponse.fromJson(Map<String, dynamic> json) {
    return JoinRequestsResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => JoinRequest.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}