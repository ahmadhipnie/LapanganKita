import 'package:lapangan_kita/app/data/models/customer/community/community_post_model.dart';

class JoinedUser {
  final String id;
  final int userId;
  final String bookingId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userName;
  final String userEmail;

  JoinedUser({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userEmail,
  });

  factory JoinedUser.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic value) => value?.toString() ?? '';

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      return DateTime.parse(value.toString());
    }

    return JoinedUser(
      id: parseId(json['id']),
      userId: int.tryParse(json['id_users']?.toString() ?? '0') ?? 0,
      bookingId: parseId(json['id_booking']),
      status: json['status']?.toString() ?? 'pending',
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      userName: json['user_name']?.toString() ?? 'Unknown User',
      userEmail: json['user_email']?.toString() ?? '',
    );
  }
}

class CommunityPostDetail {
  final String id;
  final String bookingId;
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
    String parseId(dynamic value) => value?.toString() ?? '';

    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      return DateTime.parse(value.toString());
    }

    return CommunityPostDetail(
      id: parseId(json['id']),
      bookingId: parseId(json['id_booking']),
      postPhoto: json['post_photo']?.toString() ?? '',
      postTitle: json['post_title']?.toString() ?? '',
      postDescription: json['post_description']?.toString() ?? '',
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      bookingDatetimeStart: parseDateTime(json['booking_datetime_start']),
      bookingDatetimeEnd: parseDateTime(json['booking_datetime_end']),
      bookingStatus: json['booking_status']?.toString() ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      posterUserId:
          int.tryParse(json['poster_user_id']?.toString() ?? '0') ?? 0,
      posterName: json['poster_name']?.toString() ?? 'Unknown User',
      posterEmail: json['poster_email']?.toString() ?? '',
      fieldName: json['field_name']?.toString() ?? '',
      fieldType: json['field_type']?.toString() ?? 'General',
      maxPerson: json['max_person'] ?? 0,
      pricePerHour: (json['price_per_hour'] ?? 0).toDouble(),
      placeName: json['place_name']?.toString() ?? '',
      placeAddress: json['place_address']?.toString() ?? '',
      fieldOwnerName: json['field_owner_name']?.toString() ?? '',
      joinedCount: json['joined_count'] ?? 0,
      pendingCount: json['pending_count'] ?? 0,
      joinedUsers:
          (json['joined_users'] as List<dynamic>?)
              ?.map((item) => JoinedUser.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Helper method untuk convert ke CommunityPost biasa
  CommunityPost toCommunityPost() {
    return CommunityPost(
      id: id,
      bookingId: bookingId,
      userProfileImage: postPhoto,
      userName: posterName,
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
    );
  }

  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
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
}
