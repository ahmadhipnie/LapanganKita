import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldmanager/tabs_controller/fieldmanager_profile_controller.dart';

class FieldmanagerWithdrawController extends GetxController {
  // Method fixed to bank
  final selectedMethod = 'Bank'.obs;

  // Balance (could be passed in as argument), default to 0 for now
  final balance = 0.obs;

  // Form controllers
  final amountController = TextEditingController();

  // Bank fields
  final bankNameController = TextEditingController();
  final bankAccountNumberController = TextEditingController();
  final bankAccountHolderController = TextEditingController();

  // Digital wallet fields
  final walletProviderController = TextEditingController();
  final walletNumberController = TextEditingController();
  final walletNameController = TextEditingController();

  // Other method fields
  final otherMethodController = TextEditingController();
  final otherIdentifierController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      final b = args['balance'];
      if (b is int) balance.value = b;
    }

    // Prefill defaults for Bank method (dummy)
    bankNameController.text = 'Mandiri';
    bankAccountNumberController.text = '0123456789';
    try {
      final profile = Get.find<FieldManagerProfileController>();
      bankAccountHolderController.text = (profile.name.value.isNotEmpty
          ? profile.name.value
          : 'Budi Pengelola');
    } catch (_) {
      // Profile controller not found; use dummy name
      bankAccountHolderController.text = 'Budi Pengelola';
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Ensure defaults are present if still empty when view first builds
    if (bankNameController.text.isEmpty) {
      bankNameController.text = 'Mandiri';
    }
    if (bankAccountNumberController.text.isEmpty) {
      bankAccountNumberController.text = '0123456789';
    }
    if (bankAccountHolderController.text.isEmpty) {
      try {
        final profile = Get.find<FieldManagerProfileController>();
        bankAccountHolderController.text = (profile.name.value.isNotEmpty
            ? profile.name.value
            : 'Budi Pengelola');
      } catch (_) {
        bankAccountHolderController.text = 'Budi Pengelola';
      }
    }
  }

  String? validate() {
    // Basic amount validation
    final amount = int.tryParse(amountController.text.replaceAll('.', ''));
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount';
    }
    if (amount > balance.value) {
      return 'Amount exceeds balance';
    }

    // Validate bank fields only
    if (bankNameController.text.isEmpty) return 'Bank name is required';
    if (bankAccountNumberController.text.isEmpty) {
      return 'Bank account number is required';
    }
    if (bankAccountHolderController.text.isEmpty) {
      return 'Account holder name is required';
    }
    return null;
  }

  void submit() {
    final error = validate();
    if (error != null) {
      Get.snackbar('Invalid', error);
      return;
    }
    // Simulate success: reduce local balance and return amount withdrawn
    final amount = int.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
    balance.value = (balance.value - amount).clamp(0, 1 << 31);
    Get.back(result: {'withdrawn': amount});
    Get.snackbar('Withdraw', 'Your withdraw request has been submitted');
  }

  @override
  void onClose() {
    amountController.dispose();
    bankNameController.dispose();
    bankAccountNumberController.dispose();
    bankAccountHolderController.dispose();
    walletProviderController.dispose();
    walletNumberController.dispose();
    walletNameController.dispose();
    otherMethodController.dispose();
    otherIdentifierController.dispose();
    super.onClose();
  }
}
