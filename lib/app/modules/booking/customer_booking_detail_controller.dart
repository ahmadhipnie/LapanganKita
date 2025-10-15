import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/data/models/owner_booking_model.dart';
import 'package:lapangan_kita/app/data/repositories/booking_repository.dart';
import 'package:lapangan_kita/app/data/repositories/customer_booking_repository.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

import '../../data/models/customer/booking/booking_request.dart';
import '../../data/models/customer/booking/booking_response.dart';
import '../../data/models/customer/booking/court_model.dart';
import '../../data/models/add_on_model.dart';
// import '../../data/models/customer/history/customer_history_model.dart';
import '../../data/models/customer/rating/rating_model.dart';
import '../../data/repositories/add_on_repository.dart';
import '../../data/repositories/rating_repository.dart';
import '../../data/services/midtrans_service.dart';
// import '../history/customer_history_controller.dart';
import '../midtrans/midtrans_webview.dart';

class CustomerBookingDetailController extends GetxController {
  final Court court = Get.arguments;
  final AddOnRepository _addOnRepository = Get.find<AddOnRepository>();
  final CustomerBookingRepository _bookingRepository =
      Get.find<CustomerBookingRepository>();
  final RatingRepository _ratingRepository = Get.find<RatingRepository>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();
  final BookingRepository _ownerBookingRepository =
      Get.find<BookingRepository>();

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedDuration = '1'.obs;
  final RxString selectedStartTime = ''.obs;
  final RxDouble totalPrice = 0.0.obs;
  final RxMap<String, int> selectedEquipment = <String, int>{}.obs;
  final RxMap<String, int> selectedAddOns = <String, int>{}.obs;
  final RxList<AddOnModel> availableAddOns = <AddOnModel>[].obs;
  final RxString selectedAddOnCategory = ''.obs;
  final RxList<OwnerBooking> approvedBookings = <OwnerBooking>[].obs;
  final RxBool isLoadingAddOns = false.obs;
  final RxBool isRefreshingAddOns = false.obs;
  final RxBool isBooking = false.obs;

  // Rating related observables
  final RxBool isLoadingRatings = false.obs;
  final RxList<RatingDetailData> allRatings = <RatingDetailData>[].obs;
  final Rx<PlaceRatingSummary?> placeRatingSummary = Rx<PlaceRatingSummary?>(
    null,
  );

  // Data booking history yang sudah di-load (dari controller history)
  // final List<BookingHistory> allBookings = [];

  final RxList<String> availableTimes = <String>[].obs;
  final RxList<String> busyTimes = <String>[].obs;

  final List<String> durationOptions = ['1', '2', '3', '4', '5', '6'];

  int get userId => _localStorage.getUserData()?['id'] ?? 0;

  @override
  void onInit() {
    super.onInit();
    _calculateTotalPrice();
    _loadAddOns();
    _generateAvailableTimes();
    _loadApprovedBookings();
    _loadRatings();

    ever(selectedDuration, (_) {
      selectedStartTime.value = '';
      _updateBusyTimes(); // Update busy times ketika durasi berubah
    });

    ever(selectedDate, (_) {
      selectedStartTime.value = '';
      _updateBusyTimes(); // Update busy times ketika tanggal berubah
    });
  }

  // void setApprovedBookings(List<BookingHistory> bookings) {
  //   allBookings.clear();
  //   allBookings.addAll(bookings);
  //   _updateBusyTimes();
  // }

