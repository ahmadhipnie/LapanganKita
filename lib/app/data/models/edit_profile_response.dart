import 'user_model.dart';

class UpdateProfileResponse {
  UpdateProfileResponse({
    required this.success,
    required this.message,
    this.user,
  });

  final bool success;
  final String message;
  final UserModel? user;

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      user: json['data'] != null
          ? UserModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (user != null) 'data': user!.toJson(),
    };
  }
}
