class CommunityPost {
  final String id;
  final String bookingId;
  final String userProfileImage;
  final String userName;
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

  CommunityPost({
    required this.id,
    required this.bookingId,
    required this.userProfileImage,
    required this.userName,
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
  });

  factory CommunityPost.fromApiJson(Map<String, dynamic> json) {
    String parseId(dynamic value) => value?.toString() ?? '';

    DateTime parseDateTime(dynamic value) {
      if (value == null) {
        return DateTime.now();
      }

      return DateTime.parse(value.toString());
    }

    final bookingStart = parseDateTime(json['booking_datetime_start']);

    return CommunityPost(
      id: parseId(json['id']),
      bookingId: parseId(
        json['booking_id'] ??
            json['id_booking'] ??
            json['booking']?['id'] ??
            json['booking_id_booking'] ??
            json['id'],
      ),
      userProfileImage: json['post_photo'] ?? '',
      userName: json['poster_name'] ?? 'Unknown User',
      postTime: parseDateTime(json['created_at']),
      category: json['field_type'] ?? 'General',
      title: json['post_title'] ?? '',
      subtitle: json['post_description'] ?? '',
      courtName: json['field_name'] ?? '',
      gameDate: bookingStart,
      gameTime: _formatTime(bookingStart),
      playersNeeded: json['max_person'] ?? 0,
      totalCost: (json['total_price'] ?? 0).toDouble(),
      joinedPlayers: json['joined_count'] ?? 0,
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

  CommunityPost copyWith({
    String? id,
    String? bookingId,
    String? userProfileImage,
    String? userName,
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
  }) {
    return CommunityPost(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      userName: userName ?? this.userName,
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
    );
  }
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
              ?.map((item) => CommunityPost.fromApiJson(item))
              .toList() ??
          [],
    );
  }
}

class JoinRequest {
  final String id;
  final int userId;
  final String userName;
  final String status;
  final String? note;
  final String? avatarUrl;
  final DateTime requestedAt;

  const JoinRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.status,
    required this.requestedAt,
    this.note,
    this.avatarUrl,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic value) => value?.toString() ?? '';

    DateTime parseDateTime(dynamic value) {
      if (value == null) {
        return DateTime.now();
      }
      return DateTime.parse(value.toString());
    }

    return JoinRequest(
      id: parseId(json['id'] ?? json['id_joined']),
      userId:
          int.tryParse(
            json['user_id']?.toString() ?? json['id_users']?.toString() ?? '0',
          ) ??
          0,
      userName:
          json['user_name']?.toString() ??
          json['name']?.toString() ??
          'Unknown User',
      status: (json['status'] ?? json['joined_status'] ?? 'pending')
          .toString()
          .toLowerCase(),
      note: json['note']?.toString() ?? json['message']?.toString(),
      avatarUrl:
          json['avatar_url']?.toString() ?? json['user_avatar']?.toString(),
      requestedAt: parseDateTime(json['created_at'] ?? json['requested_at']),
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
  }) {
    return JoinRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      note: note ?? this.note,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
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
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (item) => JoinRequest.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