  // Generate available times berdasarkan opening dan closing time court
  void _generateAvailableTimes() {
    try {
      final openingTime = court.openingTime;
      final closingTime = court.closingTime;

      // Default fallback times
      final List<String> defaultTimes = [
        '06:00',
        '07:00',
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '12:00',
        '13:00',
        '14:00',
        '15:00',
        '16:00',
        '17:00',
        '18:00',
        '19:00',
        '20:00',
        '21:00',
        '22:00',
        '23:00',
      ];

      if (openingTime.isEmpty || closingTime.isEmpty) {
        availableTimes.assignAll(defaultTimes);
        print('Using default available times: ${defaultTimes.join(', ')}');
        return;
      }

      // Parse opening dan closing time
      final opening = _parseTimeString(openingTime);
      final closing = _parseTimeString(closingTime);

      if (opening == null || closing == null) {
        availableTimes.assignAll(defaultTimes);
        print('Using default available times: ${defaultTimes.join(', ')}');
        return;
      }

      // Generate times dari opening sampai closing (per jam)
      final List<String> times = [];
      int currentHour = opening.hour;

      // Jika closing hour < opening hour, berarti buka sampai besok (misal 22:00 - 02:00)
      if (closing.hour < opening.hour) {
        // Dari opening hour sampai 23:00
        for (int hour = opening.hour; hour <= 23; hour++) {
          times.add('${hour.toString().padLeft(2, '0')}:00');
        }
        // Dari 00:00 sampai closing hour
        for (int hour = 0; hour <= closing.hour; hour++) {
          times.add('${hour.toString().padLeft(2, '0')}:00');
        }
      } else {
        // Normal case: opening hour <= closing hour
        while (currentHour <= closing.hour) {
          final timeString = '${currentHour.toString().padLeft(2, '0')}:00';
          times.add(timeString);
          currentHour += 1;

          // Safety break
          if (currentHour > 23) break;
        }
      }

      availableTimes.assignAll(times);
      print('Court: ${court.name}');
      print('Opening: $openingTime | Closing: $closingTime');
      print('Generated available times: ${times.join(', ')}');
    } catch (e) {
      print('Error generating available times: $e');
      // Fallback ke default times
      availableTimes.assignAll([
        '06:00',
        '07:00',
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '12:00',
        '13:00',
        '14:00',
        '15:00',
        '16:00',
        '17:00',
        '18:00',
        '19:00',
        '20:00',
        '21:00',
        '22:00',
        '23:00',
      ]);
    }
  }

  TimeOfDay? _parseTimeString(String timeString) {
    try {
      // Hilangkan detik jika ada
      final timeWithoutSeconds = timeString.split(':').sublist(0, 2).join(':');
      final timeOfDay = TimeOfDay.fromDateTime(
        DateFormat('HH:mm').parse(timeWithoutSeconds),
      );
      return timeOfDay;
    } catch (e) {
      print('Error parsing time string: $e');
      return null;
    }
  }

  // Load approved bookings dari history controller
  Future<void> _loadApprovedBookings() async {
    try {
      print('🔄 Loading approved bookings from API for court: ${court.name}');

      final allBookings = await _ownerBookingRepository.getBookingsAll();

      // Filter hanya booking yang approved untuk court ini
      final filteredBookings = allBookings.where((booking) {
        return booking.status.toLowerCase() == 'approved' &&
            booking.fieldName == court.name;
      }).toList();

      approvedBookings.assignAll(filteredBookings);

      print('✅ Loaded ${filteredBookings.length} approved bookings from API');
      _updateBusyTimes();
    } catch (e) {
      print('❌ Error loading approved bookings from API: $e');
      // Tetap update busy times dengan list kosong jika error
      approvedBookings.clear();
      _updateBusyTimes();
    }
  }

