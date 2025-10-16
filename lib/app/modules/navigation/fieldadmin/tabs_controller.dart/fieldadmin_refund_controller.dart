import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:lapangan_kita/app/data/models/owner_booking_model.dart';
import 'package:lapangan_kita/app/data/models/refund_model.dart';
import 'package:lapangan_kita/app/data/repositories/booking_repository.dart';
import 'package:lapangan_kita/app/data/repositories/refund_repository.dart';

class FieldadminTransactionController extends GetxController {
  FieldadminTransactionController({
    RefundRepository? refundRepository,
    BookingRepository? bookingRepository,
  }) : _refundRepository = refundRepository ?? Get.find<RefundRepository>(),
       _bookingRepository = bookingRepository ?? Get.find<BookingRepository>();

  final RefundRepository _refundRepository;
  final BookingRepository _bookingRepository;

  final RxList<RefundModel> refunds = <RefundModel>[].obs;
  final RxList<OwnerBooking> cancelledBookings = <OwnerBooking>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessingRefund = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString bookingWarning = ''.obs;

  final RxString filterStatus = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxList<String> statusOptions = <String>['All'].obs;
  final RxMap<int, String> _userBankTypes = <int, String>{}.obs;
  final RxMap<int, String> _userAccountNumbers = <int, String>{}.obs;

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _dateTimeFormatter = DateFormat(
    'dd MMM yyyy, HH:mm',
    'id_ID',
  );

  @override
  void onInit() {
    super.onInit();
    _ensureLocaleInitialized().then((_) => fetchRefunds());
  }

  static Future<void> _ensureLocaleInitialized() async {
    try {
      await initializeDateFormatting('id_ID', null);
    } catch (_) {
      await initializeDateFormatting();
    }
  }

