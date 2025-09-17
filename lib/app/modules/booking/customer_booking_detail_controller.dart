import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lapangan_kita/app/modules/booking/customer_booking_controller.dart';

class CustomerBookingDetailController extends GetxController {
  final Court court = Get.arguments;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedDuration = '1'.obs;
  final RxString selectedStartTime = ''.obs;
  final RxDouble totalPrice = 0.0.obs;
  final RxMap<String, int> selectedEquipment = <String, int>{}.obs;

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
    ever(selectedDuration, (_) {
      selectedStartTime.value = ''; // Reset waktu saat durasi berubah
    });
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

    totalPrice.value = basePrice + equipmentPrice;
  }

  void bookNow() {
    if (selectedStartTime.value.isEmpty) {
      Get.snackbar('Error', 'Please select start time');
      return;
    }

    // Logic booking disini
    Get.toNamed(
      '/booking-confirmation',
      arguments: {
        'court': court,
        'date': selectedDate.value,
        'startTime': selectedStartTime.value,
        'duration': selectedDuration.value,
        'equipment': selectedEquipment,
        'totalPrice': totalPrice.value,
      },
    );
  }
}
