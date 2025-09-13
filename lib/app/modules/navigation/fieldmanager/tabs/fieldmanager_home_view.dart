import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class FieldManagerHomeView extends StatelessWidget {
  FieldManagerHomeView({super.key});

  final List<Map<String, dynamic>> dummyFields = [
    {
      'name': 'Lapangan Futsal A',
      'type': 'Futsal',
      'price': 150000,
      'status': 'Tersedia',
    },
    {
      'name': 'Lapangan Badminton B',
      'type': 'Badminton',
      'price': 100000,
      'status': 'Tersedia',
    },
    {
      'name': 'Lapangan Basket C',
      'type': 'Basket',
      'price': 200000,
      'status': 'Tidak Tersedia',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Greeting
                const Text(
                  'Hi, Budi Pengelola',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 20),
                // Balance Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  color: const Color(0xFF2563EB),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Balance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Rp 2.500.000',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Get.snackbar(
                              'Withdraw',
                              'Fitur withdraw coming soon!',
                            );
                          },
                          child: const Text('Withdraw'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Data Lapangan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Field List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF2563EB)),
                      onPressed: () {
                        Get.snackbar('Refresh', 'Data dummy di-refresh!');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dummyFields.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final field = dummyFields[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: ListTile(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(field['name']),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tipe: ${field['type']}'),
                                  const SizedBox(height: 8),
                                  Text('Harga per Jam: Rp${field['price']}'),
                                  const SizedBox(height: 8),
                                  Text('Status: ${field['status']}'),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  const Text('Deskripsi:'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lapangan ${field['name']} adalah lapangan ${field['type']} yang nyaman dan berkualitas.',
                                  ),
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
                        },
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF2563EB),
                          child: Text(
                            field['type'][0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(field['name']),
                        subtitle: Text(
                          '${field['type']} • Rp${field['price']}/jam',
                        ),
                        trailing: Text(
                          field['status'],
                          style: TextStyle(
                            color: field['status'] == 'Tersedia'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Field', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Get.toNamed(AppRoutes.FIELD_ADD);
        },
      ),
    );
  }
}
