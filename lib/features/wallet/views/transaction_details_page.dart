import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';
import '../data/models/transaction_model.dart';
import '../presentation/providers/wallet_provider.dart';

class TransactionDetailsPage extends ConsumerWidget {
  final TransactionModel? transaction;

  const TransactionDetailsPage({super.key, this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);
    final tx = transaction ??
        (walletState.transactions.isNotEmpty
            ? walletState.transactions.first
            : null);

    final isCredit = tx?.isCredit ?? false;
    final formatter = NumberFormat('#,##0.00');
    final amountStr = tx != null
        ? '${isCredit ? '+' : '-'}₦${formatter.format(tx.amount.abs())}'
        : '-₦45,000.00';

    final statusStr = tx?.status.toUpperCase() ?? 'SUCCESS';
    final isSuccess = statusStr == 'SUCCESS' || statusStr == 'COMPLETED';

    final dateStr = tx != null
        ? DateFormat('MMM dd, yyyy, hh:mm a').format(tx.createdAt)
        : 'Oct 24, 2024, 14:30';

    final reference = tx?.reference ?? tx?.id ?? 'TXN-99283471';
    final desc = tx?.description ?? 'Shipment Payment / Currency Settlement';
    final typeStr = tx?.type.toUpperCase() ?? 'PAYMENT';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, size: 18, color: AppColors.onBackground),
          ),
        ),
        leadingWidth: 64,
        title: Text(
          'Transaction Details',
          style: AppTypography.headlineMd.copyWith(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── Success Banner ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSuccess
                            ? AppColors.secondary.withValues(alpha: 0.3)
                            : AppColors.tertiary.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      isSuccess ? Icons.check : Icons.access_time,
                      color: isSuccess ? AppColors.secondary : AppColors.tertiary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    statusStr,
                    style: AppTypography.labelCaps.copyWith(
                      color: isSuccess ? AppColors.secondary : AppColors.tertiary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    amountStr,
                    style: AppTypography.headlineLg.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onBackground,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Transaction Breakdown ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRANSACTION BREAKDOWN',
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.5,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DetailRow(
                    label: 'Transaction Type',
                    value: typeStr,
                  ),
                  const _DetailDivider(),
                  _DetailRow(
                    label: 'Status',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSuccess ? AppColors.success : AppColors.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusStr,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSuccess ? AppColors.success : AppColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _DetailDivider(),
                  _DetailRow(
                    label: 'Date & Time',
                    value: dateStr,
                  ),
                  const _DetailDivider(),
                  _DetailRow(
                    label: 'Transaction ID',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reference,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: reference));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transaction ID copied'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.copy_outlined,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _DetailDivider(),
                  _DetailRow(
                    label: 'Payment Method',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Wallet Balance',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _DetailDivider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      Text(
                        'Reference',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reference,
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 20),
                  label: Text(
                    'Download Receipt',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.help_outline, size: 20),
                  label: Text(
                    'Need Help?',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onBackground,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Detail Row ─────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;

  const _DetailRow({
    required this.label,
    this.value,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          child ??
              Text(
                value ?? '',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
        ],
      ),
    );
  }
}

// ── Detail Divider ─────────────────────────────────────────────────────────
class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFF1F5F9));
  }
}
