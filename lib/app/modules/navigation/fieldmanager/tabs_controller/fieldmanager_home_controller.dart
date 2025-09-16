import 'package:get/get.dart';

class FieldManagerHomeController extends GetxController {
  RxList<Map<String, dynamic>> fields = <Map<String, dynamic>>[
    {
      'name': 'Lapangan Futsal A',
      'type': 'Futsal',
      'price': 150000,
      'status': 'Tersedia',
      'openHour': '08:00',
      'closeHour': '22:00',
      'description': 'Lapangan futsal dengan rumput sintetis',
      'maxPerson': 10,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Lapangan Badminton B',
      'type': 'Badminton',
      'price': 100000,
      'status': 'Tersedia',
      'openHour': '07:00',
      'closeHour': '21:00',
      'description': 'Lapangan badminton indoor',
      'maxPerson': 4,
      'imageUrl': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Lapangan Basket C',
      'type': 'Basket',
      'price': 200000,
      'status': 'Tidak Tersedia',
      'openHour': '09:00',
      'closeHour': '20:00',
      'description': 'Lapangan basket standar nasional',
      'maxPerson': 10,
      'imageUrl': 'https://via.placeholder.com/150',
    },
  ].obs;

  RxInt balance = 2500000.obs;

  void refreshFields() {
    // Dummy refresh, bisa diisi logic fetch data dari API
    Get.snackbar('Refresh', 'Data dummy di-refresh!');
  }
}