  // Update busy times berdasarkan selected date dan approved bookings
  void _updateBusyTimes() {
    try {
      final formattedSelectedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(selectedDate.value);
      final List<String> newBusyTimes = [];

      print('=== UPDATING BUSY TIMES (FROM API) ===');
      print('Date: $formattedSelectedDate');
      print('Court: ${court.name}');
      print('Total approved bookings: ${approvedBookings.length}');

      for (final booking in approvedBookings) {
        final bookingDate = booking.bookingStart;
        final startTime = DateFormat('HH:mm').format(booking.bookingStart);
        final duration = _calculateDuration(
          booking.bookingStart,
          booking.bookingEnd,
        );

        final bookingFormattedDate = DateFormat(
          'yyyy-MM-dd',
        ).format(bookingDate);

        if (bookingFormattedDate == formattedSelectedDate) {
          print('Processing booking: $startTime for $duration hours');

          final bookingTimeSlots = _getTimeSlotsFromBooking(
            startTime,
            duration,
          );
          newBusyTimes.addAll(bookingTimeSlots);

          print('Added busy slots: ${bookingTimeSlots.join(', ')}');
        }
      }

      busyTimes.assignAll(newBusyTimes.toSet().toList());
      print('Final Busy Times: ${busyTimes.join(', ')}');
      print('Total Busy Slots: ${busyTimes.length}');
      print('=== END BUSY TIMES UPDATE ===');

      _updateTimeAvailability();
    } catch (e) {
      print('❌ Error updating busy times: $e');
      busyTimes.clear();
    }
  }

  int _calculateDuration(DateTime start, DateTime end) {
    final difference = end.difference(start);
    return difference.inHours;
  }

  List<String> _getTimeSlotsFromBooking(String startTime, int duration) {
    final List<String> timeSlots = [];

    try {
      final startParts = startTime.split(':');
      if (startParts.length >= 2) {
        final startHour = int.tryParse(startParts[0]) ?? 0;

        for (int i = 0; i < duration; i++) {
          final slotHour = startHour + i;
          if (slotHour < 24) {
            final timeSlot = '${slotHour.toString().padLeft(2, '0')}:00';
            timeSlots.add(timeSlot);
          }
        }

        print('$duration-hour booking: Added slots ${timeSlots.join(', ')}');
      }
    } catch (e) {
      print('❌ Error getting time slots from booking: $e');
    }

    return timeSlots;
  }

  // Update time availability berdasarkan durasi yang dipilih
  void _updateTimeAvailability() {
    // Trigger update di UI
    update();
  }

  // List<String> _getTimeSlotsFromBooking(BookingHistory booking) {
  //   final List<String> timeSlots = [];

  //   try {
  //     final startTime = booking.startTime; // opening time
  //     final bookingDuration = booking.duration;

  //     // Parse start time (format: "HH:MM")
  //     final startParts = startTime.split(':');
  //     if (startParts.length >= 2) {
  //       final startHour = int.tryParse(startParts[0]) ?? 0;

  //       // SELALU ambil semua timeslot dari opening time berdasarkan duration booking
  //       for (int i = 0; i < bookingDuration; i++) {
  //         final slotHour = startHour + i;
  //         if (slotHour < 24) {
  //           final timeSlot = '${slotHour.toString().padLeft(2, '0')}:00';
  //           timeSlots.add(timeSlot);
  //         }
  //       }

  //       print(
  //         '${bookingDuration}-hour booking: Added slots ${timeSlots.join(', ')}',
  //       );
  //     }
  //   } catch (e) {
  //     print('Error getting time slots from booking: $e');
  //   }

  //   return timeSlots;
  // }

  Future<void> _loadAddOns() async {
    if (court.placeId == 0) return;
    isLoadingAddOns.value = true;
    try {
      final addOns = await _addOnRepository.getAddOnsByPlace(
        placeId: court.placeId,
      );
      availableAddOns.assignAll(addOns);

      // ✅ SET DEFAULT CATEGORY (first category or empty)
      if (addOns.isNotEmpty) {
        selectedAddOnCategory.value = addOns.first.category;
      }
    } catch (e) {
      print('Error loading add-ons: $e');
    } finally {
      isLoadingAddOns.value = false;
    }
  }

  // Method untuk refresh data dari history controller
  // Future<void> refreshAvailability() async {
  //   _loadApprovedBookingsFromHistory();
  // }

  Future<void> refreshAvailability() async {
    await _loadApprovedBookings();
  }

  // Update method isTimeAvailable untuk menggunakan busyTimes
  bool isTimeAvailable(String time) {
    return !busyTimes.contains(time);
  }

