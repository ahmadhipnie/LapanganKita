import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType { success, error, warning, info }

class ErrorHandler {
  // Singleton instance
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  // Method untuk mendapatkan pesan error yang SIMPLE dalam English
  String getSimpleErrorMessage(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 0;

      // Handle ngrok offline error
      if (_isNgrokOfflineError(error)) {
        return 'Server is temporarily offline. Please try again in a few minutes.';
      }

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
    final errorString = error.toString().toLowerCase();

    // Handle ngrok offline error (string-based)
    if (_isNgrokOfflineError(errorString)) {
      return 'Server is temporarily offline. Please try again in a few minutes.';
    } else if (errorString.contains('connection') ||
        errorString.contains('socket')) {
      return 'Connection problem. Please check your internet.';
    } else if (errorString.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (errorString.contains('not found') ||
        errorString.contains('404')) {
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

    // Gunakan Get.snackbar asli
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
    showCustomSnackbar('Success', message, SnackbarType.success);
  }

  // Method untuk warning messages
  void showWarningMessage(String message) {
    showCustomSnackbar('Warning', message, SnackbarType.warning);
  }

  // Method untuk info messages
  void showInfoMessage(String message) {
    showCustomSnackbar('Info', message, SnackbarType.info);
  }

  // Method untuk error messages
  void showErrorMessage(String message) {
    showCustomSnackbar('Error', message, SnackbarType.error);
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

    print('Error: $context - $error');

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
}
