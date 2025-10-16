import 'package:intl/intl.dart';

class CommunityPost {
  final int id; // ✅ Ubah dari String ke int
  final int bookingId; // ✅ Ubah dari String ke int
  final String userProfileImage;
  final String userName;
  final String userPhone;
  final DateTime postTime;
  final String category;
  final String title;
  final String subtitle;
  final String courtName;
  final DateTime gameDate;
  final String gameTime;
  final int playersNeeded;
  final double totalCost;
  final int joinedPlayers;
  final int posterUserId;
  final String bookingStatus;
  final String placeAddress;
  final String placeName;
  final String postPhoto;

  CommunityPost({
    required this.id,
    required this.bookingId,
    required this.userProfileImage,
    required this.userName,
    required this.userPhone,
    required this.postTime,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.courtName,
    required this.gameDate,
    required this.gameTime,
    required this.playersNeeded,
    required this.totalCost,
    required this.joinedPlayers,
    required this.posterUserId,
    required this.bookingStatus,
    required this.placeAddress,
    required this.placeName,
    required this.postPhoto,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    // ✅ Helper untuk parse int
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    DateTime parseDateTime(dynamic value) {
      if (value == null) {
        return DateTime.now();
      }

      try {
        final utcDateTime = DateTime.parse(value.toString()).toUtc();
        return utcDateTime.toLocal();
      } catch (e) {
        return DateTime.now();
      }
    }

    final bookingStart = parseDateTime(json['booking_datetime_start']);

    return CommunityPost(
      // ✅ Parse id sebagai int
      id: parseInt(json['id']),
      // ✅ Parse bookingId sebagai int
      bookingId: parseInt(
        json['booking_id'] ??
            json['id_booking'] ??
            json['booking']?['id'] ??
            json['booking_id_booking'],
      ),
      userProfileImage: json['poster_photo']?.toString() ?? '',
      userName:
          json['poster_name'] ??
          json['user_name'] ??
          json['username'] ??
          json['name'] ??
          'Unknown User',
      userPhone: json['poster_phone']?.toString() ?? '',
      postTime: parseDateTime(json['created_at']),
      category: json['field_type'] ?? 'General',
      title: json['post_title'] ?? '',
      subtitle: json['post_description'] ?? '',
      courtName: json['field_name'] ?? '',
      gameDate: bookingStart,
      gameTime: _formatTime(bookingStart),
      playersNeeded: parseInt(json['max_person']),
      totalCost:
          (json['total_price'] ??
                  json['total_cost'] ??
                  json['price'] ??
                  json['cost'] ??
                  0)
              .toDouble(),
      joinedPlayers: parseInt(json['joined_count']),
      posterUserId: parseInt(json['poster_user_id']),
      bookingStatus: json['booking_status']?.toString() ?? 'approved',
      placeAddress: json['place_address']?.toString() ?? '',
      placeName: json['place_name']?.toString() ?? '',
      postPhoto: json['post_photo']?.toString() ?? '',
    );
  }

  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(postTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedGameDate {
    return '${gameDate.day}/${gameDate.month}/${gameDate.year}';
  }

  String get formattedGameDateTime {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    return dateFormat.format(gameDate);
  }

  String get formattedPostTime {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    return dateFormat.format(postTime);
  }

  CommunityPost copyWith({
    int? id, // ✅ Ubah dari String ke int
    int? bookingId, // ✅ Ubah dari String ke int
    String? userProfileImage,
    String? userName,
    String? userPhone,
    DateTime? postTime,
    String? category,
    String? title,
    String? subtitle,
    String? courtName,
    DateTime? gameDate,
    String? gameTime,
    int? playersNeeded,
    double? totalCost,
    int? joinedPlayers,
    int? posterUserId,
    String? bookingStatus,
    String? placeAddress,
    String? placeName,
    String? postPhoto,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      postTime: postTime ?? this.postTime,
      category: category ?? this.category,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      courtName: courtName ?? this.courtName,
      gameDate: gameDate ?? this.gameDate,
      gameTime: gameTime ?? this.gameTime,
      playersNeeded: playersNeeded ?? this.playersNeeded,
      totalCost: totalCost ?? this.totalCost,
      joinedPlayers: joinedPlayers ?? this.joinedPlayers,
      posterUserId: posterUserId ?? this.posterUserId,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      placeAddress: placeAddress ?? this.placeAddress,
      placeName: placeName ?? this.placeName,
      postPhoto: postPhoto ?? this.postPhoto,
    );
  }

  // ✅ TAMBAH: Helper untuk toString (debugging)
  @override
  String toString() {
    return 'CommunityPost(id: $id, bookingId: $bookingId, userName: $userName, '
        'courtName: $courtName, joinedPlayers: $joinedPlayers/$playersNeeded)';
  }

  // ✅ TAMBAH: Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CommunityPostsResponse {
  final bool success;
  final String message;
  final List<CommunityPost> data;

  CommunityPostsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CommunityPostsResponse.fromJson(Map<String, dynamic> json) {
    return CommunityPostsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (item) => CommunityPost.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  // ✅ TAMBAH: toJson untuk debugging
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data
          .map(
            (post) => {
              'id': post.id,
              'bookingId': post.bookingId,
              'userName': post.userName,
              'courtName': post.courtName,
            },
          )
          .toList(),
    };
  }

  @override
  String toString() {
    return 'CommunityPostsResponse(success: $success, message: $message, '
        'dataCount: ${data.length})';
  }
}
