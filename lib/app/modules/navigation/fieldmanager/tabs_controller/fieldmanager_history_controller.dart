import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/owner_booking_model.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../services/local_storage_service.dart';

class FieldManagerHistoryController extends GetxController {
  FieldManagerHistoryController({BookingRepository? bookingRepository})
    : _bookingRepository = bookingRepository ?? Get.find<BookingRepository>();

  final BookingRepository _bookingRepository;
  final LocalStorageService _localStorage = LocalStorageService.instance;

  final RxList<OwnerBooking> bookings = <OwnerBooking>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString filterStatus = 'All'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    if (!_localStorage.isLoggedIn) {
      bookings.clear();
      errorMessage.value = 'Sesi Anda telah berakhir. Silakan login kembali.';
      return;
    }

    final userId = _localStorage.userId;
    if (userId == 0) {
      bookings.clear();
      errorMessage.value = 'Terjadi kesalahan pada akun Anda.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final results = await _bookingRepository.getBookingsByOwner(
        ownerId: userId,
      );
      bookings.assignAll(results);
    } on BookingException catch (_) {
      // Pesan dari repository tidak ditampilkan langsung ke UI.
      bookings.clear();
      errorMessage.value =
          'Tidak dapat memuat riwayat booking. Coba lagi nanti.';
    } catch (e) {
      // Log internal untuk debugging (tidak muncul di UI).
      debugPrint('Error saat memuat riwayat booking: $e');
      bookings.clear();
      errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi nanti.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBookings() => fetchBookings();

  List<OwnerBooking> get filteredBookings {
    final query = searchQuery.value.trim().toLowerCase();
    final statusFilter = filterStatus.value;

    final list = bookings.where((booking) {
      if (statusFilter != 'All' &&
          booking.normalizedStatus.label.toLowerCase() !=
              statusFilter.toLowerCase()) {
        return false;
      }

      if (query.isNotEmpty && !_matchesSearchQuery(booking, query)) {
        return false;
      }

      return true;
    }).toList();

    list.sort((a, b) => b.bookingStart.compareTo(a.bookingStart));
    return list;
  }

  bool _matchesSearchQuery(OwnerBooking booking, String query) {
    bool contains(String value) => value.toLowerCase().contains(query);

    if (contains(booking.userName)) return true;
    if (contains(booking.fieldName)) return true;
    if (contains(booking.placeName)) return true;
    if (contains(booking.orderId)) return true;

    final formattedDate = DateFormat('yyyy-MM-dd').format(booking.bookingStart);
    return formattedDate.contains(query);
  }

  Color statusColor(OwnerBookingStatus status) {
    switch (status) {
      case OwnerBookingStatus.waitingConfirmation:
        return Colors.orange;
      case OwnerBookingStatus.approved:
        return Colors.green;
      case OwnerBookingStatus.cancelled:
      case OwnerBookingStatus.rejected:
        return Colors.red;
      case OwnerBookingStatus.completed:
        return Colors.blueGrey;
      case OwnerBookingStatus.unknown:
        return Colors.grey;
    }
  }

  String statusLabel(OwnerBooking booking) => booking.normalizedStatus.label;

  String formatDate(DateTime date) =>
      DateFormat('EEE, d MMM yyyy', 'id_ID').format(date);

  String formatTimeRange(DateTime start, DateTime end) {
    final timeFormat = DateFormat('HH:mm');
    return '${timeFormat.format(start)} - ${timeFormat.format(end)}';
  }

  String formatPrice(num value) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return currency.format(value);
  }
}
