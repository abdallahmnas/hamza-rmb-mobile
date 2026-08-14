import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/section_header.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Dark Balance Header ────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'TOTAL BALANCE (NGN)',
                        style: AppTypography.labelCaps.copyWith(
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.5,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₦1,250,000.00',
                        style: AppTypography.currencyDisplay.copyWith(
                          fontSize: 34,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up, color: AppColors.secondary, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '+2.4% this week',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Action Buttons ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _ActionButton(
                    icon: Icons.add,
                    label: 'Fund',
                    onTap: () {},
                  ),
                  const SizedBox(width: 24),
                  _ActionButton(
                    icon: Icons.arrow_downward,
                    label: 'Withdraw',
                    onTap: () {},
                  ),
                  const SizedBox(width: 24),
                  _ActionButton(
                    icon: Icons.swap_horiz,
                    label: 'Transfer',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Currency Balances ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                title: 'Currency Balances',
                actionText: 'Manage',
                onActionPressed: () {},
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _CurrencyCard(
                    code: 'CNY',
                    name: 'Yuan',
                    amount: '¥45,000.00',
                    flagColor: Color(0xFFDE2910),
                  ),
                  SizedBox(width: 12),
                  _CurrencyCard(
                    code: 'USD',
                    name: 'Dollar',
                    amount: '\$2,450.00',
                    flagColor: Color(0xFF3C3B6E),
                  ),
                  SizedBox(width: 12),
                  _CurrencyCard(
                    code: 'NGN',
                    name: 'Naira',
                    amount: '₦1,250,000',
                    flagColor: Color(0xFF008751),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Recent Transactions ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                title: 'Recent Transactions',
                actionText: 'View All',
                onActionPressed: () {},
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _TransactionTile(
                    icon: Icons.north_east,
                    iconBgColor: const Color(0xFFFEE2E2),
                    iconColor: AppColors.error,
                    title: 'Shipment Payment',
                    subtitle: 'REQ-8412 • Today, 10:...',
                    amount: '-₦150,000.00',
                    amountColor: AppColors.onBackground,
                    onTap: () => context.push('/transaction-details'),
                  ),
                  _TransactionTile(
                    icon: Icons.south_west,
                    iconBgColor: const Color(0xFFECFDF5),
                    iconColor: AppColors.success,
                    title: 'Wallet Top-up',
                    subtitle: 'Bank Transfer • Yest...',
                    amount: '+₦500,000.00',
                    amountColor: AppColors.success,
                    onTap: () => context.push('/transaction-details'),
                  ),
                  _TransactionTile(
                    icon: Icons.currency_exchange,
                    iconBgColor: const Color(0xFFF0FDFA),
                    iconColor: AppColors.secondary,
                    title: 'Currency Exchange',
                    subtitle: 'NGN to CNY • Oct 24,...',
                    amount: '-₦350,000.00',
                    secondaryAmount: '+¥5,500.00',
                    amountColor: AppColors.onBackground,
                    onTap: () => context.push('/transaction-details'),
                  ),
                  _TransactionTile(
                    icon: Icons.north_east,
                    iconBgColor: const Color(0xFFFEE2E2),
                    iconColor: AppColors.error,
                    title: 'Supplier Payment',
                    subtitle: 'Shenzhen Electronics •...',
                    amount: '-¥12,000.00',
                    amountColor: AppColors.onBackground,
                    isLast: true,
                    onTap: () => context.push('/transaction-details'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Action Button ──────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Currency Balance Card ──────────────────────────────────────────────────
class _CurrencyCard extends StatelessWidget {
  final String code;
  final String name;
  final String amount;
  final Color flagColor;

  const _CurrencyCard({
    required this.code,
    required this.name,
    required this.amount,
    required this.flagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: flagColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  code,
                  style: AppTypography.labelCaps.copyWith(
                    color: flagColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: AppTypography.headlineMd.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transaction Tile ───────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  final String? secondaryAmount;
  final Color amountColor;
  final bool isLast;
  final VoidCallback? onTap;

  const _TransactionTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.secondaryAmount,
    required this.amountColor,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                    fontSize: 13,
                  ),
                ),
                if (secondaryAmount != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    secondaryAmount!,
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