  Future<void> fetchRefunds({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    }
    errorMessage.value = '';
    bookingWarning.value = '';

    try {
      final refundsResult = await _refundRepository.getRefunds();
      refunds.assignAll(refundsResult);
      _ingestRefundBankInfo(refundsResult);

      final bookingsResult = await _loadCancelledBookings();
      final refundedBookingIds = refundsResult
          .map((refund) => refund.bookingId)
          .whereType<int>()
          .toSet();
      final filteredBookings = bookingsResult
          .where((booking) => !refundedBookingIds.contains(booking.id))
          .toList();

      await _prefetchBankInfoForBookings(filteredBookings);
      cancelledBookings.assignAll(filteredBookings);

      _synchronizeStatusOptions(refundsResult, filteredBookings);
    } on RefundException catch (e) {
      refunds.clear();
      cancelledBookings.clear();
      errorMessage.value = e.message;
    } catch (_) {
      refunds.clear();
      cancelledBookings.clear();
      errorMessage.value =
          'Failed to load refund data. Please try again later.';
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<List<OwnerBooking>> _loadCancelledBookings() async {
    try {
      final bookings = await _bookingRepository.getBookingsAll();

      return bookings
          .where(
            (booking) =>
                booking.normalizedStatus == OwnerBookingStatus.cancelled,
          )
          .toList();
    } on BookingException catch (e) {
      bookingWarning.value = e.message;
      return const <OwnerBooking>[];
    } catch (_) {
      bookingWarning.value =
          'Failed to load booking data. Canceled booking. Please try again later.';
      return const <OwnerBooking>[];
    }
  }

  void _synchronizeStatusOptions(
    List<RefundModel> refundItems,
    List<OwnerBooking> bookingItems,
  ) {
    // Use fixed filter options instead of dynamic status-based options
    statusOptions
      ..clear()
      ..add('All')
      ..add('Refund')    // For cancelled bookings that can be processed
      ..add('Refunded'); // For already processed refunds

    if (!statusOptions.contains(filterStatus.value)) {
      filterStatus.value = 'All';
    }
  }

  List<FieldadminRefundItem> get filteredItems {
    var list = <FieldadminRefundItem>[
      ...refunds.map(FieldadminRefundItem.fromRefund),
      ...cancelledBookings.map(FieldadminRefundItem.fromBooking),
    ];

    if (filterStatus.value != 'All') {
      if (filterStatus.value == 'Refund') {
        // Show only cancelled bookings that can be processed for refund
        list = list.where((item) => item.isCancelledBooking).toList();
      } else if (filterStatus.value == 'Refunded') {
        // Show only already processed refunds
        list = list.where((item) => item.isRefund).toList();
      }
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((item) => item.matchesQuery(query)).toList();
    }

    list.sort((a, b) {
      final priorityA = a.isCancelledBooking ? 0 : 1;
      final priorityB = b.isCancelledBooking ? 0 : 1;
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      return b.sortDate.compareTo(a.sortDate);
    });
    return list;
  }

  String? bankTypeForUser(int userId) {
    final value = _userBankTypes[userId];
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? accountNumberForUser(int userId) {
    final value = _userAccountNumbers[userId];
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Color statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('reject')) return Colors.red;
    if (normalized.contains('approve') ||
        normalized.contains('complete') ||
        normalized.contains('refund')) {
      return Colors.green;
    }
    if (normalized.contains('cancel')) return Colors.orange;
    return Colors.blueGrey;
  }

  String formatCurrency(num amount) {
    return _currencyFormatter.format(amount);
  }

  String formatDate(DateTime date) {
    return _dateFormatter.format(date.toLocal());
  }

  String formatDateTime(DateTime date) {
    return _dateTimeFormatter.format(date.toLocal());
  }

  String formatDateRange(DateTime start, DateTime end) {
    final date = _dateFormatter.format(start.toLocal());
    final timeFormatter = DateFormat('HH:mm', 'id_ID');
    final startTime = timeFormatter.format(start.toLocal());
    final endTime = timeFormatter.format(end.toLocal());
    return '$date, $startTime - $endTime';
  }

  Future<void> submitRefund({
    required FieldadminRefundItem item,
    required num totalRefund,
    required String proofPath,
  }) async {
    final booking = item.booking;
    if (booking == null) {
      Get.snackbar(
        'Cannot be processed',
        'Booking data not found.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    if (isProcessingRefund.value) return;

    try {
      isProcessingRefund.value = true;

      final result = await _refundRepository.createRefund(
        bookingId: booking.id,
        totalRefund: totalRefund,
        proofFile: File(proofPath),
      );

      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      await fetchRefunds();

      final successMessage = result.message.isNotEmpty
          ? result.message
          : 'Refund booking #${booking.id} has been successfully processed.';

      Get.snackbar(
        'Success',
        successMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } on RefundException catch (e) {
      Get.snackbar(
        'Failed to process refund',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } catch (_) {
      Get.snackbar(
        'Failed to process refund',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isProcessingRefund.value = false;
    }
  }

  void _ingestRefundBankInfo(List<RefundModel> items) {
    for (final refund in items) {
      final bank = refund.normalizedBankType;
      final account = refund.normalizedAccountNumber;
      if (bank.isEmpty && account.isEmpty) {
        continue;
      }
      _storeBankInfo(refund.userId, {
        if (bank.isNotEmpty) 'bank_type': bank,
        if (account.isNotEmpty) 'account_number': account,
      });
    }
  }

  Future<void> _prefetchBankInfoForBookings(List<OwnerBooking> bookings) async {
    final userIds = bookings
        .map((booking) => booking.userId)
        .where((userId) => !_hasBankMeta(userId))
        .toSet();

    if (userIds.isEmpty) {
      return;
    }

    await Future.wait(
      userIds.map((userId) async {
        final info = await _refundRepository.getUserBankInfo(userId);
        if (info != null && info.isNotEmpty) {
          _storeBankInfo(userId, info);
        }
      }),
    );
  }

  void _storeBankInfo(int userId, Map<String, String> info) {
    final bank = info['bank_type'];
    final account = info['account_number'];

    if (bank != null && bank.trim().isNotEmpty) {
      _userBankTypes[userId] = bank;
    }

    if (account != null && account.trim().isNotEmpty) {
      _userAccountNumbers[userId] = account;
    }
  }

  bool _hasBankMeta(int userId) {
    final bank = _userBankTypes[userId]?.trim();
    final account = _userAccountNumbers[userId]?.trim();
    return (bank != null && bank.isNotEmpty) ||
        (account != null && account.isNotEmpty);
  }
}

enum FieldadminRefundItemType { refund, cancelledBooking }

class FieldadminRefundItem {
  FieldadminRefundItem._({this.refund, this.booking, required this.type});

  factory FieldadminRefundItem.fromRefund(RefundModel refund) {
    return FieldadminRefundItem._(
      refund: refund,
      type: FieldadminRefundItemType.refund,
    );
  }

  factory FieldadminRefundItem.fromBooking(OwnerBooking booking) {
    return FieldadminRefundItem._(
      booking: booking,
      type: FieldadminRefundItemType.cancelledBooking,
    );
  }

  final RefundModel? refund;
  final OwnerBooking? booking;
  final FieldadminRefundItemType type;

  bool get isRefund => type == FieldadminRefundItemType.refund;
  bool get isCancelledBooking =>
      type == FieldadminRefundItemType.cancelledBooking;

  RefundModel get _refund => refund!;
  OwnerBooking get _booking => booking!;

  String get statusLabel =>
      isRefund ? _refund.statusLabel : _booking.normalizedStatus.label;

  String get statusRaw => isRefund ? _refund.bookingStatus : _booking.status;

  String get customerLabel {
    if (isRefund) return _refund.customerLabel;
    final email = _booking.userEmail.trim();
    if (email.isEmpty || email == '-') {
      return _booking.userName;
    }
    return '${_booking.userName} ($email)';
  }

  String get fieldName => isRefund ? _refund.fieldName : _booking.fieldName;

  String get fieldLocation {
    if (isRefund) return _refund.fieldLocation;
    if (_booking.placeAddress.trim().isNotEmpty) {
      return _booking.placeAddress;
    }
    if (_booking.placeName.trim().isNotEmpty) {
      return _booking.placeName;
    }
    return '-';
  }

  int? get refundId => refund?.id;

  int get bookingId => isRefund ? _refund.bookingId : _booking.id;

  int get userId => isRefund ? _refund.userId : _booking.userId;

  DateTime get sortDate => isRefund ? _refund.createdAt : _booking.updatedAt;

  DateTime get bookingCreatedAt =>
      isRefund ? _refund.bookingCreatedAt : _booking.bookingStart;

  DateTime? get refundCreatedAt =>
      isRefund ? _refund.createdAt : _booking.updatedAt;

  num get refundAmount => isRefund ? _refund.totalRefund : 0;

  num get bookingTotal =>
      isRefund ? _refund.bookingTotalPrice : _booking.totalPrice;

  String? get fieldType {
    final value = isRefund ? _refund.fieldType : _booking.fieldType;
    if (value.trim().isEmpty || value == '-') {
      return null;
    }
    return value;
  }

  String? get fieldOwner => isRefund && _refund.fieldOwnerName.trim().isNotEmpty
      ? _refund.fieldOwnerName
      : null;

  String? get bankType {
    if (!isRefund) return null;
    final value = _refund.normalizedBankType;
    return value.isEmpty ? null : value;
  }

  String? get accountNumber {
    if (!isRefund) return null;
    final value = _refund.normalizedAccountNumber;
    return value.isEmpty ? null : value;
  }

  String? get proofFile =>
      isRefund &&
          _refund.filePhoto != null &&
          _refund.filePhoto!.trim().isNotEmpty
      ? _refund.filePhoto
      : null;

  DateTime? get bookingEnd => isRefund ? null : _booking.bookingEnd;

  bool get canProcessRefund => isCancelledBooking;

  bool matchesQuery(String query) {
    bool contains(String value) => value.toLowerCase().contains(query);

    if (isRefund) {
      return contains(_refund.userName) ||
          contains(_refund.userEmail) ||
          contains(_refund.fieldName) ||
          contains(_refund.placeName) ||
          contains(_refund.normalizedBankType) ||
          contains(_refund.normalizedAccountNumber) ||
          contains('#${_refund.id}'.toLowerCase()) ||
          contains('#${_refund.bookingId}'.toLowerCase());
    }

    return contains(_booking.userName) ||
        contains(_booking.userEmail) ||
        contains(_booking.fieldName) ||
        contains(_booking.placeName) ||
        contains('#${_booking.id}'.toLowerCase()) ||
        contains(_booking.orderId.toLowerCase());
  }
}
