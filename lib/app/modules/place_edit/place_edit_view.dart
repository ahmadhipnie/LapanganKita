import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/add_on_model.dart';
import 'place_edit_controller.dart';

class PlaceEditView extends GetView<PlaceEditController> {
  const PlaceEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 450,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildPlaceFormCard(context),
                  const SizedBox(height: 16),
                  _buildAddOnsCard(context),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Text(
          'Edit Place',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Update place details and available add-ons.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFE5E7EB), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPlaceFormCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Place Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              _buildPhotoSection(context),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Place Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Text(
                'Address',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.streetController,
                decoration: const InputDecoration(
                  labelText: 'Street',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.provinceController,
                decoration: const InputDecoration(
                  labelText: 'Province',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final File? selected = controller.selectedPhoto.value;
      final String? initialUrl = controller.resolvedInitialPhotoUrl;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Place Photo',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _buildPhotoPreview(file: selected, url: initialUrl),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: controller.pickPlaceImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  selected != null ||
                          (initialUrl != null && initialUrl.isNotEmpty)
                      ? 'Change Photo'
                      : 'Upload Photo',
                ),
              ),
              const SizedBox(width: 12),
              if (selected != null)
                TextButton(
                  onPressed: controller.removeSelectedImage,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                  ),
                  child: const Text('Delete'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'New photo will replace the old photo when changes are saved.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPhotoPreview({File? file, String? url}) {
    if (file != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.file(file, fit: BoxFit.cover),
        ),
      );
    }

    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _photoPlaceholder(),
          ),
        ),
      );
    }

    return _photoPlaceholder();
  }

  Widget _photoPlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_outlined, size: 40, color: Color(0xFF9CA3AF)),
              SizedBox(height: 6),
              Text(
                'No photo yet',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddOnsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildAddOnsSection(context),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final isSubmitting = controller.isSubmitting.value;

      return SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: isSubmitting
              ? null
              : () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await controller.submit();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      );
    });
  }

  Widget _buildAddOnsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Add-Ons',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            Obx(() {
              final isCreating = controller.isCreatingAddOn.value;
              return ElevatedButton.icon(
                onPressed: isCreating
                    ? null
                    : () => _showCreateAddOnSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: isCreating
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(isCreating ? 'Processing...' : 'Add Add-On'),
              );
            }),
            const SizedBox(width: 8),
            Obx(
              () => IconButton(
                tooltip: 'Refresh',
                onPressed: controller.isLoadingAddOns.value
                    ? null
                    : () => controller.fetchAddOnsForPlace(),
                icon: const Icon(Icons.refresh),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoadingAddOns.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.addOnError.value.isNotEmpty) {
            return _buildAddOnFeedbackCard(
              context,
              message: controller.addOnError.value,
              icon: Icons.error_outline,
              iconColor: Colors.redAccent,
              actionLabel: 'Try Again',
              onAction: () => controller.fetchAddOnsForPlace(),
            );
          }

          if (controller.addOns.isEmpty) {
            return _buildAddOnFeedbackCard(
              context,
              message: 'No add-ons registered for this place yet.',
              icon: Icons.inventory_2_outlined,
              iconColor: const Color(0xFF9CA3AF),
            );
          }

          return Column(
            children: controller.addOns
                .map(
                  (addOn) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAddOnCard(context, addOn),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildAddOnFeedbackCard(
    BuildContext context, {
    required String message,
    required IconData icon,
    Color? iconColor,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? theme.primaryColor),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF4B5563),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddOnCard(BuildContext context, AddOnModel addOn) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (addOn.photo != null && addOn.photo!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  addOn.photo!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _addOnPhotoPlaceholder(),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          addOn.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatCurrency(addOn.price)} ${addOn.category == "per hour" ? "/ hour" : ""}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stock: ${addOn.stock}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    addOn.description.isNotEmpty
                        ? addOn.description
                        : 'Description not available.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(() {
                      final isUpdating = controller.isAddOnUpdating(addOn.id);
                      final isDeleting = controller.isAddOnDeleting(addOn.id);
                      return Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            icon: isUpdating
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF2563EB),
                                          ),
                                    ),
                                  )
                                : const Icon(Icons.edit, size: 18),
                            label: Text(isUpdating ? 'Saving...' : 'Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(color: Color(0xFF2563EB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: (isUpdating || isDeleting)
                                ? null
                                : () => _showEditAddOnSheet(context, addOn),
                          ),
                          TextButton.icon(
                            onPressed: isDeleting
                                ? null
                                : () => _confirmDeleteAddOn(context, addOn),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: isDeleting
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFFDC2626),
                                          ),
                                    ),
                                  )
                                : const Icon(Icons.delete_outline),
                            label: Text(isDeleting ? 'Deleting...' : 'Delete'),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addOnPhotoPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.photo_outlined, color: Color(0xFF9CA3AF)),
    );
  }

  Future<void> _showCreateAddOnSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CreateAddOnSheet(controller: controller),
    );
  }

  Future<void> _confirmDeleteAddOn(
    BuildContext context,
    AddOnModel addOn,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Add-On'),
            content: Text(
              'Are you sure you want to delete ${addOn.name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    await controller.deleteAddOn(addOn);
  }

  Future<void> _showEditAddOnSheet(
    BuildContext context,
    AddOnModel addOn,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EditAddOnSheet(controller: controller, addOn: addOn),
    );
  }

  String _formatCurrency(int value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(value);
  }
}

