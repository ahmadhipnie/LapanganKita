import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/models/customer/history/customer_history_model.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';
import 'package:dio/dio.dart' as dio;
import '../../data/helper/error_helper.dart';
import '../../data/models/customer/community/community_post_model.dart';
import '../../data/network/api_client.dart';
import '../../data/repositories/rating_repository.dart';

class CustomerHistoryController extends GetxController {
  final RxList<BookingHistory> bookings = <BookingHistory>[].obs;
  final RxList<CommunityPost> existingPosts = <CommunityPost>[].obs;
  final RxString selectedFilter = 'all'.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final ApiClient _apiClient = ApiClient();
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final errorHandler = ErrorHandler();
  late final RatingRepository _ratingRepository;

  @override
  void onInit() {
    super.onInit();
    _ratingRepository = RatingRepository(apiClient: _apiClient);
    loadData();
  }

  Future<void> _loadExistingPosts() async {
    try {
      final response = await _apiClient.get('posts');
      if (response.statusCode == 200) {
        final postsResponse = CommunityPostsResponse.fromJson(response.data);
        if (postsResponse.success) {
          existingPosts.assignAll(postsResponse.data);
        }
      }
    } catch (e) {
      print('Error loading existing posts: $e');
      // Tidak perlu handle error karena tidak critical
    }
  }

  bool _hasPostedForBooking(int bookingId) {
    return existingPosts.any(
      (post) =>
          post.bookingId == bookingId.toString() ||
          post.bookingId == bookingId.toString(),
    );
  }

