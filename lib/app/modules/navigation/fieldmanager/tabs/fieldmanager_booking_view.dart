import 'package:flutter/material.dart';

class FieldManagerBookingView extends StatefulWidget {
  const FieldManagerBookingView({super.key});

  @override
  State<FieldManagerBookingView> createState() =>
      _FieldManagerBookingViewState();
}

class _FieldManagerBookingViewState extends State<FieldManagerBookingView> {
  // Dummy data
  List<Map<String, dynamic>> bookings = [
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
  ];

  String filterStatus = 'Semua';
  String searchQuery = '';
  // bool showCalendar = false;

  void updateStatus(int id, String newStatus) {
    setState(() {
      final idx = bookings.indexWhere((b) => b['id'] == id);
      if (idx != -1) bookings[idx]['status'] = newStatus;
    });
  }

  void confirmAction(int id, String action) {
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
              updateStatus(id, action);
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

  void showBookingDetail(Map<String, dynamic> b) {
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

  List<Map<String, dynamic>> get filteredBookings {
    List<Map<String, dynamic>> list = bookings;
    if (filterStatus != 'Semua') {
      list = list.where((b) => b['status'] == filterStatus).toList();
    }
    if (searchQuery.isNotEmpty) {
      list = list
          .where(
            (b) =>
                b['customer'].toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                b['field'].toLowerCase().contains(searchQuery.toLowerCase()),
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

  @override
  Widget build(BuildContext context) {
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
                      onChanged: (val) => setState(() => searchQuery = val),
                    ),
                  ),
                  Container(
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
                        value: filterStatus,
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
                            setState(() => filterStatus = val ?? 'Semua'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredBookings.isEmpty
                ? const Center(child: Text('Tidak ada booking'))
                : ListView.separated(
                    itemCount: filteredBookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final b = filteredBookings[i];
                      return GestureDetector(
                        onTap: () => showBookingDetail(b),
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
                                        color: statusColor(
                                          b['status'],
                                        ).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        b['status'],
                                        style: TextStyle(
                                          color: statusColor(b['status']),
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
                                          onPressed: () =>
                                              confirmAction(b['id'], 'Ditolak'),
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
        ],
      ),
    );
  }
}
