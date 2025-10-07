import 'user_model.dart';

class UpdateProfileResponse {
  final bool success;
  final String message;
  final UserModel? user;

  UpdateProfileResponse({
    required this.success,
    required this.message,
    this.user,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      user: json['data'] is Map<String, dynamic>
          ? UserModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
