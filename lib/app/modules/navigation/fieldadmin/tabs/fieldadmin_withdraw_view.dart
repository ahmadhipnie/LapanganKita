
import 'dart:io';
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Approved':
        bg = const Color(0xFFE6F4EA);
        fg = const Color(0xFF1B5E20);
        break;
      case 'Rejected':
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFB71C1C);
        break;
      default:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFBF360C);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: const [
                  Icon(
                    Icons.request_quote_rounded,
                    size: 24,
                    color: Color(0xFF2563EB),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Withdraw Request',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => c.searchQuery.value = v,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search by manager/method/details',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                Widget chip(String label) {
                  final selected = c.statusFilter.value == label;
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => c.statusFilter.value = label,
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      chip('All'),
                      const SizedBox(width: 8),
                      chip('Pending'),
                      const SizedBox(width: 8),
                      chip('Approved'),
                      const SizedBox(width: 8),
                      chip('Rejected'),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            // List
            Expanded(
              child: Obx(() {
                final base = List<Map<String, dynamic>>.from(c.requests);
                final filter = c.statusFilter.value;
                final statusFiltered = filter == 'All'
                    ? base
                    : base
                          .where((e) => (e['status'] as String?) == filter)
                          .toList();
                final q = c.searchQuery.value.trim().toLowerCase();
                final list = q.isEmpty
                    ? statusFiltered
                    : statusFiltered.where((e) {
                        final manager =
                            e['managerName']?.toString().toLowerCase() ?? '';
                        final amountStr =
                            (e['amount'] as int?)?.toString() ?? '';
                        final method =
                            e['method']?.toString().toLowerCase() ?? '';
                        final details = (e['details'] as Map?) ?? {};
                        final detailsStr = details.values
                            .map((v) => v?.toString().toLowerCase() ?? '')
                            .join(' ');
                        return manager.contains(q) ||
                            amountStr.contains(q) ||
                            method.contains(q) ||
                            detailsStr.contains(q);
                      }).toList();

                const order = {'Pending': 0, 'Approved': 1, 'Rejected': 2};
                list.sort((a, b) {
                  final sa = order[a['status']] ?? 3;
                  final sb = order[b['status']] ?? 3;
                  if (sa != sb) return sa.compareTo(sb);
                  return (a['id'] as int).compareTo(b['id'] as int);
                });

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.inbox_outlined,
                          size: 40,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No withdraw requests found',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemBuilder: (context, index) {
                    final r = list[index];
                    final id = r['id'] as int;
                    final status = r['status'] as String? ?? 'Pending';
                    final amount = r['amount'] as int? ?? 0;
                    final method = r['method'] as String? ?? '-';
                    final createdAt = r['createdAt'] as String? ?? '-';
                    final details = Map<String, dynamic>.from(
                      r['details'] as Map,
                    );

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r['managerName']?.toString() ?? '-',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${_formatCurrency(amount)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _statusChip(status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 12),
                          _infoRow('Method', method),
                          _infoRow('Created', createdAt),
                          if (method == 'Bank') ...[
                            _infoRow(
                              'Bank Name',
                              details['bankName']?.toString() ?? '-',
                            ),
                            _infoRow(
                              'Account Number',
                              details['accountNumber']?.toString() ?? '-',
                            ),
                            _infoRow(
                              'Account Holder',
                              details['accountHolder']?.toString() ?? '-',
                            ),
                          ] else if (method == 'Digital Wallet') ...[
                            _infoRow(
                              'Provider',
                              details['walletProvider']?.toString() ?? '-',
                            ),
                            _infoRow(
                              'Wallet Number',
                              details['walletNumber']?.toString() ?? '-',
                            ),
                            _infoRow(
                              'Wallet Name',
                              details['walletName']?.toString() ?? '-',
                            ),
                          ] else ...[
                            _infoRow(
                              'Method Name',
                              details['methodName']?.toString() ?? '-',
                            ),
                            _infoRow(
                              'Identifier',
                              details['identifier']?.toString() ?? '-',
                            ),
                          ],
                          const SizedBox(height: 12),
                          if (status == 'Pending')
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Get.bottomSheet(
                                        SafeArea(
                                          child: SingleChildScrollView(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(
                                                context,
                                              ).viewInsets.bottom,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                    child: Container(
                                                      width: 44,
                                                      height: 4,
                                                      margin:
                                                          const EdgeInsets.only(
                                                            bottom: 12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black12,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              2,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Confirm Rejection',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    'Are you sure you want to reject withdraw #$id?',
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: OutlinedButton(
                                                          onPressed: () =>
                                                              Get.back(),
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                            foregroundColor:
                                                                Colors.white,
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 14,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                          ),
                                                          onPressed: () =>
                                                              c.rejectRequest(
                                                                id,
                                                              ),
                                                          child: const Text(
                                                            'Confirm Reject',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Reject'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      Get.bottomSheet(
                                        SafeArea(
                                          child: SingleChildScrollView(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(
                                                context,
                                              ).viewInsets.bottom,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                ),
                                              ),
                                              child: Obx(() {
                                                final proof = c.proofImages[id];
                                                final isReady = proof != null;
                                                return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Center(
                                                      child: Container(
                                                        width: 44,
                                                        height: 4,
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 12,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black12,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                2,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Process Withdraw',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      'Withdraw ID: #$id',
                                                      style: const TextStyle(
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    const Text(
                                                      'Upload Transfer Proof',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          c.pickProof(id),
                                                      child: Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 24,
                                                              horizontal: 16,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color:
                                                                Colors.black12,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .cloud_upload_outlined,
                                                              color: Color(
                                                                0xFF2563EB,
                                                              ),
                                                              size: 32,
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            Text(
                                                              proof == null
                                                                  ? 'Tap to upload image'
                                                                  : 'Tap to replace image',
                                                              style: const TextStyle(
                                                                color: Color(
                                                                  0xFF2563EB,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if (proof != null) ...[
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        child: Image.file(
                                                          File(proof.path),
                                                          height: 160,
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    const SizedBox(height: 8),
                                                    const Text(
                                                      'Upload proof of bank transfer for this withdraw',
                                                      style: TextStyle(
                                                        color: Colors.black45,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: OutlinedButton(
                                                            onPressed: () =>
                                                                Get.back(),
                                                            child: const Text(
                                                              'Cancel',
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  isReady
                                                                  ? const Color(
                                                                      0xFF2563EB,
                                                                    )
                                                                  : Colors.grey,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        14,
                                                                  ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                            ),
                                                            onPressed: isReady
                                                                ? () => c
                                                                      .approveWithProof(
                                                                        id,
                                                                      )
                                                                : null,
                                                            child: const Text(
                                                              'Confirm Approve',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              }),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Approve'),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: list.length,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