  // ✅ Method untuk enrich booking data dengan status posting
  List<BookingHistory> _enrichWithPostStatus(List<BookingHistory> apiBookings) {
    return apiBookings.map((booking) {
      return booking.copyWith(hasPosted: _hasPostedForBooking(booking.id));
    }).toList();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorHandler.clearError(hasError: hasError, errorMessage: errorMessage);

    try {
      final userId = _localStorage.userId;
      if (userId == 0) {
        errorHandler.handleGeneralError(
          context: 'User authentication',
          error: 'User not logged in',
          hasError: hasError,
          errorMessage: errorMessage,
          showSnackbar: true,
        );
        return;
      }

      // ✅ Load existing posts terlebih dahulu
      await _loadExistingPosts();

      final response = await errorHandler.handleFutureError(
        future: _apiClient.get(
          'bookings/me/bookings',
          queryParameters: {'user_id': userId},
        ),
        context: 'Failed to load booking history',
        hasError: hasError,
        errorMessage: errorMessage,
        showSnackbar: false,
      );

      if (response.statusCode == 200) {
        final bookingResponse = BookingHistoryResponse.fromJson(response.data);

        if (bookingResponse.success) {
          // ✅ Enrich data dengan status posting dari existing posts
          final enrichedBookings = _enrichWithPostStatus(bookingResponse.data);
          bookings.assignAll(enrichedBookings);

          if (bookingResponse.data.isEmpty) {
            errorHandler.showInfoMessage('No booking history found');
          } else {
            errorHandler.showSuccessMessage(
              'Booking history loaded successfully',
            );
          }
        } else {
          errorHandler.handleGeneralError(
            context: 'API Error',
            error: bookingResponse.message,
            hasError: hasError,
            errorMessage: errorMessage,
            showSnackbar: true,
          );
        }
      } else {
        errorHandler.handleGeneralError(
          context: 'Server Error',
          error: 'Failed to load booking data',
          hasError: hasError,
          errorMessage: errorMessage,
          showSnackbar: true,
        );
      }
    } catch (e) {
      final userFriendlyMessage = _getHistorySpecificError(e);
      errorHandler.handleGeneralError(
        context: 'Failed to load booking history',
        error: userFriendlyMessage,
        hasError: hasError,
        errorMessage: errorMessage,
        showSnackbar: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCommunityPost({
    required int bookingId,
    required String title,
    required String description,
    required String? imagePath,
  }) async {
    try {
      isLoading.value = true;
      errorHandler.clearError(hasError: hasError, errorMessage: errorMessage);

      final formData = dio.FormData.fromMap({
        'id_booking': bookingId,
        'post_title': title,
        'post_description': description,
        if (imagePath != null && imagePath.isNotEmpty)
          'post_photo': await dio.MultipartFile.fromFile(
            imagePath,
            filename: 'post_${DateTime.now().millisecondsSinceEpoch}.png',
          ),
      });

      final response = await errorHandler.handleFutureError(
        future: _apiClient.raw.post(
          'posts',
          data: formData,
          options: dio.Options(
            contentType: 'multipart/form-data',
            headers: {'Content-Type': 'multipart/form-data'},
          ),
        ),
        context: 'Failed to create community post',
        hasError: hasError,
        errorMessage: errorMessage,
        showSnackbar: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ SUCCESS: Refresh existing posts untuk update cache
        await _loadExistingPosts();

        // ✅ Update status posting di local data
        _updateBookingPostStatus(bookingId, true);
        return;
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to create post');
      }
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to create community post',
        error: e,
        hasError: hasError,
        errorMessage: errorMessage,
        showSnackbar: false,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void _updateBookingPostStatus(int bookingId, bool hasPosted) {
    try {
      final index = bookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) {
        final updatedBooking = bookings[index].copyWith(hasPosted: hasPosted);
        bookings[index] = updatedBooking;
        update(); // Trigger UI update
      }
    } catch (e) {
      print('Error updating post status: $e');
    }
  }

  // ✅ Method untuk manual check post status (optional)
  Future<bool> checkPostStatus(int bookingId) async {
    try {
      await _loadExistingPosts(); // Refresh cache
      return _hasPostedForBooking(bookingId);
    } catch (e) {
      return false;
    }
  }

  String _getHistorySpecificError(dynamic error) {
    final generalMessage = errorHandler.getSimpleErrorMessage(error);

    // Custom message untuk kasus khusus history
    if (error.toString().toLowerCase().contains('booking') ||
        error.toString().toLowerCase().contains('history')) {
      return 'Unable to load booking history. $generalMessage';
    }

    // Custom message untuk network issues
    if (error.toString().toLowerCase().contains('socket') ||
        error.toString().toLowerCase().contains('connection') ||
        error.toString().toLowerCase().contains('network')) {
      return 'Network connection issue. Please check your internet and try again.';
    }

    // Custom message untuk timeout
    if (error.toString().toLowerCase().contains('timeout')) {
      return 'Request timeout. Please try again.';
    }

    // Custom message untuk authentication
    if (error.toString().toLowerCase().contains('unauthorized') ||
        error.toString().toLowerCase().contains('authentication')) {
      return 'Authentication failed. Please login again.';
    }

    return generalMessage;
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    errorHandler.clearError(hasError: hasError, errorMessage: errorMessage);

    try {
      final userId = _localStorage.userId;
      if (userId == 0) {
        errorHandler.handleGeneralError(
          context: 'User authentication',
          error: 'User not logged in',
          hasError: hasError,
          errorMessage: errorMessage,
          showSnackbar: true,
        );
        return;
      }

      // ✅ Refresh existing posts juga
      await _loadExistingPosts();

      final response = await errorHandler.handleFutureError(
        future: _apiClient.get(
          'bookings/me/bookings',
          queryParameters: {'user_id': userId},
        ),
        context: 'Failed to refresh booking history',
        hasError: hasError,
        errorMessage: errorMessage,
        showSnackbar: false,
      );

      if (response.statusCode == 200) {
        final bookingResponse = BookingHistoryResponse.fromJson(response.data);

        if (bookingResponse.success) {
          // ✅ Enrich data dengan status posting dari existing posts
          final enrichedBookings = _enrichWithPostStatus(bookingResponse.data);
          bookings.assignAll(enrichedBookings);

          errorHandler.showSuccessMessage(
            'Booking history refreshed successfully',
          );
        } else {
          errorHandler.handleGeneralError(
            context: 'API Error',
            error: bookingResponse.message,
            hasError: hasError,
            errorMessage: errorMessage,
            showSnackbar: true,
          );
        }
      } else {
        errorHandler.handleGeneralError(
          context: 'Server Error',
          error: 'Failed to refresh booking data',
          hasError: hasError,
          errorMessage: errorMessage,
          showSnackbar: true,
        );
      }
    } catch (e) {
      print('Error refreshing booking history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    try {
      selectedFilter.value = filter;
      // errorHandler.showInfoMessage('Filter applied: ${filter.toUpperCase()}');
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to apply filter',
        error: e,
        showSnackbar: false,
      );
    }
  }

  void refreshHistory() async {
    try {
      await loadData();
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to refresh history',
        error: e,
        showSnackbar: true,
      );
    }
  }

  void addBooking(BookingHistory booking) {
    try {
      bookings.insert(0, booking);
      update();
      errorHandler.showSuccessMessage('Booking added successfully');
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to add booking',
        error: e,
        showSnackbar: true,
      );
    }
  }

  void updateBookingStatus(int id, String status) {
    try {
      final index = bookings.indexWhere((booking) => booking.id == id);
      if (index != -1) {
        final updatedBooking = BookingHistory(
          id: bookings[index].id,
          courtName: bookings[index].courtName,
          location: bookings[index].location,
          orderId: bookings[index].orderId,
          date: bookings[index].date,
          startTime: bookings[index].startTime,
          duration: bookings[index].duration,
          note: bookings[index].note,
          totalAmount: bookings[index].totalAmount,
          status: status,
          details: bookings[index].details,
          courtPrice: bookings[index].courtPrice,
          equipmentTotal: bookings[index].equipmentTotal,
          types: bookings[index].types,
        );
        bookings[index] = updatedBooking;
        update();

        errorHandler.showSuccessMessage(
          'Booking status updated to ${status.toUpperCase()}',
        );
      } else {
        errorHandler.showWarningMessage('Booking not found');
      }
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to update booking status',
        error: e,
        showSnackbar: true,
      );
    }
  }

  // Method untuk mendapatkan jumlah booking berdasarkan status
  int getBookingCountByStatus(String status) {
    try {
      if (status == 'all') return bookings.length;
      return bookings.where((booking) => booking.status == status).length;
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to count bookings',
        error: e,
        showSnackbar: false,
      );
      return 0;
    }
  }

