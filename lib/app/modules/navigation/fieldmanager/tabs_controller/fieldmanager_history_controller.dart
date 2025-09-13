import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FieldManagerHistoryController extends GetxController {
  RxString filterStatus = 'Semua'.obs;
  RxString searchQuery = ''.obs;

  RxList<Map<String, dynamic>> history = <Map<String, dynamic>>[
    {
      'id': 1,
      'customer': 'Andi Wijaya',
      'field': 'Lapangan Futsal A',
      'date': '2025-09-10',
      'start': '14:00',
      'end': '16:00',
      'status': 'Selesai',
      'total': 300000,
      'payment': 'Transfer',
    },
    {
      'id': 2,
      'customer': 'Siti Rahma',
      'field': 'Lapangan Badminton B',
      'date': '2025-09-09',
      'start': '09:00',
      'end': '11:00',
      'status': 'Batal',
      'total': 0,
      'payment': '-',
    },
    {
      'id': 3,
      'customer': 'Budi Santoso',
      'field': 'Lapangan Basket C',
      'date': '2025-09-08',
      'start': '19:00',
      'end': '21:00',
      'status': 'Ditolak',
      'total': 0,
      'payment': '-',
    },
  ].obs;

  List<Map<String, dynamic>> get filteredHistory {
    var list = history.toList();
    if (filterStatus.value != 'Semua') {
      list = list.where((b) => b['status'] == filterStatus.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      list = list
          .where(
            (b) =>
                b['customer'].toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                b['field'].toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
          )
          .toList();
    }
    list.sort((a, b) => b['date'].compareTo(a['date']));
    return list;
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Batal':
        return Colors.red;
      case 'Ditolak':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
