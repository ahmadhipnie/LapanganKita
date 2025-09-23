import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_withdraw_controller.dart';

class FieldadminWithdrawView extends GetView<FieldadminWithdrawController> {
  const FieldadminWithdrawView({super.key});

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Withdraw Request',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(
                () => c.requests.isEmpty
                    ? const Center(child: Text('No withdraw requests'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: c.requests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final r = c.requests[i];
                          final method = (r['method'] ?? '').toString();
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        r['managerName'] ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Pending',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _infoRow(
                                    'Requested at',
                                    r['createdAt'] ?? '-',
                                  ),
                                  _infoRow(
                                    'Amount',
                                    'Rp ${_formatCurrency(r['amount'] ?? 0)}',
                                  ),
                                  _infoRow('Method', method),
                                  const Divider(height: 24),
                                  if (method == 'Bank') ...[
                                    _infoRow(
                                      'Bank',
                                      r['details']?['bankName'] ?? '-',
                                    ),
                                    _infoRow(
                                      'Account Number',
                                      r['details']?['accountNumber'] ?? '-',
                                    ),
                                    _infoRow(
                                      'Account Holder',
                                      r['details']?['accountHolder'] ?? '-',
                                    ),
                                  ] else if (method == 'Digital Wallet') ...[
                                    _infoRow(
                                      'Provider',
                                      r['details']?['walletProvider'] ?? '-',
                                    ),
                                    _infoRow(
                                      'Wallet Number',
                                      r['details']?['walletNumber'] ?? '-',
                                    ),
                                    _infoRow(
                                      'Wallet Name',
                                      r['details']?['walletName'] ?? '-',
                                    ),
                                  ] else ...[
                                    _infoRow(
                                      'Method Name',
                                      r['details']?['methodName'] ?? '-',
                                    ),
                                    _infoRow(
                                      'Identifier',
                                      r['details']?['identifier'] ?? '-',
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            // TODO: implement reject flow
                                            Get.snackbar(
                                              'Reject',
                                              'Request #${r['id']} rejected',
                                            );
                                          },
                                          child: const Text('Reject'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2563EB,
                                            ),
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            // TODO: implement approve flow
                                            Get.snackbar(
                                              'Approve',
                                              'Request #${r['id']} approved',
                                            );
                                          },
                                          child: const Text('Approve'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
