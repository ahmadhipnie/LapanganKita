import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/fieldadmin_navigation_controller.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs/fieldadmin_history_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs/fieldadmin_transaction_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs/fieldadmin_withdraw_view.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

class FieldadminNavigationView extends GetView<FieldadminNavigationController> {
  FieldadminNavigationView({super.key});

  final List<Widget> _pages = [
    FieldadminWithdrawView(), // index 0
    FieldadminTransactionView(), // index 1
    FieldadminHistoryView(), // index 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      body: Obx(() => _pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[500],
          backgroundColor: AppColors.neutralColor,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Withdraw'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Transaction',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'History'),
          ],
        ),
      ),
    );
  }
}
