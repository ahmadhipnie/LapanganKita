import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'fieldmanager_withdraw_controller.dart';

class FieldmanagerWithdrawView extends GetView<FieldmanagerWithdrawController> {
  const FieldmanagerWithdrawView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FieldmanagerWithdrawController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rp ${c.balance.value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Amount
                const Text(
                  'Withdraw Amount',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: c.amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. 250000',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Withdraw Method',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: c.selectedMethod.value,
                  items: c.methods
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(m),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) c.selectedMethod.value = v;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // Dynamic fields
                if (c.selectedMethod.value == 'Bank') ...[
                  const Text('Bank Name'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: c.bankNameController,
                    decoration: _inputDecoration('e.g. BCA, BRI, Mandiri'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Bank Account Number'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: c.bankAccountNumberController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('e.g. 0123456789'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Account Holder Name'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: c.bankAccountHolderController,
                    decoration: _inputDecoration('e.g. Budi Santoso'),
                  ),
                ] else if (c.selectedMethod.value == 'Digital Wallet') ...[
                  const Text('Wallet Provider'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: c.walletProviderController,
                    decoration: _inputDecoration('e.g. OVO, GoPay, Dana, ShopeePay'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Wallet Number'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: c.walletNumberController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('e.g. 081234567890'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Wallet Name'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: c.walletNameController,
                    decoration: _inputDecoration('e.g. Budi Santoso'),
                  ),
                ] else ...[
                  const Text('Method Name'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: c.otherMethodController,
                    decoration: _inputDecoration('e.g. Cash, Transfer Internal'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Identifier / Number'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: c.otherIdentifierController,
                    decoration: _inputDecoration('Enter identifier'),
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: c.submit,
                    child: const Text('Submit Withdraw'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
