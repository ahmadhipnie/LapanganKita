import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/fieldadmin_navigation_controller.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs/fieldadmin_field_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs/fieldadmin_logout_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs/fieldadmin_promosi_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs/fieldadmin_transaction_view.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

class FieldadminNavigationView extends GetView<FieldadminNavigationController> {
  FieldadminNavigationView({super.key});

  final List<Widget> _pages = [
    const FieldadminTransactionView(), // index 0 - Transaction (Withdraw + Refund)
    const FieldadminFieldView(),
    const FieldadminPromosiView(), // index 1 - Promosi
    const FieldadminLogoutView(), // index 3 - Logout
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
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Transaction',
            ),
            
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              label: 'Promosi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stadium_outlined),
              label: 'Field',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Logout',
            ),
          ],
        ),
      ),
    );
  }
}