  // Update method isTimeAvailableWithDuration
  bool isTimeAvailableWithDuration(String startTime, int duration) {
    final startIndex = availableTimes.indexOf(startTime);
    if (startIndex == -1) return false;

    // Cek semua slot waktu dalam durasi
    for (int i = 0; i < duration; i++) {
      if (startIndex + i >= availableTimes.length) return false;
      final timeSlot = availableTimes[startIndex + i];
      if (busyTimes.contains(timeSlot)) return false;
    }

    return true;
  }

  // bool isTimeAvailable(String time) {
  //   return !busyTimes.contains(time);
  // }

  // bool _isWithinOperatingHours(String startTime, int duration) {
  //   try {
  //     final opening = _parseTimeString(court.openingTime);
  //     final closing = _parseTimeString(court.closingTime);

  //     if (opening == null || closing == null) return true; // Fallback ke true

  //     // Parse start time
  //     final startParts = startTime.split(':');
  //     if (startParts.length < 2) return false;

  //     final startHour = int.tryParse(startParts[0]) ?? 0;
  //     final endHour = startHour + duration;

  //     // Cek apakah end time melebihi closing time
  //     return endHour <= closing.hour;
  //   } catch (e) {
  //     print('Error checking operating hours: $e');
  //     return true; // Fallback ke true jika error
  //   }
  // }

  bool isTimeInSelectedRange(String time) {
    if (selectedStartTime.value.isEmpty) return false;

    final selectedIndex = availableTimes.indexOf(selectedStartTime.value);
    final currentIndex = availableTimes.indexOf(time);
    final duration = int.parse(selectedDuration.value);

    if (selectedIndex == -1 || currentIndex == -1) return false;

    return currentIndex >= selectedIndex &&
        currentIndex < selectedIndex + duration;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedStartTime.value = '';
    _updateBusyTimes();
  }

  Future<void> refreshAddOns() async {
    if (court.placeId == 0) return;
    isRefreshingAddOns.value = true;
    try {
      await _loadAddOns();
    } finally {
      isRefreshingAddOns.value = false;
    }
  }

  void selectStartTime(String time) {
    selectedStartTime.value = time;
    _calculateTotalPrice();
  }

  void unselectStartTime() {
    selectedStartTime.value = '';
    _calculateTotalPrice();
  }

  void selectDuration(String duration) {
    selectedDuration.value = duration;
    _calculateTotalPrice();
    _updateTimeAvailability(); // Update availability ketika durasi berubah
  }

