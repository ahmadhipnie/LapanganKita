import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class FieldadminWithdrawController extends GetxController {
  // UI state: search & status filter
  final RxString searchQuery = ''.obs;
  final RxString statusFilter =
      'All'.obs; // All | Pending | Approved | Rejected
  // Selected proof images per request id
  final RxMap<int, XFile?> proofImages = <int, XFile?>{}.obs;
  // Dummy list of withdraw requests from field managers
  // In a real app this would be fetched from an API/service
  final requests = <Map<String, dynamic>>[
    {
      'id': 1,
      'managerName': 'Budi Pengelola',
      'amount': 350000,
      'method': 'Bank',
      'details': {
        'bankName': 'BCA',
        'accountNumber': '0123456789',
        'accountHolder': 'Budi Santoso',
      },
      'createdAt': '2025-09-22 10:15',
      'status': 'Pending',
    },
    {
      'id': 2,
      'managerName': 'Sari Pengelola',
      'amount': 200000,
      'method': 'Digital Wallet',
      'details': {
        'walletProvider': 'OVO',
        'walletNumber': '081234567890',
        'walletName': 'Sari Wulandari',
      },
      'createdAt': '2025-09-22 11:00',
      'status': 'Pending',
    },
    {
      'id': 3,
      'managerName': 'Agus Pengelola',
      'amount': 150000,
      'method': 'Other',
      'details': {'methodName': 'Cash', 'identifier': 'On-site'},
      'createdAt': '2025-09-22 12:30',
      'status': 'Pending',
    },
    {
      'id': 4,
      'managerName': 'Rina Pengelola',
      'amount': 420000,
      'method': 'Bank',
      'details': {
        'bankName': 'Mandiri',
        'accountNumber': '9876543210',
        'accountHolder': 'Rina Amelia',
      },
      'createdAt': '2025-09-21 09:20',
      'status': 'Approved',
    },
    {
      'id': 5,
      'managerName': 'Dodi Pengelola',
      'amount': 275000,
      'method': 'Digital Wallet',
      'details': {
        'walletProvider': 'GoPay',
        'walletNumber': '081298765432',
        'walletName': 'Dodi Pratama',
      },
      'createdAt': '2025-09-20 14:05',
      'status': 'Rejected',
    },
  ].obs;

  Future<void> pickProof(int id) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      proofImages[id] = image;
    }
  }

  void approveWithProof(int id) {
    final proof = proofImages[id];
    if (proof == null) {
      Get.snackbar('Proof required', 'Please upload transfer proof');
      return;
    }
    final idx = requests.indexWhere((e) => e['id'] == id);
    if (idx != -1) {
      final updated = Map<String, dynamic>.from(requests[idx]);
      updated['status'] = 'Approved';
      updated['proofPath'] = proof.path;
      requests[idx] = updated;
    }
    Get.back();
    Get.snackbar('Approve', 'Request #$id approved');
  }

  void rejectRequest(int id) {
    final idx = requests.indexWhere((e) => e['id'] == id);
    if (idx != -1) {
      final updated = Map<String, dynamic>.from(requests[idx]);
      updated['status'] = 'Rejected';
      requests[idx] = updated;
    }
    Get.back();
    Get.snackbar('Reject', 'Request #$id rejected');
  }
}
