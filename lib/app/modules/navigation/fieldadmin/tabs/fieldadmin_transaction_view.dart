import 'package:flutter/material.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs/fieldadmin_refund_view.dart';
import 'package:lapangan_kita/app/modules/navigation/fieldadmin/tabs/fieldadmin_withdraw_view.dart';
import 'package:lapangan_kita/app/themes/color_theme.dart';

class FieldadminTransactionView extends StatelessWidget {
  const FieldadminTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.neutralColor,
        appBar: AppBar(
          toolbarHeight: 20
          ,
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey[600],
            tabs: const [
              Tab(
                icon: Icon(Icons.account_balance_wallet),
                text: 'Withdraw',
              ),
              Tab(
                icon: Icon(Icons.receipt_long),
                text: 'Refund',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FieldadminWithdrawView(),
            FieldadminRefundView(),
          ],
        ),
      ),
    );
  }
}