  String formatRupiah(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  String get formattedTotalPrice => formatRupiah(totalPrice.value);

  // bool isTimeAvailableWithDuration(String startTime, int duration) {
  //   final startIndex = availableTimes.indexOf(startTime);
  //   if (startIndex == -1) return false;

  //   for (int i = 0; i < duration; i++) {
  //     if (startIndex + i >= availableTimes.length) return false;
  //     final timeSlot = availableTimes[startIndex + i];
  //     if (!isTimeAvailable(timeSlot)) return false;
  //   }
  //   return true;
  // }

  // bool isTimeInSelectedRange(String time) {
  //   if (selectedStartTime.value.isEmpty) return false;
  //   final selectedIndex = availableTimes.indexOf(selectedStartTime.value);
  //   final currentIndex = availableTimes.indexOf(time);
  //   final duration = int.parse(selectedDuration.value);

  //   if (selectedIndex == -1 || currentIndex == -1) return false;
  //   return currentIndex >= selectedIndex &&
  //       currentIndex < selectedIndex + duration;
  // }

  // bool isTimeAvailable(String time) {
  //   // TODO: Implement real availability check via API
  //   final busyTimes = ['18:00', '19:00', '20:00'];
  //   return !busyTimes.contains(time);
  // }

  void incrementEquipment(String equipmentName) {
    final currentCount = selectedEquipment[equipmentName] ?? 0;
    selectedEquipment[equipmentName] = currentCount + 1;
    _calculateTotalPrice();
  }

  void decrementEquipment(String equipmentName) {
    final currentCount = selectedEquipment[equipmentName] ?? 0;
    if (currentCount > 0) {
      selectedEquipment[equipmentName] = currentCount - 1;
      _calculateTotalPrice();
    }
  }

  void incrementAddOn(String addOnName) {
    final currentCount = selectedAddOns[addOnName] ?? 0;
    selectedAddOns[addOnName] = currentCount + 1;
    _calculateTotalPrice();
  }

  void decrementAddOn(String addOnName) {
    final currentCount = selectedAddOns[addOnName] ?? 0;
    if (currentCount > 0) {
      selectedAddOns[addOnName] = currentCount - 1;
      _calculateTotalPrice();
    }
  }

  int getAddOnQuantity(String addOnName) {
    return selectedAddOns[addOnName] ?? 0;
  }

  void _calculateTotalPrice() {
    double basePrice = court.price * int.parse(selectedDuration.value);

    double equipmentPrice = 0;
    selectedEquipment.forEach((name, quantity) {
      final equipment = court.equipment.firstWhere(
        (e) => e.name == name,
        orElse: () => Equipment(name: name, price: 0, description: ''),
      );
      equipmentPrice += equipment.price * quantity;
    });

    double addOnPrice = 0;
    selectedAddOns.forEach((name, quantity) {
      if (quantity > 0) {
        final addOn = availableAddOns.firstWhere(
          (a) => a.name == name,
          orElse: () => AddOnModel(
            id: 0,
            name: name,
            price: 0,
            category: 'once time',
            stock: 0,
            description: '',
          ),
        );
        addOnPrice += addOn.price * quantity;
      }
    });

    totalPrice.value = basePrice + equipmentPrice + addOnPrice;
  }

  Future<void> bookNow() async {
    // Validations
    if (userId == 0) {
      Get.snackbar('Error', 'Please login to book a court');
      return;
    }

    if (selectedStartTime.value.isEmpty) {
      Get.snackbar('Error', 'Please select start time');
      return;
    }

    if (isBooking.value) return;

    isBooking.value = true;

    try {
      // 1. Calculate booking times
      final startDateTime = _calculateStartDateTime();
      final endDateTime = _calculateEndDateTime();

      // 2. Prepare add-ons data
      final List<Map<String, dynamic>> addOnsList = [];
      selectedAddOns.forEach((name, quantity) {
        if (quantity > 0) {
          final addOn = availableAddOns.firstWhere(
            (a) => a.name == name,
            orElse: () => AddOnModel(
              id: 0,
              name: name,
              price: 0,
              category: 'once time',
              stock: 0,
              description: '',
            ),
          );
          if (addOn.id != 0) {
            addOnsList.add({'id_add_on': addOn.id, 'quantity': quantity});
          }
        }
      });

      // 3. Prepare transaction items
      final List<Map<String, dynamic>> items = [];

      // Court booking item
      items.add({
        'id': court.id.toString(),
        'price': court.price.toInt(),
        'quantity': int.parse(selectedDuration.value),
        'name': court.name,
      });

      // Equipment items
      selectedEquipment.forEach((name, quantity) {
        if (quantity > 0) {
          final equipment = court.equipment.firstWhere(
            (e) => e.name == name,
            orElse: () => Equipment(name: name, price: 0, description: ''),
          );
          if (equipment.price > 0) {
            items.add({
              'id': 'equipment_${name.toLowerCase().replaceAll(' ', '_')}',
              'price': equipment.price.toInt(),
              'quantity': quantity,
              'name': 'Equipment: $name',
            });
          }
        }
      });

      // Add-on items
      selectedAddOns.forEach((name, quantity) {
        if (quantity > 0) {
          final addOn = availableAddOns.firstWhere(
            (a) => a.name == name,
            orElse: () => AddOnModel(
              id: 0,
              name: name,
              price: 0,
              category: 'once time',
              stock: 0,
              description: '',
            ),
          );
          if (addOn.id != 0 && addOn.price > 0) {
            items.add({
              'id': 'addon_${addOn.id}',
              'price': addOn.price.toInt(),
              'quantity': quantity,
              'name': addOn.name,
            });
          }
        }
      });

      // 4. Prepare customer details
      final userData = _localStorage.getUserData();
      final userName = userData?['name']?.toString() ?? 'Customer';
      final nameParts = userName.split(' ');

      final customerDetails = {
        'first_name': nameParts.first,
        'last_name': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        'email': userData?['email']?.toString() ?? 'customer@example.com',
        'phone': userData?['phone']?.toString() ?? '+6281234567890',
      };

      // 5. Generate order ID
      final orderId = 'BOOKING-${DateTime.now().millisecondsSinceEpoch}';

      // 6. Create snap token
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      final snapToken = await MidtransService.instance.createSnapToken(
        orderId: orderId,
        grossAmount: totalPrice.value,
        items: items,
        customerDetails: customerDetails,
      );

      if (snapToken.isEmpty) {
        Get.back(); // Close loading
        Get.snackbar('Error', 'Failed to get payment token');
        return;
      }

      Get.back(); // Close loading

      // 7. Open WebView for payment DULU
      final snapUrl = MidtransService.instance.getSnapUrl(snapToken);

      final paymentResult = await Navigator.push(
        Get.context!,
        MaterialPageRoute(
          builder: (context) =>
              MidtransWebView(snapUrl: snapUrl, orderId: orderId),
        ),
      );

      // 8. CEK payment result dulu
      if (paymentResult == null ||
          paymentResult['status'] == 'cancelled' ||
          paymentResult['status'] == 'failed') {
        // Payment cancelled/failed, jangan buat booking
        if (paymentResult?['status'] == 'cancelled') {
          Get.snackbar(
            'Cancelled',
            'Payment was cancelled',
            snackPosition: SnackPosition.TOP,
          );
        } else if (paymentResult?['status'] == 'failed') {
          Get.snackbar(
            'Failed',
            'Payment failed',
            snackPosition: SnackPosition.TOP,
          );
        }
        return;
      }

      // 9. HANYA jika payment success/pending, baru create booking
      if (paymentResult['status'] == 'success' ||
          paymentResult['status'] == 'pending') {
        Get.dialog(
          const Center(child: CircularProgressIndicator(color: Colors.white)),
          barrierDismissible: false,
        );

        try {
          final bookingRequest = BookingRequest(
            idUsers: userId,
            fieldId: court.id,
            bookingDatetimeStart: startDateTime,
            bookingDatetimeEnd: endDateTime,
            snapToken: snapToken,
            note: 'Booking untuk ${court.name}',
            addOns: addOnsList,
          );

          final BookingResponse bookingResponse = await _bookingRepository
              .createBooking(bookingRequest);

          Get.back(); // Close loading

          await Future.delayed(Duration(milliseconds: 100));
          _handlePaymentResult(paymentResult, bookingResponse.id);

          // 10. Navigate ke halaman success
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   _handlePaymentResult(paymentResult, bookingResponse.id);
          // });
        } catch (e, stackTrace) {
          Get.back(); // Close loading
          print('Error creating booking after payment: $e');
          print('Stack trace: $stackTrace');

          // Tampilkan error yang lebih spesifik
          Get.offAllNamed(
            '/booking/error',
            arguments: {
              'orderId': orderId,
              'message':
                  'Payment successful but booking failed. Error: ${e.toString()}',
            },
          );
        }
      }
    } catch (e) {
      Get.back(); // Close loading if still open
      print('Booking error: $e');
      Get.snackbar(
        'Error',
        'Failed to create booking: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isBooking.value = false;
    }
  }

  void _handlePaymentResult(Map<String, dynamic> result, int bookingId) {
    final status = result['status'];

    print('===== HANDLING PAYMENT RESULT =====');
    print('Status: $status');
    print('Booking ID: $bookingId');
    print('==============================');

    // Delay kecil untuk memastikan UI ready
    Future.delayed(Duration(milliseconds: 300), () {
      try {
        // Navigate ke customer navigation dengan initialTab 3 (booking history)
        Get.offAllNamed('/customer/navigation', arguments: {'initialTab': 3});

        // Tampilkan snackbar sesuai status
        _showStatusSnackbar(status, bookingId);
      } catch (e, stackTrace) {
        print('Navigation error: $e');
        print('Stack trace: $stackTrace');

        // Fallback ke home dengan snackbar
        Get.offAllNamed('/home');
        _showStatusSnackbar(status, bookingId);
      }
    });
  }

  void _showStatusSnackbar(String status, int bookingId) {
    // Delay sedikit agar navigasi selesai dulu
    Future.delayed(Duration(milliseconds: 500), () {
      switch (status) {
        case 'success':
          Get.snackbar(
            'Booking Success! 🎉',
            'Booking ID: $bookingId telah berhasil dibuat',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            icon: Icon(Icons.check_circle, color: Colors.white),
          );
          break;

        case 'pending':
          Get.snackbar(
            'Booking Pending ⏳',
            'Booking ID: $bookingId menunggu konfirmasi pembayaran',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            icon: Icon(Icons.pending, color: Colors.white),
          );
          break;

        case 'cancelled':
          Get.snackbar(
            'Booking Cancelled ❌',
            'Pembayaran dibatalkan',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.grey,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
            icon: Icon(Icons.cancel, color: Colors.white),
          );
          break;

        case 'failed':
          Get.snackbar(
            'Booking Failed 😞',
            'Pembayaran gagal, silakan coba lagi',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
            icon: Icon(Icons.error, color: Colors.white),
          );
          break;

        default:
          Get.snackbar(
            'Booking Completed',
            'Status: $status. Booking ID: $bookingId',
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 4),
          );
          break;
      }
    });
  }

  DateTime _calculateStartDateTime() {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    return DateTime.parse('$dateStr ${selectedStartTime.value}:00');
  }

  DateTime _calculateEndDateTime() {
    final startDateTime = _calculateStartDateTime();
    final duration = int.parse(selectedDuration.value);
    return startDateTime.add(Duration(hours: duration));
  }

  // Rating related methods
  Future<void> _loadRatings() async {
    try {
      isLoadingRatings.value = true;
      print('🔄 Loading ratings for place: ${court.placeName}');

      final ratingsResponse = await _ratingRepository.getAllRatings();

      if (ratingsResponse.success) {
        allRatings.assignAll(ratingsResponse.data);
        _calculatePlaceRatingSummary();

        print('✅ Loaded ${allRatings.length} total ratings');
        print(
          '📊 Place summary: ${placeRatingSummary.value?.totalReviews} reviews, avg: ${placeRatingSummary.value?.formattedAverageRating}',
        );
      }
    } catch (e) {
      print('❌ Error loading ratings: $e');
      // Don't show error to user, just log it
    } finally {
      isLoadingRatings.value = false;
    }
  }

  void _calculatePlaceRatingSummary() {
    if (allRatings.isNotEmpty) {
      final summary = _ratingRepository.getPlaceRatingSummary(
        court.placeName,
        allRatings,
      );
      placeRatingSummary.value = summary;
    }
  }

  Future<void> refreshRatings() async {
    await _loadRatings();
  }

  // Get reviews for this specific place
  List<RatingDetailData> get placeReviews {
    return allRatings
        .where((rating) => rating.placeName == court.placeName)
        .toList();
  }

  // Check if place has any ratings
  bool get hasRatings {
    return placeRatingSummary.value != null &&
        placeRatingSummary.value!.totalReviews > 0;
  }
}
