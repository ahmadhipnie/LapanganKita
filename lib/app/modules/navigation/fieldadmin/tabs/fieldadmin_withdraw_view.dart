import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/models/place_model.dart';
import 'package:lapangan_kita/app/data/models/withdraw_model.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_withdraw_controller.dart';
import 'package:image_picker/image_picker.dart';

class FieldadminWithdrawView extends GetView<FieldadminWithdrawController> {
  const FieldadminWithdrawView({super.key});

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
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
                    'Withdraw Requests',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) => c.searchQuery.value = value,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search for owner name or nominal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                Widget chip(String label) {
                  final selected = c.statusFilter.value == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => c.statusFilter.value = label,
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [chip('All'), chip('Pending'), chip('Processed')],
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                final isLoading = c.isLoading.value || c.isLoadingPlaces.value;
                final autoPendingPlaces = c.autoPendingPlaces;
                final pendingWithdraws = c.pendingWithdraws;
                final processed = c.processedWithdraws;
                final minBalanceDisplay = _formatCurrency(
                  c.minimumBalanceThreshold.value,
                );
                final hasAnyData =
                    autoPendingPlaces.isNotEmpty ||
                    pendingWithdraws.isNotEmpty ||
                    processed.isNotEmpty;

                if (isLoading && !hasAnyData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!hasAnyData) {
                  if (c.errorMessage.value.isNotEmpty) {
                    return _ErrorState(
                      message: c.errorMessage.value,
                      onRetry: c.fetchWithdraws,
                    );
                  }
                  if (c.placeError.value.isNotEmpty) {
                    return _ErrorState(
                      message: c.placeError.value,
                      onRetry: c.fetchEligiblePlaces,
                    );
                  }
                  return _EmptyState(
                    onRefresh: c.refreshAll,
                    message:
                        'There is no withdrawal data yet. Fields with a minimum balance of Rp $minBalanceDisplay will automatically appear here.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: c.refreshAll,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (c.errorMessage.value.isNotEmpty)
                        _InfoBanner(
                          message: c.errorMessage.value,
                          icon: Icons.warning_amber_rounded,
                          backgroundColor: const Color(0xFFFFF7ED),
                          iconColor: const Color(0xFFD97706),
                          textColor: const Color(0xFF92400E),
                        ),
                      if (c.placeError.value.isNotEmpty)
                        _InfoBanner(
                          message: c.placeError.value,
                          icon: Icons.info_outline,
                          backgroundColor: const Color(0xFFF0F9FF),
                          iconColor: const Color(0xFF0284C7),
                          textColor: const Color(0xFF075985),
                        ),
                      _SectionHeader(
                        title: 'Waiting Process',
                        count:
                            autoPendingPlaces.length + pendingWithdraws.length,
                        highlightColor: const Color(0xFFFCD34D),
                      ),
                      if (autoPendingPlaces.isEmpty && pendingWithdraws.isEmpty)
                        _SectionPlaceholder(
                          icon: Icons.hourglass_empty_outlined,
                          message:
                              'There is no data waiting for processing. Fields will automatically appear when the balance reaches Rp $minBalanceDisplay.',
                        )
                      else ...[
                        if (autoPendingPlaces.isNotEmpty)
                          ...autoPendingPlaces.map(
                            (place) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _AutoWithdrawCard(
                                place: place,
                                currencyFormatter: _formatCurrency,
                                thresholdAmount:
                                    c.minimumBalanceThreshold.value,
                                isProcessing: c.isAutoProcessing(place.id),
                                onProcess: () =>
                                    _showAutoWithdrawSheet(context, c, place),
                              ),
                            ),
                          ),
                        if (pendingWithdraws.isNotEmpty)
                          ...pendingWithdraws.map(
                            (item) => Obx(() {
                              final processing = c.isProcessing(item.id);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _WithdrawCard(
                                  item: item,
                                  statusColor: const Color(0xFFB45309),
                                  statusLabel: 'Waiting for Proof',
                                  currencyFormatter: _formatCurrency,
                                  onApprove: () =>
                                      _showApproveSheet(context, c, item),
                                  onReject: () =>
                                      _showRejectSheet(context, c, item),
                                  isProcessing: processing,
                                ),
                              );
                            }),
                          ),
                      ],
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: 'Already Processed',
                        count: processed.length,
                        highlightColor: const Color(0xFF34D399),
                      ),
                      if (processed.isEmpty)
                        const _SectionPlaceholder(
                          icon: Icons.check_circle_outline,
                          message:
                              'There are no withdrawals that have been processed yet.',
                        )
                      else
                        ...processed.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _WithdrawCard(
                              item: item,
                              statusColor: const Color(0xFF047857),
                              statusLabel: 'Completed Processing',
                              currencyFormatter: _formatCurrency,
                              onViewProof: item.filePhotoUrl?.isNotEmpty == true
                                  ? () => _showProofDialog(context, item)
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectSheet(
    BuildContext context,
    FieldadminWithdrawController controller,
    WithdrawModel item,
  ) {
    Get.bottomSheet(
      SafeArea(
        child: Obx(() {
          final isProcessing = controller.isProcessing(item.id);
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Reject Withdraw',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to reject the withdrawal request? #${item.id}?',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isProcessing ? null : Get.back,
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: isProcessing
                            ? null
                            : () => controller.rejectRequest(item.id),
                        child: isProcessing
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Reject Withdraw'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showApproveSheet(
    BuildContext context,
    FieldadminWithdrawController controller,
    WithdrawModel item,
  ) {
    Get.bottomSheet(
      SafeArea(
        child: Obx(() {
          final proof = controller.proofImages[item.id];
          final hasProof = proof != null;
          final isProcessing = controller.isProcessing(item.id);
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Proses Withdraw',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unggah bukti transfer untuk withdraw #${item.id}.',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: isProcessing
                        ? null
                        : () => controller.pickProof(item.id),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            color: hasProof
                                ? const Color(0xFF2563EB)
                                : Colors.black26,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hasProof
                                ? 'Ketuk untuk mengganti gambar'
                                : 'Ketuk untuk unggah gambar',
                            style: TextStyle(
                              color: hasProof
                                  ? const Color(0xFF2563EB)
                                  : Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (proof != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(proof.path),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isProcessing ? null : Get.back,
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasProof
                                ? const Color(0xFF2563EB)
                                : Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: hasProof && !isProcessing
                              ? () => controller.approveWithProof(item.id)
                              : null,
                          child: isProcessing
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Konfirmasi Selesai'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showProofDialog(BuildContext context, WithdrawModel item) {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bukti Transfer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (item.filePhotoUrl != null && item.filePhotoUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.filePhotoUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                const Icon(
                  Icons.image_not_supported_outlined,
                  size: 64,
                  color: Colors.black26,
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: Get.back,
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAutoWithdrawSheet(
    BuildContext context,
    FieldadminWithdrawController controller,
    PlaceModel place,
  ) async {
    final amountController = TextEditingController(
      text: place.balance.toString(),
    );
    XFile? selectedFile;
    String? validationError;
    final picker = ImagePicker();

    Future<void> pickFile(
      ImageSource source,
      void Function(void Function()) setState,
    ) async {
      final file = await picker.pickImage(source: source);
      if (file != null) {
        setState(() {
          selectedFile = file;
          validationError = null;
        });
      }
    }

    Future<void> submit(void Function(void Function()) setState) async {
      final raw = amountController.text.trim();
      final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = int.tryParse(digits) ?? 0;
      final minAmount = controller.minimumBalanceThreshold.value;

      if (amount < minAmount) {
        setState(() {
          validationError =
              'Nominal withdraw minimal Rp ${_formatCurrency(minAmount)}.';
        });
        return;
      }

      if (amount > place.balance) {
        setState(() {
          validationError =
              'Nominal tidak boleh melebihi saldo tersedia (${_formatCurrency(place.balance)}).';
        });
        return;
      }

      if (selectedFile == null) {
        setState(() {
          validationError = 'Lampirkan bukti transfer terlebih dahulu.';
        });
        return;
      }

      setState(() {
        validationError = null;
      });

      await controller.submitAutoWithdraw(
        place: place,
        amount: amount,
        proofPath: selectedFile!.path,
      );
    }

    await Get.bottomSheet(
      SafeArea(
        child: StatefulBuilder(
          builder: (context, setState) {
            final inset = MediaQuery.of(context).viewInsets.bottom;
            final minAmount = controller.minimumBalanceThreshold.value;
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: inset),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2563EB,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.payments_rounded,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ajukan Withdraw',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                place.placeName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              if ((place.ownerName ?? '').isNotEmpty)
                                Text(
                                  'Field Manager: ${place.ownerName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (Get.isBottomSheetOpen ?? false) {
                              Get.back();
                            }
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ringkasan Saldo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _summaryRow(
                            label: 'Saldo tersedia',
                            value: 'Rp ${_formatCurrency(place.balance)}',
                          ),
                          _summaryRow(
                            label: 'Minimal penarikan',
                            value: 'Rp ${_formatCurrency(minAmount)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Nominal Withdraw',
                      style: TextStyle(
                        fontSize: 14,
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
                        prefixText: 'Rp ',
                        hintText: 'Masukkan nominal withdraw',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
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
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.upload_file_outlined,
                                color: Color(0xFF2563EB),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Bukti Transfer',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      pickFile(ImageSource.gallery, setState),
                                  icon: const Icon(
                                    Icons.photo_library_outlined,
                                  ),
                                  label: const Text('Dari Galeri'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      pickFile(ImageSource.camera, setState),
                                  icon: const Icon(Icons.photo_camera_outlined),
                                  label: const Text('Ambil Foto'),
                                ),
                              ),
                            ],
                          ),
                          if (selectedFile != null) ...[
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(selectedFile!.path),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
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
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Obx(() {
                      final isProcessing = controller.isAutoProcessing(
                        place.id,
                      );
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () => submit(setState),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isProcessing
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Memproses...'),
                                  ],
                                )
                              : const Text('Kirim Withdraw'),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    amountController.dispose();
  }
}

Widget _summaryRow({required String label, required String value}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.highlightColor,
  });

  final String title;
  final int count;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            color: highlightColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: highlightColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: highlightColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.black26),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh, required this.message});

  final Future<void> Function() onRefresh;
  final String message;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.only(top: 120),
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Colors.black26),
          const SizedBox(height: 12),
          Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
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
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.message,
    this.icon = Icons.info_outline,
    this.backgroundColor = const Color(0xFFF0F9FF),
    this.iconColor = const Color(0xFF0284C7),
    this.textColor = const Color(0xFF075985),
  });

  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }
}

class _AutoWithdrawCard extends StatelessWidget {
  const _AutoWithdrawCard({
    required this.place,
    required this.currencyFormatter,
    required this.thresholdAmount,
    required this.onProcess,
    required this.isProcessing,
  });

  final PlaceModel place;
  final String Function(int) currencyFormatter;
  final int thresholdAmount;
  final VoidCallback onProcess;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final ownerName = place.ownerName?.trim();
    final ownerEmail = place.ownerEmail?.trim();
    final address = place.address.trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.placeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if ((ownerName?.isNotEmpty ?? false) ||
                        (ownerEmail?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 4),
                      if (ownerName != null && ownerName.isNotEmpty)
                        Text(
                          'Field Manager: $ownerName',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (ownerEmail != null && ownerEmail.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          ownerEmail,
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const _StatusChip(
                label: 'Siap diproses',
                color: Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo Tersedia',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${currencyFormatter(place.balance)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Ambang Minimal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${currencyFormatter(thresholdAmount)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Saldo lapangan ini telah mencapai ambang minimal dan otomatis muncul untuk diproses withdraw oleh admin.',
            style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.4),
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: Colors.black26,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isProcessing ? null : onProcess,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isProcessing
                  ? const SizedBox.shrink()
                  : const Icon(Icons.payments_outlined),
              label: isProcessing
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                        Text('Memproses...'),
                      ],
                    )
                  : const Text('Ajukan Withdraw'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawCard extends StatelessWidget {
  const _WithdrawCard({
    required this.item,
    required this.statusColor,
    required this.statusLabel,
    required this.currencyFormatter,
    this.onApprove,
    this.onReject,
    this.onViewProof,
    this.isProcessing = false,
  });

  final WithdrawModel item;
  final Color statusColor;
  final String statusLabel;
  final String Function(int) currencyFormatter;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onViewProof;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.userEmail,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nominal Withdraw',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${currencyFormatter(item.amount)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Diajukan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.formattedDate(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (onApprove != null || onReject != null || onViewProof != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 12),
          ],
          if (onApprove != null && onReject != null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : onReject,
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isProcessing ? null : onApprove,
                    child: isProcessing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Upload Bukti'),
                  ),
                ),
              ],
            )
          else if (onViewProof != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('View Proof of Transfer'),
                onPressed: onViewProof,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
