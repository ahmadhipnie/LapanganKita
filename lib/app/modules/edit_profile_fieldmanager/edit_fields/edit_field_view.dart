import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../edit_profile_controller.dart';

class EditFieldView extends StatefulWidget {
  final String title;
  final String hint;
  final TextEditingController? controller;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? helperText;
  final VoidCallback? onSave;
  // For gender dropdown
  final bool isGender;
  // For bank type dropdown
  final bool isBankType;
  // For address (street, city, province)
  final bool isAddress;
  // For birthdate
  final bool isBirthdate;
  final TextEditingController? streetController;
  final TextEditingController? cityController;
  final TextEditingController? provinceController;

  const EditFieldView({
    super.key,
    required this.title,
    required this.hint,
    this.controller,
    this.maxLength,
    this.keyboardType,
    this.helperText,
    this.onSave,
    this.isGender = false,
    this.isBankType = false,
    this.isAddress = false,
    this.isBirthdate = false,
    this.streetController,
    this.cityController,
    this.provinceController,
  });

  @override
  State<EditFieldView> createState() => _EditFieldViewState();
}

class _EditFieldViewState extends State<EditFieldView> {
  String? selectedGender;
  String? selectedBankType;
  // bool _isSaving = false;
  final List<String> genderOptions = ['male', 'female'];
  final List<String> bankOptions = [
    'BCA',
    'BNI',
    'BRI',
    'Mandiri',
    'CIMB',
    'Danamon',
    'Permata',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isGender && widget.controller != null) {
      selectedGender = widget.controller!.text;
    }
    if (widget.isBankType && widget.controller != null) {
      selectedBankType = widget.controller!.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditProfileFieldmanagerController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isGender)
              DropdownButtonFormField<String>(
                initialValue: selectedGender,
                items: genderOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() => selectedGender = val);
                  if (widget.controller != null) {
                    widget.controller!.text = val ?? '';
                  }
                },
                decoration: InputDecoration(
                  labelText: widget.hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2563EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2563EB)),
                  ),
                ),
              )
            else if (widget.isBankType)
              DropdownButtonFormField<String>(
                initialValue: selectedBankType,
                items: bankOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() => selectedBankType = val);
                  if (widget.controller != null) {
                    widget.controller!.text = val ?? '';
                  }
                },
                decoration: InputDecoration(
                  labelText: widget.hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2563EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2563EB)),
                  ),
                ),
              )
            else if (widget.isAddress)
              Column(
                children: [
                  TextField(
                    controller: widget.streetController,
                    decoration: const InputDecoration(
                      labelText: 'Street',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: widget.cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: widget.provinceController,
                    decoration: const InputDecoration(
                      labelText: 'Province',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              )
            else if (widget.isBirthdate)
              GestureDetector(
                onTap: () async {
                  // Parse existing date if available
                  DateTime initialDate = DateTime.now();
                  if (widget.controller?.text.isNotEmpty == true) {
                    try {
                      // Try to parse DD/MM/YYYY format first
                      final parts = widget.controller!.text.split('/');
                      if (parts.length == 3) {
                        initialDate = DateTime(
                          int.parse(parts[2]), // year
                          int.parse(parts[1]), // month
                          int.parse(parts[0]), // day
                        );
                      }
                    } catch (e) {
                      print('Error parsing date: $e');
                    }
                  }

                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (picked != null && widget.controller != null) {
                    setState(() {
                      // Save as DD/MM/YYYY format
                      widget.controller!.text =
                          '${picked.day.toString().padLeft(2, '0')}/'
                          '${picked.month.toString().padLeft(2, '0')}/'
                          '${picked.year}';
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: widget.controller,
                    decoration: InputDecoration(
                      labelText: widget.hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF2563EB),
                      ),
                      helperText: widget.helperText,
                    ),
                  ),
                ),
              )
            else
              TextField(
                controller: widget.controller,
                maxLength: widget.maxLength,
                keyboardType: widget.keyboardType,
                decoration: InputDecoration(
                  labelText: widget.hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2563EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2563EB)),
                  ),
                  helperText: widget.helperText,
                ),
              ),
            const SizedBox(height: 8),
            if (widget.helperText != null)
              Text(
                widget.helperText!,
                style: const TextStyle(color: Colors.grey),
              ),
            const Spacer(),
            // Save Button - at the bottom of the build method
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          // Call onSave - controller handles Get.back() on success
                          if (widget.onSave != null) {
                            widget.onSave!();
                          }
                        },
                  child: controller.isLoading.value
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
                          'Save',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
