import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FieldManagerBookingController extends GetxController {
  RxList<Map<String, dynamic>> bookings = <Map<String, dynamic>>[
    {
      'id': 1,
      'customer': 'Andi Wijaya',
      'field': 'Lapangan Futsal A',
      'date': '2025-09-15',
      'start': '14:00',
      'end': '16:00',
      'status': 'Menunggu',
    },
    {
      'id': 2,
      'customer': 'Siti Rahma',
      'field': 'Lapangan Badminton B',
      'date': '2025-09-16',
      'start': '09:00',
      'end': '11:00',
      'status': 'Menunggu',
    },
    {
      'id': 3,
      'customer': 'Budi Santoso',
      'field': 'Lapangan Basket C',
      'date': '2025-09-17',
      'start': '19:00',
      'end': '21:00',
      'status': 'Diterima',
    },
    {
      'id': 4,
      'customer': 'Dewi Lestari',
      'field': 'Lapangan Futsal A',
      'date': '2025-09-18',
      'start': '10:00',
      'end': '12:00',
      'status': 'Ditolak',
    },
  ].obs;

  RxString filterStatus = 'Semua'.obs;
  RxString searchQuery = ''.obs;

  List<Map<String, dynamic>> get filteredBookings {
    var list = bookings.toList();
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
    // Sort by date ascending, then by start time
    list.sort((a, b) {
      int cmp = a['date'].compareTo(b['date']);
      if (cmp == 0) {
        return a['start'].compareTo(b['start']);
      }
      return cmp;
    });
    return list;
  }

  void updateStatus(int id, String newStatus) {
    final idx = bookings.indexWhere((b) => b['id'] == id);
    if (idx != -1) bookings[idx]['status'] = newStatus;
    bookings.refresh();
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Diterima':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
