import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_transaction_controller.dart';

class FieldadminTransactionView extends GetView<FieldadminTransactionController>{
  const FieldadminTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Transaction"),
      ),
    );
  }
}