import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_transaction_controller.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

class FieldadminTransactionView
    extends GetView<FieldadminTransactionController> {
  const FieldadminTransactionView({super.key});

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
                          hintText: 'Search customer/field/refund ID...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 0,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 15),
                        onChanged: (val) => controller.searchQuery.value = val,
                      ),
                    ),
                    // FIXED: Wrap only the reactive part with Obx
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
                      child: Obx(
                        () => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.filterStatus.value,
                            items: const [
                              DropdownMenuItem(
                                value: 'All',
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: 'Pending',
                                child: Text('Pending'),
                              ),
                              DropdownMenuItem(
                                value: 'Approved',
                                child: Text('Approved'),
                              ),
                              DropdownMenuItem(
                                value: 'Rejected',
                                child: Text('Rejected'),
                              ),
                            ],
                            onChanged: (val) =>
                                controller.filterStatus.value = val ?? 'All',
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

            // Refunds List - FIXED: Obx hanya wrap bagian yang perlu reactive
            Expanded(
              child: Obx(() {
                final filteredRefunds = controller.filteredRefunds.toList();

                return filteredRefunds.isEmpty
                    ? const Center(child: Text('No refund requests'))
                    : ListView.separated(
                        itemCount: filteredRefunds.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final refund = filteredRefunds[index];
                          return _buildRefundCard(context, refund);
                        },
                      );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundCard(BuildContext context, Map<String, dynamic> refund) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field Info and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        refund['field_name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        refund['field_location'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // FIXED: Status color menggunakan controller method langsung
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: controller
                        .statusColor(refund['status'])
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    refund['status'],
                    style: TextStyle(
                      color: controller.statusColor(refund['status']),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Refund Details
            _buildDetailRow('Refund ID', refund['refund_id']),
            _buildDetailRow('Booking ID', refund['id']),
            _buildDetailRow('Customer', refund['customer_name']),
            _buildDetailRow('Booking Date', refund['booking_date']),
            _buildDetailRow('Refund Date', refund['refund_date']),
            _buildDetailRow(
              'Bank',
              '${refund['bank_name']} - ${refund['account_number']}',
            ),

            const SizedBox(height: 8),
            // Refund Notes
            Text(
              'Notes: ${refund['refund_notes']}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 12),
            // Total Refund
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Refund:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    controller.formatCurrency(refund['total_refund']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            // Refund Button (only for pending status)
            if (refund['status'] == 'Pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showRefundModal(context, refund),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(
                    Icons.payment,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Process Refund',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _showRefundModal(BuildContext context, Map<String, dynamic> refund) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _RefundBottomSheet(refund: refund),
    );
  }
}

// FIXED: Pisahkan bottom sheet menjadi widget terpisah untuk manage state dengan benar
class _RefundBottomSheet extends GetView<FieldadminTransactionController> {
  final Map<String, dynamic> refund;

  const _RefundBottomSheet({required this.refund});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Process Refund',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Refund ID: ${refund['refund_id']}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Upload Proof Section - FIXED: Gunakan Obx yang tepat
          _buildUploadSection(context),

          const SizedBox(height: 20),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.selectedImagePath.value.isEmpty
                        ? null // Disable jika belum upload image
                        : () => _confirmRefund(context, refund),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      'Confirm Refund',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Transfer Proof',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showImageSourceDialog(context),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Obx(() {
              final imagePath = controller.selectedImagePath.value;

              if (imagePath.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to upload image',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                );
              } else {
                return Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 40,
                            color: Colors.green[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image selected',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            imagePath.split('/').last,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: controller.clearSelectedImage,
                      ),
                    ),
                  ],
                );
              }
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload proof of bank transfer for this refund',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: const Text('Choose how you want to upload the image'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      controller.setSelectedImage(pickedFile.path);
    }
  }

  void _confirmRefund(BuildContext context, Map<String, dynamic> refund) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Refund'),
        content: const Text('Are you sure you want to process this refund?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateRefundStatus(
                refund['refund_id'],
                'Approved',
                controller.selectedImagePath.value,
              );
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refund processed successfully')),
              );
              controller.clearSelectedImage();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
