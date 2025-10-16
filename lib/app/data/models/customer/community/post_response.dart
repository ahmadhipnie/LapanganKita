import 'community_post_model.dart';

class PostResponse {
  final bool success;
  final String message;
  final CommunityPost? post; // ✅ UBAH dari Post ke CommunityPost

  PostResponse({
    required this.success,
    required this.message,
    this.post,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      post: json['data'] != null 
          ? CommunityPost.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (post != null) 'data': {
        'id': post!.id,
        'booking_id': post!.bookingId,
        'post_title': post!.title,
        'post_description': post!.subtitle,
        'post_photo': post!.postPhoto,
      },
    };
  }
}