  // Method untuk mendapatkan filtered bookings berdasarkan status
  List<BookingHistory> getFilteredBookings() {
    try {
      if (selectedFilter.value == 'all') {
        return bookings.toList();
      }
      return bookings
          .where((booking) => booking.status == selectedFilter.value)
          .toList();
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to filter bookings',
        error: e,
        showSnackbar: false,
      );
      return bookings.toList();
    }
  }

  // Method untuk check jika ada data
  bool get hasData => bookings.isNotEmpty;

  // Method untuk check jika sedang loading
  bool get isDataLoading => isLoading.value;

  // Method untuk check jika ada error
  bool get hasDataError => hasError.value;

  // Method untuk retry loading data
  Future<void> retryLoadData() async {
    await loadData();
  }

  // Method untuk clear error state
  void clearError() {
    errorHandler.clearError(hasError: hasError, errorMessage: errorMessage);
  }

  // Method untuk force reload data
  Future<void> forceReload() async {
    try {
      isLoading.value = true;
      errorHandler.clearError(hasError: hasError, errorMessage: errorMessage);

      // Clear existing data
      bookings.clear();

      // Load fresh data
      await loadData();
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to force reload data',
        error: e,
        showSnackbar: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk mendapatkan booking by ID
  BookingHistory? getBookingById(int id) {
    try {
      return bookings.firstWhere((booking) => booking.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method untuk check jika booking exists
  bool hasBooking(int id) {
    return bookings.any((booking) => booking.id == id);
  }

  // Method untuk remove booking
  void removeBooking(int id) {
    try {
      bookings.removeWhere((booking) => booking.id == id);
      update();
      errorHandler.showSuccessMessage('Booking removed successfully');
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to remove booking',
        error: e,
        showSnackbar: true,
      );
    }
  }

  // Rating Methods
  Future<void> submitRating({
    required String bookingId,
    required int ratingValue,
    required String review,
  }) async {
    try {
      isLoading.value = true;

      print(
        '🚀 Starting rating submission for booking: $bookingId, rating: $ratingValue, review: "$review"',
      );

      final response = await _ratingRepository.submitRating(
        idBooking: bookingId,
        ratingValue: ratingValue,
        review: review,
      );

      print(
        '📦 Rating response received: success=${response.success}, message="${response.message}"',
      );

      if (response.success) {
        // Show success message
        Get.snackbar(
          'Success',
          response.message.isNotEmpty
              ? response.message
              : 'Rating submitted successfully!',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // Refresh data to show any updates
        await refreshData();
      } else {
        // Show error message from API
        Get.snackbar(
          'Failed',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to submit rating',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      print('💥 Rating submission exception: $e');

      // Show detailed error message
      Get.snackbar(
        'Error',
        'Failed to submit rating. Please check your connection and try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Clear error state ketika controller diclose
    clearError();
    super.onClose();
  }
}
