import 'package:lapangan_kita/app/data/models/customer/community/community_post_model.dart';

class JoinedUser {
  final int id; // ✅ Ubah dari String ke int
  final int userId;
  final int bookingId; // ✅ Ubah dari String ke int
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userPhoto;

  JoinedUser({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userPhoto,
  });

  factory JoinedUser.fromJson(Map<String, dynamic> json) {
    // ✅ Helper untuk parse int
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        final utcTime = DateTime.parse(value.toString());
        return utcTime.toLocal();
      } catch (e) {
        return DateTime.now();
      }
    }

    return JoinedUser(
      id: parseInt(json['id']), // ✅ Parse ke int
      userId: parseInt(json['id_users']),
      bookingId: parseInt(json['id_booking']), // ✅ Parse ke int
      status: json['status']?.toString() ?? 'pending',
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      userName: json['user_name']?.toString() ?? 'Unknown User',
      userEmail: json['user_email']?.toString() ?? '',
      userPhone: json['user_phone']?.toString() ?? '',
      userPhoto: json['user_photo']?.toString() ?? '',
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
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'user_photo': userPhoto,
    };
  }

  @override
  String toString() {
    return 'JoinedUser(id: $id, userName: $userName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JoinedUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CommunityPostDetail {
  final int id; // ✅ Ubah dari String ke int
  final int bookingId; // ✅ Ubah dari String ke int
  final String postPhoto;
  final String postTitle;
  final String postDescription;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime bookingDatetimeStart;
  final DateTime bookingDatetimeEnd;
  final String bookingStatus;
  final double totalPrice;
  final int posterUserId;
  final String posterName;
  final String posterEmail;
  final String posterPhone;
  final String posterPhoto;
  final String fieldName;
  final String fieldType;
  final int maxPerson;
  final double pricePerHour;
  final String placeName;
  final String placeAddress;
  final String fieldOwnerName;
  final int joinedCount;
  final int pendingCount;
  final List<JoinedUser> joinedUsers;

  CommunityPostDetail({
    required this.id,
    required this.bookingId,
    required this.postPhoto,
    required this.postTitle,
    required this.postDescription,
    required this.createdAt,
    required this.updatedAt,
    required this.bookingDatetimeStart,
    required this.bookingDatetimeEnd,
    required this.bookingStatus,
    required this.totalPrice,
    required this.posterUserId,
    required this.posterName,
    required this.posterEmail,
    required this.posterPhone,
    required this.posterPhoto,
    required this.fieldName,
    required this.fieldType,
    required this.maxPerson,
    required this.pricePerHour,
    required this.placeName,
    required this.placeAddress,
    required this.fieldOwnerName,
    required this.joinedCount,
    required this.pendingCount,
    required this.joinedUsers,
  });

  factory CommunityPostDetail.fromJson(Map<String, dynamic> json) {
    // ✅ Helper untuk parse int
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        final utcTime = DateTime.parse(value.toString());
        return utcTime.toLocal();
      } catch (e) {
        return DateTime.now();
      }
    }

    return CommunityPostDetail(
      id: parseInt(json['id']), // ✅ Parse ke int
      bookingId: parseInt(json['id_booking']), // ✅ Parse ke int
      postPhoto: json['post_photo']?.toString() ?? '',
      postTitle: json['post_title']?.toString() ?? '',
      postDescription: json['post_description']?.toString() ?? '',
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      bookingDatetimeStart: parseDateTime(json['booking_datetime_start']),
      bookingDatetimeEnd: parseDateTime(json['booking_datetime_end']),
      bookingStatus: json['booking_status']?.toString() ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      posterUserId: parseInt(json['poster_user_id']),
      posterName: json['poster_name']?.toString() ?? 'Unknown User',
      posterEmail: json['poster_email']?.toString() ?? '',
      posterPhone: json['poster_phone']?.toString() ?? '',
      posterPhoto: json['poster_photo']?.toString() ?? '',
      fieldName: json['field_name']?.toString() ?? '',
      fieldType: json['field_type']?.toString() ?? 'General',
      maxPerson: parseInt(json['max_person']),
      pricePerHour: (json['price_per_hour'] ?? 0).toDouble(),
      placeName: json['place_name']?.toString() ?? '',
      placeAddress: json['place_address']?.toString() ?? '',
      fieldOwnerName: json['field_owner_name']?.toString() ?? '',
      joinedCount: parseInt(json['joined_count']),
      pendingCount: parseInt(json['pending_count']),
      joinedUsers: (json['joined_users'] as List<dynamic>?)
              ?.map((item) => JoinedUser.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_booking': bookingId,
      'post_photo': postPhoto,
      'post_title': postTitle,
      'post_description': postDescription,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'booking_datetime_start': bookingDatetimeStart.toIso8601String(),
      'booking_datetime_end': bookingDatetimeEnd.toIso8601String(),
      'booking_status': bookingStatus,
      'total_price': totalPrice,
      'poster_user_id': posterUserId,
      'poster_name': posterName,
      'poster_email': posterEmail,
      'poster_phone': posterPhone,
      'poster_photo': posterPhoto,
      'field_name': fieldName,
      'field_type': fieldType,
      'max_person': maxPerson,
      'price_per_hour': pricePerHour,
      'place_name': placeName,
      'place_address': placeAddress,
      'field_owner_name': fieldOwnerName,
      'joined_count': joinedCount,
      'pending_count': pendingCount,
      'joined_users': joinedUsers.map((user) => user.toJson()).toList(),
    };
  }

  /// Helper method untuk convert ke CommunityPost biasa
  CommunityPost toCommunityPost() {
    return CommunityPost(
      id: id, // ✅ Sekarang sudah int ke int
      bookingId: bookingId, // ✅ Sekarang sudah int ke int
      userProfileImage: posterPhoto,
      userName: posterName,
      userPhone: posterPhone,
      postTime: createdAt,
      category: fieldType,
      title: postTitle,
      subtitle: postDescription,
      courtName: fieldName,
      gameDate: bookingDatetimeStart,
      gameTime: _formatTime(bookingDatetimeStart),
      playersNeeded: maxPerson,
      totalCost: totalPrice,
      joinedPlayers: joinedCount,
      posterUserId: posterUserId,
      bookingStatus: bookingStatus,
      placeAddress: placeAddress,
      placeName: placeName,
      postPhoto: postPhoto,
    );
  }

  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  CommunityPostDetail copyWith({
    int? id,
    int? bookingId,
    String? postPhoto,
    String? postTitle,
    String? postDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? bookingDatetimeStart,
    DateTime? bookingDatetimeEnd,
    String? bookingStatus,
    double? totalPrice,
    int? posterUserId,
    String? posterName,
    String? posterEmail,
    String? posterPhone,
    String? posterPhoto,
    String? fieldName,
    String? fieldType,
    int? maxPerson,
    double? pricePerHour,
    String? placeName,
    String? placeAddress,
    String? fieldOwnerName,
    int? joinedCount,
    int? pendingCount,
    List<JoinedUser>? joinedUsers,
  }) {
    return CommunityPostDetail(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      postPhoto: postPhoto ?? this.postPhoto,
      postTitle: postTitle ?? this.postTitle,
      postDescription: postDescription ?? this.postDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookingDatetimeStart: bookingDatetimeStart ?? this.bookingDatetimeStart,
      bookingDatetimeEnd: bookingDatetimeEnd ?? this.bookingDatetimeEnd,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      totalPrice: totalPrice ?? this.totalPrice,
      posterUserId: posterUserId ?? this.posterUserId,
      posterName: posterName ?? this.posterName,
      posterEmail: posterEmail ?? this.posterEmail,
      posterPhone: posterPhone ?? this.posterPhone,
      posterPhoto: posterPhoto ?? this.posterPhoto,
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      maxPerson: maxPerson ?? this.maxPerson,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      placeName: placeName ?? this.placeName,
      placeAddress: placeAddress ?? this.placeAddress,
      fieldOwnerName: fieldOwnerName ?? this.fieldOwnerName,
      joinedCount: joinedCount ?? this.joinedCount,
      pendingCount: pendingCount ?? this.pendingCount,
      joinedUsers: joinedUsers ?? this.joinedUsers,
    );
  }

  @override
  String toString() {
    return 'CommunityPostDetail(id: $id, bookingId: $bookingId, title: $postTitle, '
        'joinedCount: $joinedCount/$maxPerson, pendingCount: $pendingCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityPostDetail && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CommunityPostDetailResponse {
  final bool success;
  final String message;
  final CommunityPostDetail data;

  CommunityPostDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CommunityPostDetailResponse.fromJson(Map<String, dynamic> json) {
    return CommunityPostDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CommunityPostDetail.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }

  @override
  String toString() {
    return 'CommunityPostDetailResponse(success: $success, message: $message)';
  }
}
