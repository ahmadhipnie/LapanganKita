import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/history/customer_history_model.dart';

class CustomerHistoryController extends GetxController {
  final RxList<BookingHistory> bookings = <BookingHistory>[].obs;
  final RxString selectedFilter = 'all'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _addDummyData();
  }

  // Method untuk load data
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulasi loading
      _addDummyData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk refresh data
  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulasi refresh
      bookings.clear();
      _addDummyData();
      Get.snackbar(
        'Success',
        'Data refreshed successfully',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void _addDummyData() {
    // Dummy data 1
    final dummy1 = BookingHistory(
      id: 'BK1234567890',
      courtName: 'Indoor Tennis Court',
      courtImageUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      location: 'Kemang, South Jakarta',
      date: DateTime.now().subtract(const Duration(days: 2)),
      startTime: '14:00',
      duration: 2,
      totalAmount: 480000,
      status: 'approved',
      equipment: {'Tennis Racket': 2, 'Towel rental': 1},
      courtPrice: 240000,
      equipmentTotal: 125000,
    );

    // Dummy data 2
    final dummy2 = BookingHistory(
      id: 'BK0987654321',
      courtName: 'Premium Futsal Court',
      courtImageUrl:
          'https://images.unsplash.com/photo-1520877880798-5ee004e3f11e',
      location: 'Senayan, Central Jakarta',
      date: DateTime.now().subtract(const Duration(days: 1)),
      startTime: '19:00',
      duration: 1,
      totalAmount: 100000,
      status: 'pending',
      equipment: {},
      courtPrice: 100000,
      equipmentTotal: 0,
    );

    bookings.addAll([dummy1, dummy2]);
  }

  void refreshHistory() async {
    isLoading.value = true;
    // Jika data dari API, panggil API di sini. Jika lokal, bisa clear dan add ulang.
    await Future.delayed(const Duration(seconds: 1)); // simulasi loading
    // Misal: await fetchBookingHistory();
    isLoading.value = false;
  }

  void addBooking(BookingHistory booking) {
    bookings.insert(0, booking); // Tambahkan di awal list
    update();
  }

  void updateBookingStatus(String id, String status) {
    final index = bookings.indexWhere((booking) => booking.id == id);
    if (index != -1) {
      final updatedBooking = BookingHistory(
        id: bookings[index].id,
        courtName: bookings[index].courtName,
        courtImageUrl: bookings[index].courtImageUrl,
        location: bookings[index].location,
        date: bookings[index].date,
        startTime: bookings[index].startTime,
        duration: bookings[index].duration,
        totalAmount: bookings[index].totalAmount,
        status: status,
        equipment: bookings[index].equipment,
        courtPrice: bookings[index].courtPrice,
        equipmentTotal: bookings[index].equipmentTotal,
      );
      bookings[index] = updatedBooking;
    }
  }
}
