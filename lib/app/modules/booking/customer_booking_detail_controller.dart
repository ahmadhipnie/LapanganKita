import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/customer/booking/court_model.dart';
import '../../data/models/add_on_model.dart';
import '../../data/repositories/add_on_repository.dart';
// import '../../services/local_storage_service.dart';

class CustomerBookingDetailController extends GetxController {
  final Court court = Get.arguments;
  // final LocalStorageService _storageService = LocalStorageService.instance;
  final AddOnRepository _addOnRepository = Get.find<AddOnRepository>();

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedDuration = '1'.obs;
  final RxString selectedStartTime = ''.obs;
  final RxDouble totalPrice = 0.0.obs;
  final RxMap<String, int> selectedEquipment = <String, int>{}.obs;
  final RxMap<String, int> selectedAddOns = <String, int>{}.obs;
  final RxList<AddOnModel> availableAddOns = <AddOnModel>[].obs;
  final RxBool isLoadingAddOns = false.obs;
  final RxBool isRefreshingAddOns = false.obs;

  final List<String> durationOptions = ['1', '2', '3', '4', '5', '6'];
  final List<String> availableTimes = [
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
  ];

  @override
  void onInit() {
    super.onInit();
    _calculateTotalPrice();
    _loadAddOns();
    ever(selectedDuration, (_) {
      selectedStartTime.value = ''; // Reset waktu saat durasi berubah
    });
  }

  Future<void> _loadAddOns() async {
    isLoadingAddOns.value = true;
    try {
      final addOns = await _addOnRepository.getAddOnsByPlace(
        placeId: court.placeId,
      );
      availableAddOns.assignAll(addOns);
    } catch (e) {
      print('Error loading add-ons: $e');
    } finally {
      isLoadingAddOns.value = false;
    }
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

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedStartTime.value = ''; // Reset waktu saat ganti tanggal
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

  // Cek apakah waktu dan durasi berikutnya tersedia
  bool isTimeAvailableWithDuration(String startTime, int duration) {
    final startIndex = availableTimes.indexOf(startTime);
    if (startIndex == -1) return false;

    // Cek apakah semua slot waktu untuk durasi yang diminta tersedia
    for (int i = 0; i < duration; i++) {
      if (startIndex + i >= availableTimes.length) return false;

      final timeSlot = availableTimes[startIndex + i];
      if (!isTimeAvailable(timeSlot)) {
        return false;
      }
    }

    return true;
  }

  // Cek apakah waktu tertentu termasuk dalam range yang dipilih
  bool isTimeInSelectedRange(String time) {
    if (selectedStartTime.value.isEmpty) return false;

    final selectedIndex = availableTimes.indexOf(selectedStartTime.value);
    final currentIndex = availableTimes.indexOf(time);
    final duration = int.parse(selectedDuration.value);

    if (selectedIndex == -1 || currentIndex == -1) return false;

    return currentIndex >= selectedIndex &&
        currentIndex < selectedIndex + duration;
  }

  // Method original untuk cek availability per jam
  bool isTimeAvailable(String time) {
    // Logic untuk cek availability berdasarkan tanggal dan waktu
    // Ini bisa diintegrasikan dengan API nanti
    // Contoh dummy: jam 18:00-20:00 sudah dipesan
    final busyTimes = ['18:00', '19:00', '20:00'];
    return !busyTimes.contains(time);
  }

  // Equipment methods
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

  // Add-on methods
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

    // Calculate equipment price
    double equipmentPrice = 0;
    selectedEquipment.forEach((name, quantity) {
      final equipment = court.equipment.firstWhere(
        (e) => e.name == name,
        orElse: () => Equipment(name: name, price: 0, description: ''),
      );
      equipmentPrice += equipment.price * quantity;
    });

    // Calculate add-on price
    double addOnPrice = 0;
    selectedAddOns.forEach((name, quantity) {
      if (quantity > 0) {
        final addOn = availableAddOns.firstWhere(
          (a) => a.name == name,
          orElse: () => AddOnModel(
            id: 0,
            name: name,
            pricePerHour: 0,
            stock: 0,
            description: '',
          ),
        );
        addOnPrice += addOn.pricePerHour * quantity;
      }
    });

    totalPrice.value = basePrice + equipmentPrice + addOnPrice;
  }

  void bookNow() {
    if (selectedStartTime.value.isEmpty) {
      Get.snackbar('Error', 'Please select start time');
      return;
    }

    try {
      // Generate booking ID
      // final bookingId = 'BK${DateTime.now().millisecondsSinceEpoch}';

      // Hitung total equipment price
      selectedEquipment.forEach((name, quantity) {
        if (quantity > 0) {
          court.equipment.firstWhere(
            (e) => e.name == name,
            orElse: () => Equipment(name: name, price: 0, description: ''),
          );
        }
      });

      // Hitung total add-on price
      selectedAddOns.forEach((name, quantity) {
        if (quantity > 0) {
          availableAddOns.firstWhere(
            (a) => a.name == name,
            orElse: () => AddOnModel(
              id: 0,
              name: name,
              pricePerHour: 0,
              stock: 0,
              description: '',
            ),
          );
        }
      });

      // // Buat booking history
      // final bookingHistory = BookingHistory(
      //   id: court.id,
      //   courtName: court.name,
      //   courtImageUrl: court.imageUrl,
      //   location: court.location,
      //   date: selectedDate.value,
      //   startTime: selectedStartTime.value,
      //   duration: int.parse(selectedDuration.value),
      //   totalAmount: totalPrice.value,
      //   status: 'pending',
      //   equipment: Map.from(selectedEquipment),
      //   addOns: Map.from(selectedAddOns), // Tambahkan add-ons
      //   courtPrice: court.price,
      //   equipmentTotal: equipmentTotal,
      //   addOnTotal: addOnTotal, // Tambahkan add-on total
      //   types: court.types,
      // );

      // Simpan ke history controller
      // final historyController = Get.find<CustomerHistoryController>();
      // historyController.addBooking(bookingHistory);

      // Redirect ke halaman history
      Get.offAllNamed('/customer/navigation', arguments: {'initialTab': 3});

      // Get.snackbar(
      //   'Success',
      //   'Booking created successfully. ID: $bookingId',
      //   snackPosition: SnackPosition.TOP,
      //   duration: const Duration(seconds: 3),
      // );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create booking: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
