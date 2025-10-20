import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/data/models/owner_booking_model.dart';
import 'package:lapangan_kita/app/data/repositories/booking_repository.dart';
import 'package:lapangan_kita/app/data/repositories/customer_booking_repository.dart';
import 'package:lapangan_kita/app/services/local_storage_service.dart';

import '../../data/helper/error_helper.dart';
import '../../data/models/customer/booking/booking_request.dart';
import '../../data/models/customer/booking/court_model.dart';
import '../../data/models/add_on_model.dart';
import '../../data/models/customer/rating/rating_model.dart';
import '../../data/repositories/add_on_repository.dart';
import '../../data/repositories/rating_repository.dart';
import '../../data/services/midtrans_service.dart';
import '../midtrans/midtrans_webview.dart';

/// Controller for managing court booking details, availability, and payment processing
class CustomerBookingDetailController extends GetxController {
  // Dependencies
  final Court court = Get.arguments;
  final AddOnRepository _addOnRepository = Get.find<AddOnRepository>();
  final CustomerBookingRepository _bookingRepository =
      Get.find<CustomerBookingRepository>();
  final RatingRepository _ratingRepository = Get.find<RatingRepository>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();
  final BookingRepository _ownerBookingRepository =
      Get.find<BookingRepository>();
  final ErrorHandler _errorHandler = ErrorHandler();

  // Booking state
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedDuration = '1'.obs;
  final RxString selectedStartTime = ''.obs;
  final RxDouble totalPrice = 0.0.obs;
  final RxMap<String, int> selectedEquipment = <String, int>{}.obs;
  final RxMap<String, int> selectedAddOns = <String, int>{}.obs;

  // Available options
  final RxList<AddOnModel> availableAddOns = <AddOnModel>[].obs;
  final RxString selectedAddOnCategory = ''.obs;
  final RxList<String> availableTimes = <String>[].obs;
  final RxList<String> busyTimes = <String>[].obs;
  final List<String> durationOptions = ['1', '2', '3', '4', '5', '6'];

  // Bookings data
  final RxList<OwnerBooking> approvedBookings = <OwnerBooking>[].obs;

  // Loading states
  final RxBool isLoadingAddOns = false.obs;
  final RxBool isRefreshingAddOns = false.obs;
  final RxBool isBooking = false.obs;
  final RxBool isLoadingRatings = false.obs;

  // Rating data
  final RxList<RatingDetailData> allRatings = <RatingDetailData>[].obs;
  final Rx<PlaceRatingSummary?> placeRatingSummary = Rx<PlaceRatingSummary?>(
    null,
  );

