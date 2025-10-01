import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import 'package:lapangan_kita/app/bindings/edit_field_fieldmanager_binding.dart';
import 'package:lapangan_kita/app/modules/edit_field_fieldmanager/edit_field_fieldmanager_view.dart';
import 'package:lapangan_kita/app/bindings/fieldmanager_withdraw_binding.dart';
import 'package:lapangan_kita/app/modules/fieldmanager_withdraw/fieldmanager_withdraw_view.dart';
import '../tabs_controller/fieldmanager_home_controller.dart';

class FieldManagerHomeView extends GetView<FieldManagerHomeController> {
  const FieldManagerHomeView({super.key});

  // Small helper to render a filter chip and update controller.filterStatus
  Widget _filterChip(FieldManagerHomeController c, String label) {
    final isSelected = c.filterStatus.value == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF2563EB).withOpacity(0.15),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
      ),
      onSelected: (_) => c.filterStatus.value = label,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // Small status chip used on each card (green for available, red for not available)
  Widget _statusChip(dynamic statusRaw) {
    final statusStr = (statusRaw?.toString() ?? '').toLowerCase();
    // Map potential Indonesian values to English labels used in filters
    String label;
    Color color;
    if (statusStr == 'tersedia' || statusStr == 'available') {
      label = 'Available';
      color = const Color(0xFF10B981); // green
    } else if (statusStr == 'tidak tersedia' || statusStr == 'not available') {
      label = 'Not Available';
      color = const Color(0xFFEF4444); // red
    } else {
      label = statusRaw?.toString() ?? 'Unknown';
      color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
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
                Obx(
                  () => Card(
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
                            children: [
                              const Text(
                                'Balance',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rp ${c.balance.value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                                style: const TextStyle(
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
                            onPressed: () async {
                              final res = await Get.to(
                                () => const FieldmanagerWithdrawView(),
                                binding: FieldmanagerWithdrawBinding(),
                                arguments: {'balance': c.balance.value},
                              );
                              if (res is Map && res['withdrawn'] is int) {
                                final w = res['withdrawn'] as int;
                                c.balance.value = (c.balance.value - w).clamp(
                                  0,
                                  1 << 31,
                                );
                              }
                            },
                            child: const Text('Withdraw'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Profit Recap
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Profit Recap',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.bar_chart_rounded,
                            color: Color(0xFF2563EB),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _profitCard(
                              title: 'Today',
                              amount: c.profitToday.value,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _profitCard(
                              title: 'This Week',
                              amount: c.profitWeek.value,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _profitCard(
                              title: 'This Month',
                              amount: c.profitMonth.value,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Transactions',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: const [
                              Icon(
                                Icons.receipt_long_rounded,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final total = c.recentTransactions.length;
                        final limit = 3; // show 2-3 items (choose 3 here)
                        final showAll = c.showAllTransactions.value;
                        final itemCount = showAll
                            ? total
                            : total.clamp(0, limit);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: itemCount,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final t = c.recentTransactions[i];
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(t['title']),
                                  subtitle: Text(t['date']),
                                  trailing: Text(
                                    'Rp ${t['amount'].toString().replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (m) => '.')}',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (total > limit)
                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () =>
                                      c.showAllTransactions.toggle(),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    foregroundColor: const Color(0xFF2563EB),
                                  ),
                                  child: Text(
                                    showAll ? 'View less' : 'View more',
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Divider(height: 32, thickness: 1, color: Colors.grey.shade300),
                // Search + Filters
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search field name...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onChanged: (v) => c.searchQuery.value = v,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          _filterChip(c, 'All'),
                          _filterChip(c, 'Available'),
                          _filterChip(c, 'Not Available'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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
                      onPressed: c.refreshFields,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final list = c.fields.where((f) {
                    final matchesSearch =
                        c.searchQuery.value.isEmpty ||
                        f['name'].toString().toLowerCase().contains(
                          c.searchQuery.value.toLowerCase(),
                        );
                    final status = f['status']?.toString().toLowerCase() ?? '';
                    final mapped = status == 'tersedia'
                        ? 'Available'
                        : (status == 'tidak tersedia'
                              ? 'Not Available'
                              : status);
                    final matchesFilter =
                        c.filterStatus.value == 'All' ||
                        mapped == c.filterStatus.value;
                    return matchesSearch && matchesFilter;
                  }).toList();
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final field = list[i];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (ctx) => Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 40,
                                        height: 4,
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Gambar lapangan di atas
                                    Container(
                                      width: double.infinity,
                                      height: 120,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.asset(
                                        'assets/images/gbk.jpeg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Text(
                                      field['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Tipe: ${field['type']}'),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Open Hour: ${field['openHour']} - ${field['closeHour']}',
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Max Person: ${field['maxPerson']}'),
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
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.edit),
                                            label: const Text('Edit'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFF2563EB,
                                              ),
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                              Get.to(
                                                () =>
                                                    const EditFieldFieldmanagerView(),
                                                binding:
                                                    EditFieldFieldmanagerBinding(),
                                                arguments: field,
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton(
                                            child: const Text('Tutup'),
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/images/gbk.jpeg',
                                    width: 96,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              field['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          _statusChip(field['status']),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        field['type'],
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Rp ${field['price'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}/jam',
                                        style: const TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
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

  Widget _profitCard({
    required String title,
    required int amount,
    required Color color,
  }) {
    String formatted = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.trending_up, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rp $formatted',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
