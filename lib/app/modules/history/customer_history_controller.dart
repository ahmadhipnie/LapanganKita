import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/models/customer/history/customer_history_model.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';
import 'package:dio/dio.dart' as dio;
import '../../data/helper/error_helper.dart';
import '../../data/network/api_client.dart';

class CustomerHistoryController extends GetxController {
  final RxList<BookingHistory> bookings = <BookingHistory>[].obs;
  final RxString selectedFilter = 'all'.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final ApiClient _apiClient = ApiClient();
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final errorHandler = ErrorHandler();

  @override
  void onInit() {
    super.onInit();
    loadData();
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

      // ✅ Gunakan dio.FormData dengan prefix
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
        showSnackbar: false, // Biarkan view yang handle snackbar
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Success - akan ditutup di view dan show snackbar
        return; // Biarkan view yang handle success
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to create post');
      }
    } catch (e) {
      errorHandler.handleGeneralError(
        context: 'Failed to create community post',
        error: e,
        hasError: hasError,
        errorMessage: errorMessage,
        showSnackbar: false, // Biarkan view yang handle
      );
      rethrow; // Lempar error ke view
    } finally {
      isLoading.value = false;
    }
  }

  String _getHistorySpecificError(dynamic error) {
    final generalMessage = errorHandler.getSimpleErrorMessage(error);

    // Custom message untuk kasus khusus history
    if (error.toString().toLowerCase().contains('booking') ||
        error.toString().toLowerCase().contains('history')) {
      return 'Unable to load booking history. $generalMessage';
    }

    return generalMessage;
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

      final response = await errorHandler.handleFutureError(
        future: _apiClient.get(
          'bookings/me/bookings',
          queryParameters: {'user_id': userId},
        ),
        context: 'Failed to load booking history',
        hasError: hasError,
        errorMessage: errorMessage,
        showSnackbar: false, // Tidak tampilkan snackbar untuk initial load
      );

      if (response.statusCode == 200) {
        final bookingResponse = BookingHistoryResponse.fromJson(response.data);

        if (bookingResponse.success) {
          bookings.assignAll(bookingResponse.data);

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
        error: userFriendlyMessage, // Pass string langsung, bukan exception
        hasError: hasError,
        errorMessage: errorMessage,
        showSnackbar: true,
      );
    } finally {
      isLoading.value = false;
    }
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

      final response = await errorHandler.handleFutureError(
        future: _apiClient.get(
          'bookings/me/bookings',
          queryParameters: {'user_id': userId},
        ),
        context: 'Failed to refresh booking history',
        hasError: hasError,
        errorMessage: errorMessage,
        showSnackbar: false, // Tidak tampilkan snackbar untuk refresh
      );

      if (response.statusCode == 200) {
        final bookingResponse = BookingHistoryResponse.fromJson(response.data);

        if (bookingResponse.success) {
          bookings.assignAll(bookingResponse.data);
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
      // Error sudah dihandle oleh handleFutureError
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

  @override
  void onClose() {
    // Clear error state ketika controller diclose
    clearError();
    super.onClose();
  }
}
