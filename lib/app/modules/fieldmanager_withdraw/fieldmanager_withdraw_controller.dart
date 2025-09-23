import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FieldmanagerWithdrawController extends GetxController {
  // Available methods to withdraw
  final methods = ['Bank', 'Digital Wallet', 'Other'].obs;
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

    switch (selectedMethod.value) {
      case 'Bank':
        if (bankNameController.text.isEmpty) return 'Bank name is required';
        if (bankAccountNumberController.text.isEmpty)
          return 'Bank account number is required';
        if (bankAccountHolderController.text.isEmpty)
          return 'Account holder name is required';
        break;
      case 'Digital Wallet':
        if (walletProviderController.text.isEmpty)
          return 'Wallet provider is required';
        if (walletNumberController.text.isEmpty)
          return 'Wallet number is required';
        if (walletNameController.text.isEmpty) return 'Wallet name is required';
        break;
      case 'Other':
        if (otherMethodController.text.isEmpty)
          return 'Method name is required';
        if (otherIdentifierController.text.isEmpty)
          return 'Identifier is required';
        break;
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
