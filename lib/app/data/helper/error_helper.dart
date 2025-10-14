import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType { success, error, warning, info }

class ErrorHandler {
  // Singleton instance
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  // Indonesian to English message translations
  static const Map<String, String> _messageTranslations = {
    // Password related
    'Password lama tidak sesuai': 'Old password is incorrect',
    'Password berhasil diubah': 'Password successfully changed',
    'Password baru tidak boleh sama dengan password lama': 
        'New password must be different from old password',
    'Password minimal 8 karakter': 'Password must be at least 8 characters',
    'Password harus diisi': 'Password is required',
    
    // User/Auth related
    'Email sudah terdaftar': 'Email already registered',
    'Email tidak ditemukan': 'Email not found',
    'Email atau password salah': 'Email or password is incorrect',
    'User tidak ditemukan': 'User not found',
    'User berhasil diupdate': 'User successfully updated',
    'Gagal mengupdate user': 'Failed to update user',
    'Data user tidak ditemukan': 'User data not found',
    
    // Profile/Update related
    'Berhasil memperbarui profil': 'Profile updated successfully',
    'Gagal memperbarui profil': 'Failed to update profile',
    'Foto profil berhasil diupdate': 'Profile photo updated successfully',
    'Gagal mengupload foto': 'Failed to upload photo',
    
    // Generic success/error
    'Berhasil': 'Success',
    'Gagal': 'Failed',
    'Sukses': 'Success',
    'Data tidak ditemukan': 'Data not found',
    'Terjadi kesalahan': 'An error occurred',
    'Koneksi gagal': 'Connection failed',
    'Silakan coba lagi': 'Please try again',
    
    // Validation
    'Kolom wajib diisi': 'This field is required',
    'Format tidak valid': 'Invalid format',
    'Data tidak valid': 'Invalid data',
  };

  // Translate Indonesian message to English
  String translateMessage(String message) {
    if (message.isEmpty) return message;

    // Try exact match first (case-sensitive)
    if (_messageTranslations.containsKey(message)) {
      return _messageTranslations[message]!;
    }

    // Try exact match (case-insensitive)
    final exactMatch = _messageTranslations.entries.firstWhere(
      (entry) => entry.key.toLowerCase() == message.toLowerCase(),
      orElse: () => MapEntry('', ''),
    );
    if (exactMatch.value.isNotEmpty) {
      return exactMatch.value;
    }

    // Try partial match for longer messages
    final lowerMessage = message.toLowerCase();
    for (var entry in _messageTranslations.entries) {
      if (lowerMessage.contains(entry.key.toLowerCase())) {
        // Replace the Indonesian part with English
        return message.replaceAll(
          RegExp(entry.key, caseSensitive: false),
          entry.value,
        );
      }
    }

    // If no translation found, return original
    return message;
  }

  // Extract and translate message from API response
  String? extractAndTranslateMessage(dynamic data) {
    final message = _extractMessageFromData(data);
    if (message == null || message.isEmpty) return null;
    return translateMessage(message);
  }

  // Helper to extract message from various data formats
  String? _extractMessageFromData(dynamic data) {
    if (data == null) return null;
    
    if (data is Map) {
      // Try 'message' field
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }

      // Try 'errors' field
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.map((e) => e.toString()).join(', ');
      }

      if (errors is Map && errors.isNotEmpty) {
        return errors.values
            .expand((value) => value is Iterable ? value : [value])
            .map((e) => e.toString())
            .join(', ');
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }

  // Method untuk mendapatkan pesan error yang SIMPLE dalam English
  String getSimpleErrorMessage(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 0;

      // Handle ngrok offline error
      if (_isNgrokOfflineError(error)) {
        return 'Server is temporarily offline. Please try again in a few minutes.';
      }

      // Try to extract message from response and translate
      final extractedMessage = extractAndTranslateMessage(error.response?.data);
      if (extractedMessage != null && extractedMessage.isNotEmpty) {
        return extractedMessage;
      }

      // Status code fallbacks
      if (statusCode == 404) return 'Data not found.';
      if (statusCode == 401) return 'Session expired. Please login again.';
      if (statusCode >= 500) return 'Server is busy. Please try again later.';
      
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Connection timeout. Please check your internet.';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Unable to connect to server. Please check your network.';
      }

