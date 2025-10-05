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
      selectedColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.6)),
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
                _heroSection(context, c),
                const SizedBox(height: 24),
                _profitOverview(c),
                const SizedBox(height: 28),
                _placeManagementSection(c),
                const SizedBox(height: 28),
                Divider(height: 32, thickness: 1, color: Colors.grey.shade300),
                const SizedBox(height: 24),
                _fieldManagementSection(context, c),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: Obx(() {
      //   final hasPlace = c.hasPlace.value;
      //   return FloatingActionButton.extended(
      //     backgroundColor: const Color(0xFF2563EB),
      //     icon: Icon(
      //       hasPlace ? Icons.add : Icons.add_business,
      //       color: Colors.white,
      //     ),
      //     label: Text(
      //       hasPlace ? 'Add Field' : 'Register Place',
      //       style: const TextStyle(color: Colors.white),
      //     ),
      //     onPressed: () {
      //       if (hasPlace) {
      //         _showCreateOptions(context, c);
      //       } else {
      //         Get.toNamed(AppRoutes.PLACE_FORM);
      //       }
      //     },
      //   );
      // }),
    );
  }

  Widget _heroSection(BuildContext context, FieldManagerHomeController c) {
    Color heroColor = const Color(0xFF2563EB);
    return Obx(() {
      final place = c.place.value;
      final hasPlace = c.hasPlace.value;
      final placeName = place?.placeName ?? 'LapanganKita Partner';
      final subtitle = hasPlace
          ? (place?.address.isNotEmpty == true
                ? place!.address
                : 'Complete your address so that customers can easily find you.')
          : 'Start registering your place to receive your first booking.';

      final totalFields = c.fields.length;
      final availableFields = c.fields.where((f) {
        final status = f['status']?.toString().toLowerCase() ?? '';
        return status == 'tersedia' || status == 'available';
      }).length;
      final unavailableFields = totalFields - availableFields;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [heroColor, heroColor.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: heroColor.withValues(alpha: 0.2),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
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
                        'Hello, $placeName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasPlace)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: heroColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    icon: const Icon(Icons.south_west, size: 18),
                    label: const Text('Withdraw Balance'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatCurrency(c.balance.value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!hasPlace) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: heroColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Get.toNamed(AppRoutes.PLACE_FORM),
                        icon: const Icon(Icons.add_business, size: 18),
                        label: const Text('Register Your Place'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _heroMetric(
                    icon: Icons.apartment_rounded,
                    label: 'Fields Total',
                    value: totalFields.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _heroMetric(
                    icon: Icons.check_circle_rounded,
                    label: 'Available',
                    value: availableFields.toString(),
                    iconColor: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _heroMetric(
                    icon: Icons.pause_circle_filled,
                    label: 'Inactive',
                    value: unavailableFields.toString(),
                    iconColor: const Color(0xFFF97316),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _heroMetric({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _profitOverview(FieldManagerHomeController c) {
    return Obx(() {
      final today = c.profitToday.value;
      final week = c.profitWeek.value;
      final month = c.profitMonth.value;
      final transactions = c.recentTransactions.toList();
      const limit = 3;
      final showAll = c.showAllTransactions.value;
      final visibleTransactions = showAll
          ? transactions
          : transactions.take(limit).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Performance Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Icon(Icons.bar_chart_rounded, color: Color(0xFF2563EB)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _profitSummaryTile(
                        label: 'Today',
                        amount: today,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _profitSummaryTile(
                        label: 'This Week',
                        amount: week,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _profitSummaryTile(
                        label: 'This Month',
                        amount: month,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Recent Transaction History',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 12),
                if (visibleTransactions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Text(
                      'There are no recorded transactions yet.\nAttract customers by adding schedules and promotions.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visibleTransactions.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        itemBuilder: (_, index) {
                          final transaction = visibleTransactions[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              transaction['title'] ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              transaction['date'] ?? '-',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              _formatCurrency(
                                int.tryParse(
                                      transaction['amount']?.toString() ?? '',
                                    ) ??
                                    0,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          );
                        },
                      ),
                      if (transactions.length > limit)
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: c.showAllTransactions.toggle,
                            child: Text(showAll ? 'Show Less' : 'Show All'),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _placeManagementSection(FieldManagerHomeController c) {
    return Obx(() {
      final isLoading = c.isLoadingPlace.value;
      final errorMessage = c.placeError.value;
      final hasPlace = c.hasPlace.value;
      final place = c.place.value;
      final totalFields = c.fields.length;
      final availableFields = c.fields.where((f) {
        final status = f['status']?.toString().toLowerCase() ?? '';
        return status == 'tersedia' || status == 'available';
      }).length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Place Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Icon(Icons.home_work_rounded, color: Color(0xFF2563EB)),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            _placeLoadingCard()
          else if (errorMessage.isNotEmpty)
            _placeErrorCard(errorMessage, c)
          else if (!hasPlace)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No place registered yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete the place profile to unlock field and add-on management.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Get.toNamed(AppRoutes.PLACE_FORM),
                    icon: const Icon(Icons.add_business, color: Colors.white),
                    label: const Text(
                      'Register Place',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          else if (place != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: place.placePhoto != null
                            ? Image.network(
                                place.placePhoto!,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _placePlaceholder(),
                              )
                            : _placePlaceholder(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.placeName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    place.address,
                                    style: const TextStyle(
                                      color: Color(0xFF4B5563),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _placeBadge(
                                  icon: Icons.sports_soccer,
                                  label: '$totalFields fields',
                                ),
                                _placeBadge(
                                  icon: Icons.check_circle_outline,
                                  label: '$availableFields active',
                                ),
                                _placeBadge(
                                  icon: Icons.account_circle_outlined,
                                  label: place.ownerName ?? 'PIC not set',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final result = await Get.toNamed(
                              AppRoutes.PLACE_EDIT,
                              arguments: place,
                            );

                            if (result is Map && result['updated'] == true) {
                              final message =
                                  result['message']?.toString().trim() ?? '';

                              await c.fetchPlacesForOwner();

                              Get.snackbar(
                                'Berhasil',
                                message.isNotEmpty
                                    ? message
                                    : 'Data tempat berhasil diperbarui.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Manage Place',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            side: const BorderSide(color: Color(0xFF2563EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _navigateToAddField(c),
                          icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                          label: const Text(
                            'Add Field',
                            style: TextStyle(color: Color(0xFF2563EB)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _placeLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }

  Widget _placeErrorCard(String message, FieldManagerHomeController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.error_outline, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text(
                'Unable to load place data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Color(0xFF7F1D1D))),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: c.fetchPlacesForOwner,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4B5563)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placePlaceholder() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFF9CA3AF),
        size: 32,
      ),
    );
  }

  Widget _fieldManagementSection(
    BuildContext context,
    FieldManagerHomeController c,
  ) {
    return Obx(() {
      final allFields = c.fields.toList();
      final hasPlace = c.hasPlace.value;
      final isLoadingFields = c.isLoadingFields.value;
      final fieldsError = c.fieldsError.value;

      final availableCount = allFields.where((f) {
        final status = f['status']?.toString().toLowerCase() ?? '';
        return status == 'tersedia' || status == 'available';
      }).length;

      final filteredFields = allFields.where((field) {
        final name = field['name']?.toString().toLowerCase() ?? '';
        final matchesSearch =
            c.searchQuery.value.isEmpty ||
            name.contains(c.searchQuery.value.toLowerCase());

        final rawStatus = field['status']?.toString() ?? '';
        final normalizedStatus = rawStatus.toLowerCase();
        final mappedStatus = normalizedStatus == 'tersedia'
            ? 'Available'
            : normalizedStatus == 'tidak tersedia'
            ? 'Not Available'
            : rawStatus.isEmpty
            ? 'Unknown'
            : rawStatus;
        final matchesFilter =
            c.filterStatus.value == 'All' ||
            mappedStatus.toLowerCase() == c.filterStatus.value.toLowerCase();
        return matchesSearch && matchesFilter;
      }).toList();

      final unavailableCount = allFields.length - availableCount;

      Widget bodyContent;
      if (isLoadingFields) {
        bodyContent = _fieldsLoadingState();
      } else if (fieldsError.isNotEmpty) {
        bodyContent = _fieldsErrorState(fieldsError, c);
      } else if (allFields.isEmpty) {
        if (hasPlace) {
          final placeName = c.place.value?.placeName ?? 'Place';
          bodyContent = _emptyFieldState(
            title: 'No fields registered yet',
            description:
                '$placeName is ready to accept bookings. Add your first field now.',
            actionLabel: 'Add Field',
            onAction: () => _navigateToAddField(c),
          );
        } else {
          bodyContent = _emptyFieldState(
            title: 'Start by registering a place',
            description:
                'Fields will appear here after you add a place and complete its details.',
            actionLabel: 'Register Place',
            onAction: () => Get.toNamed(AppRoutes.PLACE_FORM),
          );
        }
      } else if (filteredFields.isEmpty) {
        bodyContent = _emptyFieldState(
          title: 'No fields found',
          description:
              'Clear the search keyword or change the status filter to explore other data.',
        );
      } else {
        bodyContent = Column(
          children: [
            for (final field in filteredFields)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _fieldCard(context, c, field),
              ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Field Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Tooltip(
                      message: hasPlace
                          ? 'Create a new field'
                          : 'Register your place before adding fields.',
                      child: SizedBox(
                        height: 40,
                        child: TextButton.icon(
                          onPressed: hasPlace
                              ? () => _navigateToAddField(c)
                              : null,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            disabledForegroundColor: const Color(0xFF9CA3AF),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Field'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        onPressed: c.refreshFields,
                        icon: const Icon(
                          Icons.refresh,
                          color: Color(0xFF2563EB),
                        ),
                        tooltip: 'Refresh data',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (allFields.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for a field name...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onChanged: (value) => c.searchQuery.value = value,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _filterChip(c, 'All'),
                      _filterChip(c, 'Available'),
                      _filterChip(c, 'Not Available'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _fieldSummaryChip(
                        icon: Icons.layers_outlined,
                        label: 'Total Fields',
                        value: allFields.length.toString(),
                      ),
                      _fieldSummaryChip(
                        icon: Icons.check_circle_outline,
                        label: 'Available',
                        value: availableCount.toString(),
                        chipColor: const Color(0xFFDCFCE7),
                        iconColor: const Color(0xFF16A34A),
                      ),
                      _fieldSummaryChip(
                        icon: Icons.pause_circle_outline,
                        label: 'Inactive',
                        value: unavailableCount.toString(),
                        chipColor: const Color(0xFFFFEDD5),
                        iconColor: const Color(0xFFEA580C),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  bodyContent,
                ],
              ),
            )
          else
            bodyContent,
        ],
      );
    });
  }

  Widget _fieldSummaryChip({
    required IconData icon,
    required String label,
    required String value,
    Color chipColor = const Color(0xFFE5E7EB),
    Color iconColor = const Color(0xFF4B5563),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldCard(
    BuildContext context,
    FieldManagerHomeController c,
    Map<String, dynamic> field,
  ) {
    final price = int.tryParse(field['price']?.toString() ?? '') ?? 0;
    final type = field['type']?.toString() ?? '-';
    final name = field['name']?.toString() ?? '-';
    final status = field['status'];

    Widget imageWidget;
    if (field['photo'] != null && field['photo'].toString().isNotEmpty) {
      imageWidget = Image.network(
        field['photo'].toString(),
        width: 96,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/onboarding1.jpg',
          width: 96,
          height: 72,
          fit: BoxFit.cover,
        ),
      );
    } else {
      imageWidget = Image.asset(
        'assets/images/onboarding1.jpg',
        width: 96,
        height: 72,
        fit: BoxFit.cover,
      );
    }

    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showFieldDetailBottomSheet(context, field),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageWidget,
              ),
              const SizedBox(width: 16),
              Expanded(
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
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _statusChip(status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${field['openHour'] ?? '-'} - ${field['closeHour'] ?? '-'}',
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Max ${field['maxPerson'] ?? '-'} people',
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_formatCurrency(price)}/hour',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) async {
                            if (value == 'detail') {
                              _showFieldDetailBottomSheet(context, field);
                            } else if (value == 'edit') {
                              final result = await Get.to(
                                () => const EditFieldFieldmanagerView(),
                                binding: EditFieldFieldmanagerBinding(),
                                arguments: field,
                              );

                              if (result is Map) {
                                if (result['deleted'] == true) {
                                  final message =
                                      result['message']?.toString().trim() ??
                                      '';

                                  await c.fetchFieldsForPlace(force: true);

                                  Get.snackbar(
                                    'Berhasil',
                                    message.isNotEmpty
                                        ? message
                                        : 'Data lapangan berhasil dihapus.',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                if (result['updated'] == true) {
                                  final message =
                                      result['message']?.toString().trim() ??
                                      '';

                                  await c.fetchFieldsForPlace(force: true);

                                  Get.snackbar(
                                    'Berhasil',
                                    message.isNotEmpty
                                        ? message
                                        : 'Data lapangan berhasil diperbarui.',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'detail',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.visibility_outlined),
                                title: Text('View details'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.edit_outlined),
                                title: Text('Edit field'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFieldDetailBottomSheet(
    BuildContext context,
    Map<String, dynamic> field,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child:
                      field['photo'] != null &&
                          field['photo'].toString().isNotEmpty
                      ? Image.network(
                          field['photo'].toString(),
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/onboarding2.jpg',
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/onboarding2.jpg',
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  field['name']?.toString() ?? '-',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _detailRow('Field Type', field['type']),
                _detailRow(
                  'Operating Hours',
                  '${field['openHour'] ?? '-'} - ${field['closeHour'] ?? '-'}',
                ),
                _detailRow(
                  'Maximum Capacity',
                  '${field['maxPerson'] ?? '-'} people',
                ),
                _detailRow(
                  'Rental Price',
                  _formatCurrency(
                    int.tryParse(field['price']?.toString() ?? '') ?? 0,
                  ),
                ),
                _detailRow('Status', field['status']),
                _detailRow('Description', field['description']),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final result = await Get.to(
                            () => const EditFieldFieldmanagerView(),
                            binding: EditFieldFieldmanagerBinding(),
                            arguments: field,
                          );

                          if (result is Map) {
                            if (result['deleted'] == true) {
                              final message =
                                  result['message']?.toString().trim() ?? '';

                              await controller.fetchFieldsForPlace(force: true);

                              Get.snackbar(
                                'Berhasil',
                                message.isNotEmpty
                                    ? message
                                    : 'Data lapangan berhasil dihapus.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (result['updated'] == true) {
                              final message =
                                  result['message']?.toString().trim() ?? '';

                              await controller.fetchFieldsForPlace(force: true);

                              Get.snackbar(
                                'Berhasil',
                                message.isNotEmpty
                                    ? message
                                    : 'Data lapangan berhasil diperbarui.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'Edit Field',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _fieldsLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }

  Widget _fieldsErrorState(String message, FieldManagerHomeController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.error_outline, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text(
                'Unable to load field data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Color(0xFF7F1D1D))),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: c.refreshFields,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profitSummaryTile({
    required String label,
    required int amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(amount),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    return 'Rp $formatted';
  }

  void _navigateToAddField(FieldManagerHomeController c) {
    if (!c.hasPlace.value) {
      Get.snackbar(
        'Register place first',
        'Please register your place before adding fields.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    Get.toNamed(AppRoutes.FIELD_ADD);
  }

  // void _showCreateOptions(BuildContext context, FieldManagerHomeController c) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //     ),
  //     builder: (ctx) {
  //       return SafeArea(
  //         child: Padding(
  //           padding: const EdgeInsets.all(24),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 'Quick Actions',
  //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
  //               ),
  //               const SizedBox(height: 16),
  //               ListTile(
  //                 contentPadding: EdgeInsets.zero,
  //                 leading: const CircleAvatar(
  //                   backgroundColor: Color(0xFF2563EB),
  //                   child: Icon(Icons.layers_outlined, color: Colors.white),
  //                 ),
  //                 title: const Text('Add Field'),
  //                 subtitle: const Text(
  //                   'Complete new field data so customers can start booking it.',
  //                 ),
  //                 onTap: () {
  //                   Navigator.of(ctx).pop();
  //                   _navigateToAddField(c);
  //                 },
  //               ),
  //               const Divider(height: 24),
  //               ListTile(
  //                 contentPadding: EdgeInsets.zero,
  //                 leading: const CircleAvatar(
  //                   backgroundColor: Color(0xFFF59E0B),
  //                   child: Icon(
  //                     Icons.store_mall_directory_outlined,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //                 title: const Text('Manage Place Profile'),
  //                 subtitle: const Text(
  //                   'Update your place information, photos, and add-ons.',
  //                 ),
  //                 onTap: () {
  //                   Navigator.of(ctx).pop();
  //                   Get.toNamed(AppRoutes.PLACE_FORM);
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _emptyFieldState({
    required String title,
    required String description,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
