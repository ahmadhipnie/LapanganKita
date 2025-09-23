import 'package:get/get.dart';

class FieldadminWithdrawController extends GetxController {
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
  ].obs;
}