class _CreateAddOnSheet extends StatefulWidget {
  const _CreateAddOnSheet({required this.controller});

  final PlaceEditController controller;

  @override
  State<_CreateAddOnSheet> createState() => _CreateAddOnSheetState();
}

class _CreateAddOnSheetState extends State<_CreateAddOnSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _photo;
  String _category = 'once time';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    FocusScope.of(context).unfocus();
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _photo = File(picked.path));
  }

  Future<void> _removePhoto() async {
    setState(() => _photo = null);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Add-On',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_photo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _photo!,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_outlined,
                              color: Color(0xFF9CA3AF),
                              size: 32,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'No photo added',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickPhoto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(
                          _photo != null ? 'Change Photo' : 'Add Photo',
                        ),
                      ),
                      if (_photo != null) ...[
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: _removePhoto,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                          ),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Add-On Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (Rp)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'once time', child: Text('Once Time')),
                  DropdownMenuItem(value: 'per hour', child: Text('Per Hour')),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value ?? 'once time';
                  });
                },
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Obx(() {
                final isCreating = widget.controller.isCreatingAddOn.value;
                return SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isCreating
                        ? null
                        : () async {
                            final isValid =
                                _formKey.currentState?.validate() ?? false;
                            if (!isValid) return;

                            final price = int.tryParse(
                              _priceController.text.trim(),
                            );
                            if (price == null) {
                              Get.snackbar(
                                'Invalid Price',
                                'Please enter a valid number for the price.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            final stock = int.tryParse(
                              _stockController.text.trim(),
                            );
                            if (stock == null) {
                              Get.snackbar(
                                'Invalid Stock',
                                'Please enter a valid number for the stock.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            FocusScope.of(context).unfocus();

                            final navigator = Navigator.of(context);
                            final result = await widget.controller.createAddOn(
                              name: _nameController.text.trim(),
                              price: price,
                              category: _category,
                              stock: stock,
                              description: _descController.text.trim(),
                              photo: _photo,
                            );

                            if (!mounted) return;

                            if (result.success) {
                              navigator.pop(true);
                              Get.snackbar(
                                'Success',
                                result.message,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            Get.snackbar(
                              'Failed to add add-on',
                              result.message,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent.shade100,
                              colorText: Colors.red.shade900,
                            );
                          },
                    child: isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Create Add-On',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditAddOnSheet extends StatefulWidget {
  const _EditAddOnSheet({required this.controller, required this.addOn});

  final PlaceEditController controller;
  final AddOnModel addOn;

  @override
  State<_EditAddOnSheet> createState() => _EditAddOnSheetState();
}

class _EditAddOnSheetState extends State<_EditAddOnSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descController;
  late String _category;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.addOn.name);
    _priceController = TextEditingController(
      text: widget.addOn.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.addOn.stock.toString(),
    );
    _descController = TextEditingController(text: widget.addOn.description);
    _category = widget.addOn.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Edit Add-On',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Add-On Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (Rp)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'once time', child: Text('Once Time')),
                  DropdownMenuItem(value: 'per hour', child: Text('Per Hour')),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value ?? 'once time';
                  });
                },
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Obx(() {
                final isUpdating = widget.controller.isAddOnUpdating(
                  widget.addOn.id,
                );
                return SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isUpdating
                        ? null
                        : () async {
                            final isValid =
                                _formKey.currentState?.validate() ?? false;
                            if (!isValid) return;

                            final price = int.tryParse(
                              _priceController.text.trim(),
                            );
                            if (price == null) {
                              Get.snackbar(
                                'Invalid Price',
                                'Please enter a valid number for the price.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            final stock = int.tryParse(
                              _stockController.text.trim(),
                            );
                            if (stock == null) {
                              Get.snackbar(
                                'Invalid Stock',
                                'Please enter a valid number for the stock.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            FocusScope.of(context).unfocus();

                            final success = await widget.controller.updateAddOn(
                              addOn: widget.addOn,
                              name: _nameController.text.trim(),
                              price: price,
                              category: _category,
                              stock: stock,
                              description: _descController.text.trim(),
                            );

                            if (!mounted || !success) return;

                            Get.back();
                          },
                    child: isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
