import 'user_model.dart';

class LoginResponse {
  const LoginResponse({
    required this.success,
    required this.message,
    this.user,
  });

  final bool success;
  final String message;
  final UserModel? user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      user: json['data'] is Map<String, dynamic>
          ? UserModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
