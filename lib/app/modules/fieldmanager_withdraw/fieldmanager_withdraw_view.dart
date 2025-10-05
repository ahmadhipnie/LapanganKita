import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lapangan_kita/app/data/models/withdraw_model.dart';

import 'fieldmanager_withdraw_controller.dart';

class FieldmanagerWithdrawView extends GetView<FieldmanagerWithdrawController> {
  const FieldmanagerWithdrawView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = controller.errorMessage.value;
          if (error.isNotEmpty) {
            return _ErrorState(
              message: error,
              onRetry: controller.fetchBalanceSummary,
            );
          }

          final withdraws = controller.withdrawHistory.toList();
          final withdrawError = controller.withdrawError.value;
          final thresholdDisplay = controller.formatCurrency(
            controller.withdrawReadyThreshold,
          );

          return RefreshIndicator(
            onRefresh: controller.fetchBalanceSummary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BalanceCard(
                    balance: controller.formatCurrency(
                      controller.balance.value,
                    ),
                    canWithdraw: controller.canWithdraw.value,
                    thresholdDisplay: thresholdDisplay,
                  ),
                  const SizedBox(height: 20),
                  _AutoWithdrawInfo(
                    description: controller.autoWithdrawSummary,
                    bankName: controller.bankName.value,
                    bankAccountNumber: controller.bankAccountNumber.value,
                    bankAccountHolder: controller.bankAccountHolder.value,
                    userEmail: controller.userInfo.value?.email ?? '-',
                    canWithdraw: controller.canWithdraw.value,
                    thresholdDisplay: thresholdDisplay,
                  ),
                  const SizedBox(height: 24),
                  _HistorySection(
                    totalWithdraws: controller.totalWithdraws,
                    totalWithdrawn: controller.totalWithdrawn,
                    withdraws: withdraws,
                    withdrawError: withdrawError,
                    formatCurrency: controller.formatCurrency,
                    onRetry: controller.fetchBalanceSummary,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.canWithdraw,
    required this.thresholdDisplay,
  });

  final String balance;
  final bool canWithdraw;
  final String thresholdDisplay;

  @override
  Widget build(BuildContext context) {
    final statusLabel = canWithdraw
        ? 'Balance ready for withdrawal'
        : 'Balance not yet eligible';
    final statusColor = canWithdraw
        ? const Color(0xFF16A34A)
        : const Color(0xFFF59E0B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance Available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      balance,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
                size: 36,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _BalanceBadge(
                icon: Icons.verified_rounded,
                label: statusLabel,
                backgroundColor: statusColor.withValues(alpha: 0.16),
                textColor: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Balance must be at least $thresholdDisplay',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceBadge extends StatelessWidget {
  const _BalanceBadge({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.textColor = Colors.white,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoWithdrawInfo extends StatelessWidget {
  const _AutoWithdrawInfo({
    required this.description,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountHolder,
    required this.userEmail,
    required this.canWithdraw,
    required this.thresholdDisplay,
  });

  final String description;
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountHolder;
  final String userEmail;
  final bool canWithdraw;
  final String thresholdDisplay;

  @override
  Widget build(BuildContext context) {
    final statusColor = canWithdraw
        ? const Color(0xFF16A34A)
        : const Color(0xFFF59E0B);
    final statusIcon = canWithdraw
        ? Icons.task_alt_rounded
        : Icons.lock_clock_rounded;
    final statusLabel = canWithdraw
        ? 'Balance ready for withdrawal $thresholdDisplay'
        : 'Balance must reach at least $thresholdDisplay';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE0E7FF),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF1D4ED8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.24)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Bank', value: bankName),
                const SizedBox(height: 8),
                _InfoRow(label: 'Account Number', value: bankAccountNumber),
                const SizedBox(height: 8),
                _InfoRow(label: 'Account Holder', value: bankAccountHolder),
                if (userEmail.isNotEmpty && userEmail != '-') ...[
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Email', value: userEmail),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.totalWithdraws,
    required this.totalWithdrawn,
    required this.withdraws,
    required this.withdrawError,
    required this.formatCurrency,
    required this.onRetry,
  });

  final int totalWithdraws;
  final int totalWithdrawn;
  final List<WithdrawModel> withdraws;
  final String withdrawError;
  final String Function(int) formatCurrency;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Withdraw History',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$totalWithdraws withdrawals',
                style: const TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _HistoryStatCard(
                title: 'Total Withdrawals',
                value: totalWithdraws.toString(),
                icon: Icons.sync_alt_rounded,
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HistoryStatCard(
                title: 'Total Withdrawn',
                value: formatCurrency(totalWithdrawn),
                icon: Icons.payments_rounded,
                color: const Color(0xFF047857),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (withdrawError.isNotEmpty)
          _HistoryError(message: withdrawError, onRetry: onRetry)
        else if (withdraws.isEmpty)
          const _EmptyHistory()
        else
          Column(
            children: [
              for (final item in withdraws)
                _WithdrawTile(withdraw: item, formatCurrency: formatCurrency),
            ],
          ),
      ],
    );
  }
}

class _HistoryStatCard extends StatelessWidget {
  const _HistoryStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.24),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF97316).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFF97316)),
              SizedBox(width: 8),
              Text(
                'failed to load history',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7C2D12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF92400E)),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7C2D12),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.history_toggle_off, color: Color(0xFF6B7280)),
              SizedBox(width: 10),
              Text(
                'No withdrawal history yet',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Withdrawal history will appear here after the withdrawal is processed.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _WithdrawTile extends StatelessWidget {
  const _WithdrawTile({required this.withdraw, required this.formatCurrency});

  final WithdrawModel withdraw;
  final String Function(int) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final processed = withdraw.isProcessed;
    final statusColor = processed
        ? const Color(0xFF16A34A)
        : const Color(0xFFF59E0B);
    final statusLabel = processed ? 'Already processed' : 'Pending';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatCurrency(withdraw.amount),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      withdraw.formattedDate(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      processed
                          ? Icons.task_alt_rounded
                          : Icons.schedule_rounded,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 18,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  withdraw.userName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF374151),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (withdraw.userEmail.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 18,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    withdraw.userEmail,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (processed &&
              withdraw.filePhotoUrl != null &&
              withdraw.filePhotoUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Proof of transfer available',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF97316),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load data',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
