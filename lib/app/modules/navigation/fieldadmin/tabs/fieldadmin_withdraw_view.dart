import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs_controller.dart/fieldadmin_withdraw_controller.dart';

class FieldadminWithdrawView extends GetView<FieldadminWithdrawController>{
  const FieldadminWithdrawView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Withdraw"),
      ),
    );
  }
}