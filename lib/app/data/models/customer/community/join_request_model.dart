class JoinRequest {
  final int id;
  final int userId;
  final int bookingId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String joinerName;
  final String joinerEmail;
  final String joinerPhone;
  final String? joinerPhoto;
  final String joinerGender;
  final DateTime joinerBirthDate;
  final DateTime bookingDatetimeStart;
  final DateTime bookingDatetimeEnd;
  final int posterUserId;
  final String posterName;
  final String posterPhone;
  final String posterPhoto;
  final String fieldName;
  final String fieldType;
  final int maxPerson;
  final String placeName;
  final String postTitle;
  final int currentJoinedCount;

  const JoinRequest({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.joinerName,
    required this.joinerEmail,
    required this.joinerPhone,
    this.joinerPhoto,
    required this.joinerGender,
    required this.joinerBirthDate,
    required this.bookingDatetimeStart,
    required this.bookingDatetimeEnd,
    required this.posterUserId,
    required this.posterName,
    required this.posterPhone,
    required this.posterPhoto,
    required this.fieldName,
    required this.fieldType,
    required this.maxPerson,
    required this.placeName,
    required this.postTitle,
    required this.currentJoinedCount,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        final utcTime = DateTime.parse(value.toString());
        return utcTime.toLocal();
      } catch (e) {
        return DateTime.now();
      }
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return JoinRequest(
      id: parseInt(json['id']),
      userId: parseInt(json['id_users']),
      bookingId: parseInt(json['id_booking']),
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      joinerName: json['joiner_name']?.toString() ?? 'Unknown User',
      joinerEmail: json['joiner_email']?.toString() ?? '',
      joinerPhone: json['joiner_phone']?.toString() ?? '',
      joinerPhoto: json['joiner_photo']?.toString(),
      joinerGender: json['joiner_gender']?.toString() ?? 'male',
      joinerBirthDate: parseDateTime(json['joiner_birth_date']),
      bookingDatetimeStart: parseDateTime(json['booking_datetime_start']),
      bookingDatetimeEnd: parseDateTime(json['booking_datetime_end']),
      posterUserId: parseInt(json['poster_user_id']),
      posterName: json['poster_name']?.toString() ?? 'Unknown',
      posterPhone: json['poster_phone']?.toString() ?? '',
      posterPhoto: json['poster_photo']?.toString() ?? '',
      fieldName: json['field_name']?.toString() ?? '',
      fieldType: json['field_type']?.toString() ?? '',
      maxPerson: parseInt(json['max_person']),
      placeName: json['place_name']?.toString() ?? '',
      postTitle: json['post_title']?.toString() ?? '',
      currentJoinedCount: parseInt(json['current_joined_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_users': userId,
      'id_booking': bookingId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'joiner_name': joinerName,
      'joiner_email': joinerEmail,
      'joiner_phone': joinerPhone,
      'joiner_photo': joinerPhoto,
      'joiner_gender': joinerGender,
      'joiner_birth_date': joinerBirthDate.toIso8601String(),
      'booking_datetime_start': bookingDatetimeStart.toIso8601String(),
      'booking_datetime_end': bookingDatetimeEnd.toIso8601String(),
      'poster_user_id': posterUserId,
      'poster_name': posterName,
      'poster_phone': posterPhone,
      'poster_photo': posterPhoto,
      'field_name': fieldName,
      'field_type': fieldType,
      'max_person': maxPerson,
      'place_name': placeName,
      'post_title': postTitle,
      'current_joined_count': currentJoinedCount,
    };
  }

  JoinRequest copyWith({
    int? id,
    int? userId,
    int? bookingId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? joinerName,
    String? joinerEmail,
    String? joinerPhone,
    String? joinerPhoto,
    String? joinerGender,
    DateTime? joinerBirthDate,
    DateTime? bookingDatetimeStart,
    DateTime? bookingDatetimeEnd,
    int? posterUserId,
    String? posterName,
    String? posterPhone,
    String? posterPhoto,
    String? fieldName,
    String? fieldType,
    int? maxPerson,
    String? placeName,
    String? postTitle,
    int? currentJoinedCount,
  }) {
    return JoinRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      joinerName: joinerName ?? this.joinerName,
      joinerEmail: joinerEmail ?? this.joinerEmail,
      joinerPhone: joinerPhone ?? this.joinerPhone,
      joinerPhoto: joinerPhoto ?? this.joinerPhoto,
      joinerGender: joinerGender ?? this.joinerGender,
      joinerBirthDate: joinerBirthDate ?? this.joinerBirthDate,
      bookingDatetimeStart: bookingDatetimeStart ?? this.bookingDatetimeStart,
      bookingDatetimeEnd: bookingDatetimeEnd ?? this.bookingDatetimeEnd,
      posterUserId: posterUserId ?? this.posterUserId,
      posterName: posterName ?? this.posterName,
      posterPhone: posterPhone ?? this.posterPhone,
      posterPhoto: posterPhoto ?? this.posterPhoto,
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      maxPerson: maxPerson ?? this.maxPerson,
      placeName: placeName ?? this.placeName,
      postTitle: postTitle ?? this.postTitle,
      currentJoinedCount: currentJoinedCount ?? this.currentJoinedCount,
    );
  }

  // Status helpers
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  // Formatted gender
  String get formattedGender {
    switch (joinerGender.toLowerCase()) {
      case 'male':
        return 'Laki-laki';
      case 'female':
        return 'Perempuan';
      default:
        return joinerGender;
    }
  }

  // Calculate age from birth date
  int get age {
    final now = DateTime.now();
    final difference = now.difference(joinerBirthDate);
    return (difference.inDays / 365).floor();
  }

  // Get full avatar URL
  String? get fullAvatarUrl {
    if (joinerPhoto == null || joinerPhoto!.isEmpty) return null;
    // Jika sudah full URL, return as is
    if (joinerPhoto!.startsWith('http')) return joinerPhoto;
    // Jika relative path, tambahkan base URL
    return 'https://your-api-domain.com/$joinerPhoto';
  }

  // Get full poster photo URL
  String get fullPosterPhotoUrl {
    if (posterPhoto.isEmpty) return '';
    if (posterPhoto.startsWith('http')) return posterPhoto;
    return 'https://your-api-domain.com/$posterPhoto';
  }

  @override
  String toString() {
    return 'JoinRequest(id: $id, joinerName: $joinerName, status: $status, '
        'bookingStart: $bookingDatetimeStart, fieldName: $fieldName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JoinRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
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
              ?.map(
                (item) => JoinRequest.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'JoinRequestsResponse(success: $success, message: $message, '
        'dataCount: ${data.length})';
  }
}
