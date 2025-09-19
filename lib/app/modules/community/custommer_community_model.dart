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