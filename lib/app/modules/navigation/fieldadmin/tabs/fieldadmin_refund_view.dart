import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_refund_controller.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

class FieldadminRefundView extends GetView<FieldadminTransactionController> {
  const FieldadminRefundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        title: const Text('Refund Requests'),
        backgroundColor: AppColors.neutralColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _FilterBar(controller: controller),
            const SizedBox(height: 12),
            Obx(() {
              final warning = controller.bookingWarning.value;
              if (warning.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final error = controller.errorMessage.value;
                if (error.isNotEmpty) {
                  return _ErrorState(
                    message: error,
                    onRetry: () => controller.fetchRefunds(),
                  );
                }

                final items = controller.filteredItems;
                if (items.isEmpty) {
                  return _EmptyState(onRefresh: controller.fetchRefunds);
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchRefunds(showLoading: false),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _RefundCard(item: item);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final FieldadminTransactionController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[50],
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for customers, field, refund ID...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 15),
                onChanged: (val) => controller.searchQuery.value = val,
              ),
            ),
            Container(
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.filterStatus.value,
                    items: controller.statusOptions
                        .map(
                          (status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.filterStatus.value = value;
                      }
                    },
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    icon: const Icon(Icons.arrow_drop_down, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefundCard extends GetView<FieldadminTransactionController> {
  const _RefundCard({required this.item});

  final FieldadminRefundItem item;

  @override
  Widget build(BuildContext context) {
    final isRefund = item.isRefund;
    final statusColor = controller.statusColor(item.statusRaw);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        item.fieldName.isEmpty ? '-' : item.fieldName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.fieldLocation,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            if (isRefund) ...[
              if (item.refundId != null)
                _DetailRow(label: 'Refund ID', value: '#${item.refundId}'),
              _DetailRow(label: 'Booking ID', value: '#${item.bookingId}'),
              _DetailRow(label: 'Customer', value: item.customerLabel),
              _DetailRow(
                label: 'Booking Date',
                value: controller.formatDateTime(item.bookingCreatedAt),
              ),
              if (item.fieldLocation.trim().isNotEmpty &&
                  item.fieldLocation != '-')
                _DetailRow(label: 'Place', value: item.fieldLocation),
              if (item.refundCreatedAt != null)
                _DetailRow(
                  label: 'Refund Date',
                  value: controller.formatDateTime(item.refundCreatedAt!),
                ),
              if (item.fieldType != null)
                _DetailRow(label: 'Field Type', value: item.fieldType!),
              if (item.fieldOwner != null)
                _DetailRow(label: 'Field Owner', value: item.fieldOwner!),
              const SizedBox(height: 12),
              _AmountHighlight(
                title: 'Total Refund',
                primaryAmount: controller.formatCurrency(item.refundAmount),
                subtitle:
                    'Booking Total: ${controller.formatCurrency(item.bookingTotal)}',
              ),
              if (item.proofFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    'Bukti transfer: ${item.proofFile}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
            ] else ...[
              _DetailRow(label: 'Booking ID', value: '#${item.bookingId}'),
              _DetailRow(label: 'Customer', value: item.customerLabel),
              _DetailRow(
                label: 'Booking Time',
                value: item.bookingEnd != null
                    ? controller.formatDateRange(
                        item.bookingCreatedAt,
                        item.bookingEnd!,
                      )
                    : controller.formatDateTime(item.bookingCreatedAt),
              ),
              if (item.fieldLocation.trim().isNotEmpty &&
                  item.fieldLocation != '-')
                _DetailRow(label: 'Place', value: item.fieldLocation),
              if (item.refundCreatedAt != null)
                _DetailRow(
                  label: 'Cancelled At',
                  value: controller.formatDateTime(item.refundCreatedAt!),
                ),
              const SizedBox(height: 12),
              _AmountHighlight(
                title: 'Booking Total',
                primaryAmount: controller.formatCurrency(item.bookingTotal),
                subtitle: 'Refunds have not been processed yet.',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: item.canProcessRefund
                      ? () => _showProcessRefundSheet(context, controller, item)
                      : null,
                  icon: const Icon(Icons.assignment_return),
                  label: const Text('Proses Refund'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AmountHighlight extends StatelessWidget {
  const _AmountHighlight({
    required this.title,
    required this.primaryAmount,
    required this.subtitle,
    this.color,
  });

  final String title;
  final String primaryAmount;
  final String subtitle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Colors.blue;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            primaryAmount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final Future<void> Function({bool showLoading}) onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => onRefresh(showLoading: false),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Center(
            child: Text(
              'No refund data available.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showProcessRefundSheet(
  BuildContext context,
  FieldadminTransactionController controller,
  FieldadminRefundItem item,
) async {
  final amountController = TextEditingController(
    text: item.bookingTotal.round().toString(),
  );
  XFile? selectedFile;
  String? validationError;
  final picker = ImagePicker();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final viewInsets = MediaQuery.of(ctx).viewInsets;
      return Padding(
        padding: EdgeInsets.only(
          bottom: viewInsets.bottom,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickFile(ImageSource source) async {
              final file = await picker.pickImage(source: source);
              if (file != null) {
                setState(() {
                  selectedFile = file;
                  validationError = null;
                });
              }
            }

            Future<void> submit() async {
              final rawText = amountController.text.trim();
              final numericText = rawText.replaceAll(RegExp(r'[^0-9]'), '');
              final total = num.tryParse(numericText);

              if (total == null || total <= 0) {
                setState(() {
                  validationError = 'Please enter a valid refund amount.';
                });
                return;
              }

              if (selectedFile == null) {
                setState(() {
                  validationError = 'Please attach the transfer proof.';
                });
                return;
              }

              validationError = null;

              await controller.submitRefund(
                item: item,
                totalRefund: total,
                proofPath: selectedFile!.path,
              );
            }

            Widget buildInfoRow(String label, String value) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.assignment_return,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Proses Refund',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Booking #${item.bookingId} • ${controller.formatCurrency(item.bookingTotal)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Obx(() {
                        final isLoading = controller.isProcessingRefund.value;
                        return IconButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (Get.isBottomSheetOpen ?? false) {
                                    Get.back();
                                  }
                                },
                          icon: const Icon(Icons.close_rounded),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Summary',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        buildInfoRow('Customer', item.customerLabel),
                        buildInfoRow(
                          'Time',
                          item.bookingEnd != null
                              ? controller.formatDateRange(
                                  item.bookingCreatedAt,
                                  item.bookingEnd!,
                                )
                              : controller.formatDateTime(
                                  item.bookingCreatedAt,
                                ),
                        ),
                        if (item.fieldLocation.trim().isNotEmpty &&
                            item.fieldLocation != '-')
                          buildInfoRow('Location', item.fieldLocation),
                        buildInfoRow(
                          'Total Booking',
                          controller.formatCurrency(item.bookingTotal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nominal Refund',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter the refund amount',
                      prefixText: 'Rp ',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.upload_file_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Prove Transfer',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Upload a photo of proof of transfer as confirmation of refund.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => pickFile(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Select from Gallery'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => pickFile(ImageSource.camera),
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: const Text('Take a Photo'),
                              ),
                            ),
                          ],
                        ),
                        if (selectedFile != null) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 160,
                              width: double.infinity,
                              color: Colors.grey.shade100,
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Image.file(File(selectedFile!.path)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (validationError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      validationError!,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Obx(() {
                    final isLoading = controller.isProcessingRefund.value;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Processing...'),
                                ],
                              )
                            : const Text('Process Refund'),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      );
    },
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    amountController.dispose();
  });
}