      // Default fallback for Dio
      return 'Unable to load data. Please try again.';
    }

    // String-based fallback (non-Dio errors)
    final errorString = error.toString();
    
    // Try to translate if it's a direct message
    final translated = translateMessage(errorString);
    if (translated != errorString) {
      return translated;
    }

    final errorLower = errorString.toLowerCase();
    
    // Handle ngrok offline error (string-based)
    if (_isNgrokOfflineError(errorString)) {
      return 'Server is temporarily offline. Please try again in a few minutes.';
    } else if (errorLower.contains('connection') ||
        errorLower.contains('socket')) {
      return 'Connection problem. Please check your internet.';
    } else if (errorLower.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (errorLower.contains('not found') ||
        errorLower.contains('404')) {
      return 'Data not found.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  // Method untuk deteksi ngrok offline
  bool _isNgrokOfflineError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('ngrok') ||
        errorString.contains('err_ngrok') ||
        errorString.contains('offline') ||
        errorString.contains('tunnel') ||
        errorString.contains('tunneling') ||
        (error is DioException &&
            error.response?.data?.toString().toLowerCase().contains('ngrok') ==
                true) ||
        (error is String && error.toLowerCase().contains('ngrok'));
  }

  // Method untuk snackbar menggunakan Get.snackbar
  void showCustomSnackbar(String title, String message, SnackbarType type) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      _showSnackbarContent(title, message, type);
    });
  }

  void _showSnackbarContent(String title, String message, SnackbarType type) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        icon = Icons.check_circle;
        break;
      case SnackbarType.warning:
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        icon = Icons.warning_amber_rounded;
        break;
      case SnackbarType.info:
        backgroundColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        icon = Icons.info_outline;
        break;
      case SnackbarType.error:
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        icon = Icons.error_outline;
        break;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: Icon(icon, color: textColor),
      shouldIconPulse: true,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      snackStyle: SnackStyle.FLOATING,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  // Method untuk success messages
  void showSuccessMessage(String message) {
    showCustomSnackbar('Success', translateMessage(message), SnackbarType.success);
  }

  // Method untuk warning messages
  void showWarningMessage(String message) {
    showCustomSnackbar('Warning', translateMessage(message), SnackbarType.warning);
  }

  // Method untuk info messages
  void showInfoMessage(String message) {
    showCustomSnackbar('Info', translateMessage(message), SnackbarType.info);
  }

  // Method untuk error messages
  void showErrorMessage(String message) {
    showCustomSnackbar('Error', translateMessage(message), SnackbarType.error);
  }

  // Main method untuk handle error
  void handleGeneralError({
    required String context,
    required dynamic error,
    RxBool? hasError,
    RxString? errorMessage,
    bool showSnackbar = true,
  }) {
    final userFriendlyMessage = getSimpleErrorMessage(error);

    // Update error state jika provided
    if (hasError != null) {
      hasError.value = true;
    }

    if (errorMessage != null) {
      errorMessage.value = userFriendlyMessage;
    }

    // Tampilkan snackbar jika diperlukan
    if (showSnackbar && !_isMinorError(userFriendlyMessage)) {
      showErrorMessage(userFriendlyMessage);
    }
  }

  bool _isMinorError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('connection') ||
        lower.contains('timeout') ||
        lower.contains('offline') ||
        lower.contains('busy');
  }

  // Method untuk clear error state
  void clearError({RxBool? hasError, RxString? errorMessage}) {
    if (hasError != null) {
      hasError.value = false;
    }

    if (errorMessage != null) {
      errorMessage.value = '';
    }
  }

  // Helper method untuk error handling di Future operations
  Future<T> handleFutureError<T>({
    required Future<T> future,
    required String context,
    RxBool? hasError,
    RxString? errorMessage,
    bool showSnackbar = true,
    T? fallbackValue,
  }) async {
    try {
      return await future;
    } catch (e) {
      handleGeneralError(
        context: context,
        error: e,
        hasError: hasError,
        errorMessage: errorMessage,
        showSnackbar: showSnackbar,
      );
      if (fallbackValue != null) {
        return fallbackValue;
      }
      rethrow;
    }
  }
}

// Extension untuk memudahkan penggunaan di controllers
extension ErrorHandlerExtension on GetxController {
  void handleError({
    required String context,
    required dynamic error,
    RxBool? hasError,
    RxString? errorMessage,
    bool showSnackbar = true,
  }) {
    ErrorHandler().handleGeneralError(
      context: context,
      error: error,
      hasError: hasError,
      errorMessage: errorMessage,
      showSnackbar: showSnackbar,
    );
  }

  void showSuccess(String message) {
    ErrorHandler().showSuccessMessage(message);
  }

  void showWarning(String message) {
    ErrorHandler().showWarningMessage(message);
  }

  void showInfo(String message) {
    ErrorHandler().showInfoMessage(message);
  }

  void showError(String message) {
    ErrorHandler().showErrorMessage(message);
  }

  String getFriendlyError(dynamic error) {
    return ErrorHandler().getSimpleErrorMessage(error);
  }

  String translateMsg(String message) {
    return ErrorHandler().translateMessage(message);
  }
}
