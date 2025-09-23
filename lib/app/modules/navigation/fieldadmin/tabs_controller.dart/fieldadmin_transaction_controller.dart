import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FieldadminTransactionController extends GetxController {
  RxList<Map<String, dynamic>> refunds = <Map<String, dynamic>>[
    {
      'id': 'REF-001',
      'refund_id': 'RFD-2025001',
      'field_name': 'Lapangan Futsal A',
      'field_location': 'Jl. Merdeka No. 123, Jakarta',
      'customer_name': 'Andi Wijaya',
      'booking_date': '2025-09-15',
      'refund_date': '2025-09-10',
      'bank_name': 'BCA',
      'account_number': '1234-5678-9012',
      'refund_notes': 'Lapangan sedang renovasi',
      'total_refund': 250000,
      'status': 'Pending', // Pending, Approved, Rejected
      'proof_image': null,
    },
    {
      'id': 'REF-002',
      'refund_id': 'RFD-2025002',
      'field_name': 'Lapangan Badminton B',
      'field_location': 'Jl. Sudirman No. 45, Bandung',
      'customer_name': 'Siti Rahma',
      'booking_date': '2025-09-16',
      'refund_date': '2025-09-11',
      'bank_name': 'Mandiri',
      'account_number': '9876-5432-1000',
      'refund_notes': 'Jadwal bentrok dengan acara mendadak',
      'total_refund': 150000,
      'status': 'Pending',
      'proof_image': null,
    },
    {
      'id': 'REF-003',
      'refund_id': 'RFD-2025003',
      'field_name': 'Lapangan Basket C',
      'field_location': 'Jl. Gatot Subroto No. 67, Surabaya',
      'customer_name': 'Budi Santoso',
      'booking_date': '2025-09-17',
      'refund_date': '2025-09-12',
      'bank_name': 'BRI',
      'account_number': '5555-8888-9999',
      'refund_notes': 'Pemain tidak cukup',
      'total_refund': 300000,
      'status': 'Approved',
      'proof_image': 'https://example.com/proof1.jpg',
    },
  ].obs;

  RxString filterStatus = 'All'.obs;
  RxString searchQuery = ''.obs;
  var selectedImagePath = ''.obs;

  Iterable<Map<String, dynamic>> get filteredRefunds {
    Iterable<Map<String, dynamic>> list = refunds.toList();

    // Status filter
    if (filterStatus.value != 'All') {
      list = list.where((r) => r['status'] == filterStatus.value).toList();
    }

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      list = list.where(
        (r) =>
            r['customer_name'].toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ) ||
            r['field_name'].toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ) ||
            r['refund_id'].toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
      );
    }

    // Sort by refund date descending (newest first)
    list = list.toList()
      ..sort((a, b) {
        if (a['status'] == 'Pending' && b['status'] == 'Approved') return -1;
        if (a['status'] == 'Approved' && b['status'] == 'Pending') return 1;
        return 0;
      });

    return list;
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default: // Pending
        return Colors.orange;
    }
  }

  void updateRefundStatus(
    String refundId,
    String newStatus,
    String? imagePath,
  ) {
    final index = refunds.indexWhere((r) => r['refund_id'] == refundId);
    if (index != -1) {
      refunds[index]['status'] = newStatus;
      if (imagePath != null) {
        refunds[index]['proof_image'] = imagePath;
      }
      refunds.refresh();
    }
  }

  void setSelectedImage(String path) {
    selectedImagePath.value = path;
  }

  void clearSelectedImage() {
    selectedImagePath.value = '';
  }

  // Format currency
  String formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
