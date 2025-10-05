// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../../../data/models/owner_booking_model.dart';
// import '../../../../data/repositories/booking_repository.dart';
// import '../../../../services/local_storage_service.dart';

// class FieldManagerBookingController extends GetxController {
//   FieldManagerBookingController({BookingRepository? bookingRepository})
//     : _bookingRepository = bookingRepository ?? Get.find<BookingRepository>();

//   final BookingRepository _bookingRepository;
//   final LocalStorageService _localStorage = LocalStorageService.instance;

//   final RxList<OwnerBooking> bookings = <OwnerBooking>[].obs;
//   final RxBool isLoading = false.obs;
//   final RxString errorMessage = ''.obs;
//   final RxString filterStatus = 'All'.obs;
//   final RxString searchQuery = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchBookings();
//   }

//   Future<void> fetchBookings() async {
//     // ✅ PERBAIKAN: Gunakan LocalStorageService untuk mendapatkan user data
//     if (!_localStorage.isLoggedIn) {
//       bookings.clear();
//       errorMessage.value = 'Sesi berakhir. Silakan masuk kembali.';
//       return;
//     }

//     final userId = _localStorage.userId;
//     if (userId == 0) {
//       bookings.clear();
//       errorMessage.value = 'ID pengguna tidak valid.';
//       return;
//     }

//     isLoading.value = true;
//     errorMessage.value = '';

//     try {
//       final results = await _bookingRepository.getBookingsByOwner(
//         ownerId: userId,
//       );
//       bookings.assignAll(results);
//     } on BookingException catch (e) {
//       bookings.clear();
//       errorMessage.value = e.message;
//     } catch (_) {
//       bookings.clear();
//       errorMessage.value =
//           'Gagal memuat data booking. Silakan coba lagi nanti.';
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> refreshBookings() => fetchBookings();

//   List<OwnerBooking> get filteredBookings {
//     final now = DateTime.now();
//     final query = searchQuery.value.trim().toLowerCase();
//     final statusFilter = filterStatus.value;

//     final relevantStatuses = <OwnerBookingStatus>{
//       OwnerBookingStatus.pending,
//       OwnerBookingStatus.accepted,
//       OwnerBookingStatus.rejected,
//     };

//     final list = bookings.where((booking) {
//       final normalizedStatus = booking.normalizedStatus;
//       if (!relevantStatuses.contains(normalizedStatus)) {
//         return false;
//       }

//       if (_shouldHidePastBooking(booking, normalizedStatus, now)) {
//         return false;
//       }

//       if (statusFilter != 'All' &&
//           normalizedStatus.label.toLowerCase() != statusFilter.toLowerCase()) {
//         return false;
//       }

//       if (query.isNotEmpty && !_matchesSearchQuery(booking, query)) {
//         return false;
//       }

//       return true;
//     }).toList();

//     list.sort((a, b) {
//       final statusComparison = _statusPriority(
//         a.normalizedStatus,
//       ).compareTo(_statusPriority(b.normalizedStatus));
//       if (statusComparison != 0) {
//         return statusComparison;
//       }

//       final startComparison = a.bookingStart.compareTo(b.bookingStart);
//       if (startComparison != 0) {
//         return startComparison;
//       }

//       return a.bookingEnd.compareTo(b.bookingEnd);
//     });

//     return list;
//   }

//   bool _matchesSearchQuery(OwnerBooking booking, String query) {
//     bool contains(String value) => value.toLowerCase().contains(query);

//     if (contains(booking.userName)) return true;
//     if (contains(booking.fieldName)) return true;
//     if (contains(booking.placeName)) return true;
//     if (contains(booking.orderId)) return true;

//     final formattedDate = DateFormat('yyyy-MM-dd').format(booking.bookingStart);
//     return formattedDate.contains(query);
//   }

//   bool _shouldHidePastBooking(
//     OwnerBooking booking,
//     OwnerBookingStatus status,
//     DateTime now,
//   ) {
//     if (status == OwnerBookingStatus.pending) {
//       return false;
//     }
//     return booking.bookingEnd.isBefore(now);
//   }

//   int _statusPriority(OwnerBookingStatus status) {
//     switch (status) {
//       case OwnerBookingStatus.pending:
//         return 0;
//       case OwnerBookingStatus.accepted:
//         return 1;
//       case OwnerBookingStatus.rejected:
//         return 2;
//       default:
//         return 3;
//     }
//   }

//   Color statusColor(OwnerBookingStatus status) {
//     switch (status) {
//       case OwnerBookingStatus.pending:
//         return Colors.orange;
//       case OwnerBookingStatus.accepted:
//         return Colors.green;
//       case OwnerBookingStatus.rejected:
//         return Colors.red;
//       case OwnerBookingStatus.cancelled:
//         return Colors.grey;
//       case OwnerBookingStatus.completed:
//         return Colors.blueGrey;
//       case OwnerBookingStatus.unknown:
//         return Colors.grey;
//     }
//   }

//   String statusLabel(OwnerBooking booking) => booking.normalizedStatus.label;

//   String formatDate(DateTime date) =>
//       DateFormat('EEE, d MMM yyyy').format(date);

//   String formatTimeRange(DateTime start, DateTime end) {
//     final timeFormat = DateFormat('HH:mm');
//     return '${timeFormat.format(start)} - ${timeFormat.format(end)}';
//   }

