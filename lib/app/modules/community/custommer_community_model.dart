// models/community_post.dart
class CommunityPost {
  final String id;
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

  // Factory method untuk convert dari JSON API
  factory CommunityPost.fromApiJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'].toString(),
      userProfileImage: json['post_photo'] ?? '',
      userName: json['poster_name'] ?? 'Unknown User',
      postTime: DateTime.parse(json['created_at']),
      category: json['field_type'] ?? 'General',
      title: json['post_title'] ?? '',
      subtitle: json['post_description'] ?? '',
      courtName: json['field_name'] ?? '',
      gameDate: DateTime.parse(json['booking_datetime_start']),
      gameTime: _formatTime(DateTime.parse(json['booking_datetime_start'])),
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
}

// Model untuk API Response
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
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => CommunityPost.fromApiJson(item))
          .toList() ??
          [],
    );
  }
}