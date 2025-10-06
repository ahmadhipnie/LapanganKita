// customer_history_controller.dart
import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/models/customer/history/customer_history_model.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

import '../../data/network/api_client.dart';

class CustomerHistoryController extends GetxController {
  final RxList<BookingHistory> bookings = <BookingHistory>[].obs;
  final RxString selectedFilter = 'all'.obs;
  final RxBool isLoading = false.obs;

  final ApiClient _apiClient = ApiClient();
  final LocalStorageService _localStorage = LocalStorageService.instance;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final userId = _localStorage.userId;
      if (userId == 0) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      final response = await _apiClient.get(
        'bookings/me/bookings',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final bookingResponse = BookingHistoryResponse.fromJson(response.data);

        if (bookingResponse.success) {
          bookings.assignAll(bookingResponse.data);
          if (bookingResponse.data.isEmpty) {
            Get.snackbar('Info', 'No booking history found');
          }
        } else {
          Get.snackbar('Error', bookingResponse.message);
        }
      } else {
        Get.snackbar('Error', 'Failed to load booking data');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      final userId = _localStorage.userId;
      if (userId == 0) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      final response = await _apiClient.get(
        'bookings/me/bookings',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final bookingResponse = BookingHistoryResponse.fromJson(response.data);

        if (bookingResponse.success) {
          bookings.assignAll(bookingResponse.data);
          Get.snackbar('Success', 'Data refreshed successfully');
        } else {
          Get.snackbar('Error', bookingResponse.message);
        }
      } else {
        Get.snackbar('Error', 'Failed to refresh booking data');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void refreshHistory() async {
    await loadData();
  }

  void addBooking(BookingHistory booking) {
    bookings.insert(0, booking);
    update();
  }

  void updateBookingStatus(int id, String status) {
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
    }
  }

  // Method untuk mendapatkan jumlah booking berdasarkan status
  int getBookingCountByStatus(String status) {
    if (status == 'all') return bookings.length;
    return bookings.where((booking) => booking.status == status).length;
  }
}