//   String formatPrice(num value) {
//     final currency = NumberFormat.currency(
//       locale: 'id_ID',
//       symbol: 'Rp',
//       decimalDigits: 0,
//     );
//     return currency.format(value);
//   }

//   void updateStatus(int id, OwnerBookingStatus newStatus) {
//     final index = bookings.indexWhere((booking) => booking.id == id);
//     if (index == -1) return;
//     final rawStatus = _statusToRaw(newStatus);
//     bookings[index] = bookings[index].copyWith(status: rawStatus);
//     bookings.refresh();
//   }

//   String _statusToRaw(OwnerBookingStatus status) {
//     switch (status) {
//       case OwnerBookingStatus.pending:
//         return 'pending';
//       case OwnerBookingStatus.accepted:
//         return 'accepted';
//       case OwnerBookingStatus.rejected:
//         return 'rejected';
//       case OwnerBookingStatus.cancelled:
//         return 'cancelled';
//       case OwnerBookingStatus.completed:
//         return 'completed';
//       case OwnerBookingStatus.unknown:
//         return 'unknown';
//     }
//   }

//   // ✅ TAMBAHKAN HELPER METHODS
//   bool get isUserValid => _localStorage.isLoggedIn && _localStorage.userId > 0;
//   String get userName => _localStorage.userName;
//   String get userRole => _localStorage.userRole;
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/owner_booking_model.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../services/local_storage_service.dart';
// import '../../../../data/services/session_service.dart';

class FieldManagerBookingController extends GetxController {
  FieldManagerBookingController({BookingRepository? bookingRepository})
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
    //     // ✅ PERBAIKAN: Gunakan LocalStorageService untuk mendapatkan user data
    if (!_localStorage.isLoggedIn) {
      bookings.clear();
      errorMessage.value = 'Sesi berakhir. Silakan masuk kembali.';
      return;
    }

    final userId = _localStorage.userId;
    if (userId == 0) {
      bookings.clear();
      errorMessage.value = 'ID pengguna tidak valid.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final results = await _bookingRepository.getBookingsByOwner(
        ownerId: userId,
      );
      bookings.assignAll(results);
    } on BookingException catch (e) {
      bookings.clear();
      errorMessage.value = e.message;
    } catch (_) {
      bookings.clear();
      errorMessage.value =
          'Gagal memuat data booking. Silakan coba lagi nanti.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBookings() => fetchBookings();

  List<OwnerBooking> get filteredBookings {
    final now = DateTime.now();
    final query = searchQuery.value.trim().toLowerCase();
    final statusFilter = filterStatus.value;

    final relevantStatuses = <OwnerBookingStatus>{
      OwnerBookingStatus.pending,
      OwnerBookingStatus.accepted,
      OwnerBookingStatus.rejected,
    };

    final list = bookings.where((booking) {
      final normalizedStatus = booking.normalizedStatus;
      if (!relevantStatuses.contains(normalizedStatus)) {
        return false;
      }

      if (_shouldHidePastBooking(booking, normalizedStatus, now)) {
        return false;
      }

      if (statusFilter != 'All' &&
          normalizedStatus.label.toLowerCase() != statusFilter.toLowerCase()) {
        return false;
      }

      if (query.isNotEmpty && !_matchesSearchQuery(booking, query)) {
        return false;
      }

      return true;
    }).toList();

    list.sort((a, b) {
      final statusComparison = _statusPriority(
        a.normalizedStatus,
      ).compareTo(_statusPriority(b.normalizedStatus));
      if (statusComparison != 0) {
        return statusComparison;
      }

      final startComparison = a.bookingStart.compareTo(b.bookingStart);
      if (startComparison != 0) {
        return startComparison;
      }

      return a.bookingEnd.compareTo(b.bookingEnd);
    });

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

  bool _shouldHidePastBooking(
    OwnerBooking booking,
    OwnerBookingStatus status,
    DateTime now,
  ) {
    if (status == OwnerBookingStatus.pending) {
      return false;
    }
    return booking.bookingEnd.isBefore(now);
  }

  int _statusPriority(OwnerBookingStatus status) {
    switch (status) {
      case OwnerBookingStatus.pending:
        return 0;
      case OwnerBookingStatus.accepted:
        return 1;
      case OwnerBookingStatus.rejected:
        return 2;
      default:
        return 3;
    }
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

  void updateStatus(int id, OwnerBookingStatus newStatus) {
    final index = bookings.indexWhere((booking) => booking.id == id);
    if (index == -1) return;
    final rawStatus = _statusToRaw(newStatus);
    bookings[index] = bookings[index].copyWith(status: rawStatus);
    bookings.refresh();
  }

  String _statusToRaw(OwnerBookingStatus status) {
    switch (status) {
      case OwnerBookingStatus.pending:
        return 'pending';
      case OwnerBookingStatus.accepted:
        return 'accepted';
      case OwnerBookingStatus.rejected:
        return 'rejected';
      case OwnerBookingStatus.cancelled:
        return 'cancelled';
      case OwnerBookingStatus.completed:
        return 'completed';
      case OwnerBookingStatus.unknown:
        return 'unknown';
    }
  }
}
