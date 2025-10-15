import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_field_controller.dart';
import 'package:lapangan_kita/app/data/models/field_model.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';
import 'package:lapangan_kita/app/data/network/api_client.dart';

class FieldadminFieldView extends GetView<FieldadminFieldController> {
  const FieldadminFieldView({super.key});

  static String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400&h=300&fit=crop';
    }
    if (imagePath.startsWith('http')) return imagePath;
    
    String cleanPath = imagePath;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    
    return '${ApiClient.baseUrlWithoutApi}/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        title: const Text('Field Approval'),
        backgroundColor: AppColors.neutralColor,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.isNotEmpty) {
                  return _ErrorState(
                    message: controller.errorMessage.value,
                    onRetry: controller.fetchFields,
                  );
                }

                final fields = controller.filteredFields;
                if (fields.isEmpty) {
                  return _EmptyState(onRefresh: controller.refreshFields);
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshFields,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: fields.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final field = fields[index];
                      return _FieldCard(
                        field: field,
                        onApprove: () => _showApproveDialog(context, field),
                        onReject: () => _showRejectDialog(context, field),
                        onDetail: () => _showDetailDialog(context, field),
                      );
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

  Widget _buildSearchBar() {
    return Column(
      children: [
        Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.grey[50],
          child: SizedBox(
            height: 52,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search field name, address, or owner...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 15),
              onChanged: (val) => controller.searchQuery.value = val,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: controller.filterStatus.value == 'All',
                onTap: () => controller.filterStatus.value = 'All',
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Pending',
                isSelected: controller.filterStatus.value == 'pending',
                onTap: () => controller.filterStatus.value = 'pending',
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Approved',
                isSelected: controller.filterStatus.value == 'approved',
                onTap: () => controller.filterStatus.value = 'approved',
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Rejected',
                isSelected: controller.filterStatus.value == 'rejected',
                onTap: () => controller.filterStatus.value = 'rejected',
                color: Colors.red,
              ),
            ],
          ),
        )),
      ],
    );
  }

  void _showDetailDialog(BuildContext context, FieldModel field) {
    final photoUrl = field.fieldPhoto != null && field.fieldPhoto!.isNotEmpty
        ? _getImageUrl(field.fieldPhoto!)
        : null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Field Details'),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (photoUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photoUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _DetailRow(label: 'Field Name', value: field.fieldName),
                _DetailRow(label: 'Type', value: _formatFieldType(field.fieldType)),
                _DetailRow(label: 'Price/Hour', value: controller.formatCurrency(field.pricePerHour)),
                _DetailRow(label: 'Max Person', value: field.maxPerson.toString()),
                _DetailRow(label: 'Opening Time', value: field.openingTime),
                _DetailRow(label: 'Closing Time', value: field.closingTime),
                _DetailRow(label: 'Status', value: field.status),
                _DetailRow(label: 'Verification', value: _formatVerificationStatus(field.isVerifiedAdmin)),
                const Divider(height: 20),
                if (field.placeName != null)
                  _DetailRow(label: 'Place', value: field.placeName!),
                if (field.placeAddress != null)
                  _DetailRow(label: 'Address', value: field.placeAddress!),
                if (field.placeOwnerName != null)
                  _DetailRow(label: 'Owner', value: field.placeOwnerName!),
                const Divider(height: 20),
                _DetailRow(
                  label: 'Created',
                  value: controller.formatDate(field.createdAt),
                ),
                _DetailRow(
                  label: 'Updated',
                  value: controller.formatDate(field.updatedAt),
                ),
                if (field.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    field.description,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context, FieldModel field) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Field'),
        content: Text(
          'Are you sure you want to approve field "${field.fieldName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.approveField(field);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, FieldModel field) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Field'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reject field "${field.fieldName}"?'),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for rejection',
                  hintText: 'Enter the reason...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a reason.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop();
                controller.rejectField(field, reasonController.text.trim());
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatFieldType(String type) {
    switch (type.toLowerCase()) {
      case 'futsal':
        return 'Futsal';
      case 'badminton':
        return 'Badminton';
      case 'tennis':
        return 'Tennis';
      case 'basket':
      case 'basketball':
        return 'Basketball';
      default:
        return type;
    }
  }

  String _formatVerificationStatus(String? status) {
    final normalized = (status ?? 'pending').toLowerCase();
    switch (normalized) {
      case 'approved':
        return 'Approved ✓';
      case 'rejected':
        return 'Rejected ✗';
      case 'pending':
      default:
        return 'Pending ⏳';
    }
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.field,
    required this.onApprove,
    required this.onReject,
    required this.onDetail,
  });

  final FieldModel field;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final photoUrl = field.fieldPhoto != null && field.fieldPhoto!.isNotEmpty
        ? FieldadminFieldView._getImageUrl(field.fieldPhoto!)
        : null;
    
    final verificationStatus = (field.isVerifiedAdmin ?? 'pending').toLowerCase();
    final statusColor = _getStatusColor(verificationStatus);
    final statusLabel = _getStatusLabel(verificationStatus);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onDetail,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: photoUrl != null
                        ? Image.network(
                            photoUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                field.fieldName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor, width: 1),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatFieldType(field.fieldType),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (field.placeAddress != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            field.placeAddress!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoRow(
                      icon: Icons.attach_money,
                      label: 'Price',
                      value: 'Rp ${_formatNumber(field.pricePerHour)}',
                    ),
                  ),
                  Expanded(
                    child: _InfoRow(
                      icon: Icons.people_outline,
                      label: 'Max',
                      value: '${field.maxPerson} people',
                    ),
                  ),
                ],
              ),
              if (field.placeOwnerName != null)
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Owner',
                  value: field.placeOwnerName!,
                ),
              if (field.placeName != null)
                _InfoRow(
                  icon: Icons.stadium_outlined,
                  label: 'Place',
                  value: field.placeName!,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verificationStatus == 'approved'
                            ? Colors.grey
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: verificationStatus == 'approved' ? null : onApprove,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verificationStatus == 'rejected'
                            ? Colors.grey
                            : Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: verificationStatus == 'rejected' ? null : onReject,
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'APPROVED';
      case 'rejected':
        return 'REJECTED';
      case 'pending':
      default:
        return 'PENDING';
    }
  }

  String _formatFieldType(String type) {
    switch (type.toLowerCase()) {
      case 'futsal':
        return 'Futsal';
      case 'badminton':
        return 'Badminton';
      case 'tennis':
        return 'Tennis';
      case 'basket':
      case 'basketball':
        return 'Basketball';
      default:
        return type;
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
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

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.stadium_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Center(
            child: Text(
              'No field data available.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Colors.blue;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
