import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'fieldmanager_history_controller.dart';

class FieldManagerHistoryView extends StatelessWidget {
  const FieldManagerHistoryView({super.key});

  void showHistoryDetail(
    BuildContext context,
    Map<String, dynamic> b,
    FieldManagerHistoryController c,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Detail Riwayat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${b['customer']}'),
            Text('Lapangan: ${b['field']}'),
            Text('Tanggal: ${b['date']}'),
            Text('Jam: ${b['start']} - ${b['end']}'),
            Text('Status: ${b['status']}'),
            Text('Total: Rp${b['total']}'),
            Text('Pembayaran: ${b['payment']}'),
            const SizedBox(height: 8),
            const Divider(),
            const Text('Catatan:'),
            const SizedBox(height: 4),
            Text('Tidak ada catatan khusus.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(FieldManagerHistoryController());
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey[50],
            child: SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari customer/lapangan...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 0,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 15),
                      onChanged: (val) => c.searchQuery.value = val,
                    ),
                  ),
                  Obx(
                    () => Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: c.filterStatus.value,
                          items: const [
                            DropdownMenuItem(
                              value: 'Semua',
                              child: Text('Semua'),
                            ),
                            DropdownMenuItem(
                              value: 'Selesai',
                              child: Text('Selesai'),
                            ),
                            DropdownMenuItem(
                              value: 'Batal',
                              child: Text('Batal'),
                            ),
                            DropdownMenuItem(
                              value: 'Ditolak',
                              child: Text('Ditolak'),
                            ),
                          ],
                          onChanged: (val) =>
                              c.filterStatus.value = val ?? 'Semua',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          icon: const Icon(Icons.arrow_drop_down, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Expanded(
              child: c.filteredHistory.isEmpty
                  ? const Center(child: Text('Belum ada riwayat booking'))
                  : ListView.separated(
                      itemCount: c.filteredHistory.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final b = c.filteredHistory[i];
                        return GestureDetector(
                          onTap: () => showHistoryDetail(context, b, c),
                          child: Card(
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
                                        b['field'],
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
                                          color: c
                                              .statusColor(b['status'])
                                              .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          b['status'],
                                          style: TextStyle(
                                            color: c.statusColor(b['status']),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Customer: ${b['customer']}'),
                                  Text('Tanggal: ${b['date']}'),
                                  Text('Jam: ${b['start']} - ${b['end']}'),
                                  Text('Total: Rp${b['total']}'),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
