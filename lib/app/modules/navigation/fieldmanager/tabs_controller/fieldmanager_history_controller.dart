import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/owner_booking_model.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/services/session_service.dart';

class FieldManagerHistoryController extends GetxController {
  FieldManagerHistoryController({
    BookingRepository? bookingRepository,
    SessionService? sessionService,
  }) : _bookingRepository = bookingRepository ?? Get.find<BookingRepository>(),
       _sessionService = sessionService ?? Get.find<SessionService>();

  final BookingRepository _bookingRepository;
  final SessionService _sessionService;

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
    final user = _sessionService.rememberedUser;
    if (user == null) {
      bookings.clear();
      errorMessage.value = 'Unable to identify the current user.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final results = await _bookingRepository.getBookingsByOwner(
        ownerId: user.id,
      );
      bookings.assignAll(results);
    } on BookingException catch (e) {
      bookings.clear();
      errorMessage.value = e.message;
    } catch (_) {
      bookings.clear();
      errorMessage.value =
          'Failed to load booking history. Please try again later.';
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
      case OwnerBookingStatus.pending:
        return Colors.orange;
      case OwnerBookingStatus.accepted:
        return Colors.green;
      case OwnerBookingStatus.rejected:
        return Colors.red;
      case OwnerBookingStatus.cancelled:
        return Colors.grey;
      case OwnerBookingStatus.completed:
        return Colors.blueGrey;
      case OwnerBookingStatus.unknown:
        return Colors.grey;
    }
  }

  String statusLabel(OwnerBooking booking) => booking.normalizedStatus.label;

  String formatDate(DateTime date) =>
      DateFormat('EEE, d MMM yyyy').format(date);

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
