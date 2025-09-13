import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../tabs_controller/fieldmanager_booking_controller.dart';

class FieldManagerBookingView extends StatelessWidget {
  const FieldManagerBookingView({super.key});

  void showBookingDetail(BuildContext context, Map<String, dynamic> b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Detail Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${b['customer']}'),
            Text('Lapangan: ${b['field']}'),
            Text('Tanggal: ${b['date']}'),
            Text('Jam: ${b['start']} - ${b['end']}'),
            Text('Status: ${b['status']}'),
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

  void confirmAction(
    BuildContext context,
    FieldManagerBookingController c,
    int id,
    String action,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${action == 'Diterima' ? 'ACC' : 'Tolak'} Booking'),
        content: Text(
          'Yakin ingin ${action == 'Diterima' ? 'menerima' : 'menolak'} booking ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              c.updateStatus(id, action);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Booking ${action == 'Diterima' ? 'diterima' : 'ditolak'}',
                  ),
                ),
              );
            },
            child: Text(action == 'Diterima' ? 'ACC' : 'Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(FieldManagerBookingController());
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
                              value: 'Menunggu',
                              child: Text('Menunggu'),
                            ),
                            DropdownMenuItem(
                              value: 'Diterima',
                              child: Text('Diterima'),
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
              child: c.filteredBookings.isEmpty
                  ? const Center(child: Text('Tidak ada booking'))
                  : ListView.separated(
                      itemCount: c.filteredBookings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final b = c.filteredBookings[i];
                        return GestureDetector(
                          onTap: () => showBookingDetail(context, b),
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
                                  const SizedBox(height: 12),
                                  if (b['status'] == 'Menunggu')
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            onPressed: () => confirmAction(
                                              context,
                                              c,
                                              b['id'],
                                              'Diterima',
                                            ),
                                            child: const Text(
                                              'ACC',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () => confirmAction(
                                              context,
                                              c,
                                              b['id'],
                                              'Ditolak',
                                            ),
                                            child: const Text(
                                              'Tolak',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
