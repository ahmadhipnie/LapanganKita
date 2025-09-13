import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FieldManagerHomeController extends GetxController {
  RxList<Map<String, dynamic>> fields = <Map<String, dynamic>>[
    {
      'name': 'Lapangan Futsal A',
      'type': 'Futsal',
      'price': 150000,
      'status': 'Tersedia',
    },
    {
      'name': 'Lapangan Badminton B',
      'type': 'Badminton',
      'price': 100000,
      'status': 'Tersedia',
    },
    {
      'name': 'Lapangan Basket C',
      'type': 'Basket',
      'price': 200000,
      'status': 'Tidak Tersedia',
    },
  ].obs;

  RxInt balance = 2500000.obs;

  void refreshFields() {
    // Dummy refresh, bisa diisi logic fetch data dari API
    Get.snackbar('Refresh', 'Data dummy di-refresh!');
  }
}