  int get userId => _localStorage.getUserData()?['id'] ?? 0;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _setupReactiveListeners();
  }

  /// Initialize all required data
  void _initializeData() {
    _calculateTotalPrice();
    _loadAddOns();
    _generateAvailableTimes();
    _loadApprovedBookings();
    _loadRatings();
  }

  /// Setup reactive listeners for date and duration changes
  void _setupReactiveListeners() {
    ever(selectedDuration, (_) {
      selectedStartTime.value = '';
      _updateBusyTimes();
    });

    ever(selectedDate, (_) {
      selectedStartTime.value = '';
      _updateBusyTimes();
    });
  }

  /// Generate available time slots based on court operating hours
  void _generateAvailableTimes() {
    final defaultTimes = [
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

    try {
      final openingTime = court.openingTime;
      final closingTime = court.closingTime;

      if (openingTime.isEmpty || closingTime.isEmpty) {
        availableTimes.assignAll(defaultTimes);
        return;
      }

      final opening = _parseTimeString(openingTime);
      final closing = _parseTimeString(closingTime);

      if (opening == null || closing == null) {
        availableTimes.assignAll(defaultTimes);
        return;
      }

      final List<String> times = [];

      // Handle overnight operations (e.g., 22:00 - 02:00)
      if (closing.hour < opening.hour) {
        for (int hour = opening.hour; hour <= 23; hour++) {
          times.add('${hour.toString().padLeft(2, '0')}:00');
        }
        for (int hour = 0; hour <= closing.hour; hour++) {
          times.add('${hour.toString().padLeft(2, '0')}:00');
        }
      } else {
        // Normal operating hours
        int currentHour = opening.hour;
        while (currentHour <= closing.hour && currentHour <= 23) {
          times.add('${currentHour.toString().padLeft(2, '0')}:00');
          currentHour++;
        }
      }

      availableTimes.assignAll(times);
    } catch (e) {
      availableTimes.assignAll(defaultTimes);
    }
  }

  /// Parse time string to TimeOfDay object
  TimeOfDay? _parseTimeString(String timeString) {
    try {
      final timeWithoutSeconds = timeString.split(':').sublist(0, 2).join(':');
      return TimeOfDay.fromDateTime(
        DateFormat('HH:mm').parse(timeWithoutSeconds),
      );
    } catch (e) {
      return null;
    }
  }

  /// Load approved bookings from API and update availability
  Future<void> _loadApprovedBookings() async {
    try {
      final allBookings = await _ownerBookingRepository.getBookingsAll();

      final filteredBookings = allBookings.where((booking) {
        return booking.status.toLowerCase() == 'approved' &&
            booking.fieldName == court.name;
      }).toList();

      approvedBookings.assignAll(filteredBookings);
      _updateBusyTimes();
    } catch (e) {
      approvedBookings.clear();
      _updateBusyTimes();
    }
  }

  /// Update busy time slots based on existing bookings
  void _updateBusyTimes() {
    try {
      final formattedSelectedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(selectedDate.value);
      final List<String> newBusyTimes = [];

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
          final bookingTimeSlots = _getTimeSlotsFromBooking(
            startTime,
            duration,
          );
          newBusyTimes.addAll(bookingTimeSlots);
        }
      }

      busyTimes.assignAll(newBusyTimes.toSet().toList());
      _updateTimeAvailability();
    } catch (e) {
      busyTimes.clear();
    }
  }

  /// Calculate booking duration in hours
  int _calculateDuration(DateTime start, DateTime end) {
    return end.difference(start).inHours;
  }

  /// Get all time slots occupied by a booking
  List<String> _getTimeSlotsFromBooking(String startTime, int duration) {
    final List<String> timeSlots = [];

    try {
      final startParts = startTime.split(':');
      if (startParts.length >= 2) {
        final startHour = int.tryParse(startParts[0]) ?? 0;

        for (int i = 0; i < duration; i++) {
          final slotHour = startHour + i;
          if (slotHour < 24) {
            timeSlots.add('${slotHour.toString().padLeft(2, '0')}:00');
          }
        }
      }
    } catch (e) {
      // Return empty list on error
    }

    return timeSlots;
  }

  /// Trigger UI update for time availability
  void _updateTimeAvailability() {
    update();
  }

  /// Load available add-ons for the court's place
  Future<void> _loadAddOns() async {
    if (court.placeId == 0) return;

    isLoadingAddOns.value = true;
    try {
      final addOns = await _addOnRepository.getAddOnsByPlace(
        placeId: court.placeId,
      );
      availableAddOns.assignAll(addOns);

      if (addOns.isNotEmpty) {
        selectedAddOnCategory.value = addOns.first.category;
      }
    } catch (e) {
      // Handle error silently
    } finally {
      isLoadingAddOns.value = false;
    }
  }

  /// Refresh booking availability
  Future<void> refreshAvailability() async {
    await _loadApprovedBookings();
  }

  /// Refresh add-ons list
  Future<void> refreshAddOns() async {
    if (court.placeId == 0) return;

    isRefreshingAddOns.value = true;
    try {
      await _loadAddOns();
    } finally {
      isRefreshingAddOns.value = false;
    }
  }

  /// Check if a specific time is available
  bool isTimeAvailable(String time) {
    return !busyTimes.contains(time);
  }

  /// Check if a time slot with duration is available
  bool isTimeAvailableWithDuration(String startTime, int duration) {
    final startIndex = availableTimes.indexOf(startTime);
    if (startIndex == -1) return false;

    for (int i = 0; i < duration; i++) {
      if (startIndex + i >= availableTimes.length) return false;
      if (busyTimes.contains(availableTimes[startIndex + i])) return false;
    }

    return true;
  }

  /// Check if time is in selected booking range
  bool isTimeInSelectedRange(String time) {
    if (selectedStartTime.value.isEmpty) return false;

    final selectedIndex = availableTimes.indexOf(selectedStartTime.value);
    final currentIndex = availableTimes.indexOf(time);
    final duration = int.parse(selectedDuration.value);

    if (selectedIndex == -1 || currentIndex == -1) return false;

    return currentIndex >= selectedIndex &&
        currentIndex < selectedIndex + duration;
  }

  // Selection methods
  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedStartTime.value = '';
    _updateBusyTimes();
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
    _updateTimeAvailability();
  }

  // Equipment management
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

  // Add-on management
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

  /// Calculate total booking price including equipment and add-ons
  /// Calculate total booking price including equipment and add-ons
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

        // Check if add-on is per hour type
        if (addOn.category.toLowerCase() == 'per hour') {
          // Multiply by duration for per hour add-ons
          addOnPrice +=
              addOn.price * quantity * int.parse(selectedDuration.value);
        } else {
          // One-time charge for other categories
          addOnPrice += addOn.price * quantity;
        }
      }
    });

    totalPrice.value = basePrice + equipmentPrice + addOnPrice;
  }

  /// Format number to Indonesian Rupiah currency
  String formatRupiah(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  String get formattedTotalPrice => formatRupiah(totalPrice.value);

  /// Process booking with payment integration
  Future<void> bookNow() async {
    if (userId == 0) {
      _errorHandler.showErrorMessage('Please login to book a court');
      return;
    }

    if (selectedStartTime.value.isEmpty) {
      _errorHandler.showErrorMessage('Please select a start time');
      return;
    }

    if (isBooking.value) return;

    isBooking.value = true;

    try {
      final startDateTime = _calculateStartDateTime();
      final endDateTime = _calculateEndDateTime();

      // Prepare add-ons list
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

      // Prepare transaction items
      final items = _prepareTransactionItems();
      final customerDetails = _prepareCustomerDetails();
      final orderId = 'BOOKING-${DateTime.now().millisecondsSinceEpoch}';

      // Create payment token
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
        Get.back();
        _errorHandler.showErrorMessage(
          'Failed to initialize payment. Please try again.',
        );
        return;
      }

      Get.back();

      // Open payment webview
      final snapUrl = MidtransService.instance.getSnapUrl(snapToken);
      final paymentResult = await Navigator.push(
        Get.context!,
        MaterialPageRoute(
          builder: (context) =>
              MidtransWebView(snapUrl: snapUrl, orderId: orderId),
        ),
      );

      // Handle payment result
      if (paymentResult == null ||
          paymentResult['status'] == 'cancelled' ||
          paymentResult['status'] == 'failed') {
        if (paymentResult?['status'] == 'cancelled') {
          _errorHandler.showWarningMessage('Payment was cancelled');
        } else if (paymentResult?['status'] == 'failed') {
          _errorHandler.showErrorMessage('Payment failed. Please try again.');
        }
        return;
      }

      // Create booking after successful payment
      if (paymentResult['status'] == 'success' ||
          paymentResult['status'] == 'pending') {
        await _createBooking(
          startDateTime,
          endDateTime,
          snapToken,
          addOnsList,
          paymentResult,
          orderId,
        );
      }
    } catch (e) {
      Get.back();
      final userFriendlyError = _errorHandler.getSimpleErrorMessage(e);
      _errorHandler.showErrorMessage(
        'Failed to create booking: $userFriendlyError',
      );
    } finally {
      isBooking.value = false;
    }
  }

  /// Create booking after payment confirmation
  Future<void> _createBooking(
    DateTime startDateTime,
    DateTime endDateTime,
    String snapToken,
    List<Map<String, dynamic>> addOnsList,
    Map<String, dynamic> paymentResult,
    String orderId,
  ) async {
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
        note: 'Booking for ${court.name}',
        addOns: addOnsList,
      );

      final bookingResponse = await _bookingRepository.createBooking(
        bookingRequest,
      );

      Get.back();
      await Future.delayed(Duration(milliseconds: 100));
      _handlePaymentResult(paymentResult, bookingResponse.id);
    } catch (e) {
      Get.back();
      final userFriendlyError = _errorHandler.getSimpleErrorMessage(e);

      Get.offAllNamed(
        '/booking/error',
        arguments: {
          'orderId': orderId,
          'message':
              'Payment successful but booking failed. $userFriendlyError',
        },
      );
    }
  }

  /// Prepare transaction items for payment
  List<Map<String, dynamic>> _prepareTransactionItems() {
    final List<Map<String, dynamic>> items = [];

    // Court booking
    items.add({
      'id': court.id.toString(),
      'price': court.price.toInt(),
      'quantity': int.parse(selectedDuration.value),
      'name': court.name,
    });

    // Equipment
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

    // Add-ons
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
          // Calculate final price based on category
          int finalPrice = addOn.price.toInt();
          int finalQuantity = quantity;

          if (addOn.category.toLowerCase() == 'per hour') {
            // For per hour, multiply price by duration and keep quantity as is
            finalPrice = (addOn.price * int.parse(selectedDuration.value))
                .toInt();
          }

          items.add({
            'id': 'addon_${addOn.id}',
            'price': finalPrice,
            'quantity': finalQuantity,
            'name': addOn.category.toLowerCase() == 'per hour'
                ? '${addOn.name} (${selectedDuration.value} hours)'
                : addOn.name,
          });
        }
      }
    });

    return items;
  }

  /// Prepare customer details for payment
  Map<String, dynamic> _prepareCustomerDetails() {
    final userData = _localStorage.getUserData();
    final userName = userData?['name']?.toString() ?? 'Customer';
    final nameParts = userName.split(' ');

    return {
      'first_name': nameParts.first,
      'last_name': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      'email': userData?['email']?.toString() ?? 'customer@example.com',
      'phone': userData?['phone']?.toString() ?? '+6281234567890',
    };
  }

  /// Handle payment result and navigate accordingly
  void _handlePaymentResult(Map<String, dynamic> result, int bookingId) {
    Future.delayed(Duration(milliseconds: 300), () {
      try {
        Get.offAllNamed('/customer/navigation', arguments: {'initialTab': 3});
        _showStatusSnackbar(result['status'], bookingId);
      } catch (e) {
        Get.offAllNamed('/home');
        _showStatusSnackbar(result['status'], bookingId);
      }
    });
  }

  /// Show appropriate snackbar based on payment status
  void _showStatusSnackbar(String status, int bookingId) {
    Future.delayed(Duration(milliseconds: 500), () {
      switch (status) {
        case 'success':
          _errorHandler.showCustomSnackbar(
            'Booking Successful!',
            'Your booking (ID: $bookingId) has been successfully created',
            SnackbarType.success,
          );
          break;

        case 'pending':
          _errorHandler.showCustomSnackbar(
            'Booking Pending',
            'Your booking (ID: $bookingId) is awaiting payment confirmation',
            SnackbarType.warning,
          );
          break;

        case 'cancelled':
          _errorHandler.showCustomSnackbar(
            'Booking Cancelled',
            'Payment was cancelled',
            SnackbarType.info,
          );
          break;

        case 'failed':
          _errorHandler.showCustomSnackbar(
            'Booking Failed',
            'Payment failed. Please try again.',
            SnackbarType.error,
          );
          break;

        default:
          _errorHandler.showCustomSnackbar(
            'Booking Completed',
            'Status: $status. Booking ID: $bookingId',
            SnackbarType.info,
          );
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

  // Rating methods

  /// Load all ratings and calculate summary for the place
  Future<void> _loadRatings() async {
    try {
      isLoadingRatings.value = true;
      final ratingsResponse = await _ratingRepository.getAllRatings();

      if (ratingsResponse.success) {
        allRatings.assignAll(ratingsResponse.data);
        _calculatePlaceRatingSummary();
      }
    } catch (e) {
      // Handle error silently
    } finally {
      isLoadingRatings.value = false;
    }
  }

  /// Calculate rating summary for the current place
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

  /// Get all reviews for this specific place
  List<RatingDetailData> get placeReviews {
    return allRatings
        .where((rating) => rating.placeName == court.placeName)
        .toList();
  }

  /// Check if place has any ratings
  bool get hasRatings {
    return placeRatingSummary.value != null &&
        placeRatingSummary.value!.totalReviews > 0;
  }
}
