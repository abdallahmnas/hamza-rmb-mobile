import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/section_header.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _isBalanceVisible = true;
  int _selectedFilterIndex = 0; // 0: All, 1: Inflow, 2: Outflow, 3: Exchange

  final List<String> _filters = const ['All', 'Inflow', 'Outflow', 'Exchange'];

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFundWalletSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFF0D9488),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fund Your Wallet',
                      style: AppTypography.headlineMd.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Instant bank transfer to your dedicated account',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Account details box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildAccountRow(
                    'Bank Name',
                    'Guaranty Trust Bank (GTB)',
                    false,
                  ),
                  const Divider(height: 18, color: Color(0xFFE2E8F0)),
                  _buildAccountRow('Account Number', '0123456789', true),
                  const Divider(height: 18, color: Color(0xFFE2E8F0)),
                  _buildAccountRow(
                    'Account Name',
                    'Hamza RMB / Sarah Okonjo',
                    false,
                  ),
                  const Divider(height: 18, color: Color(0xFFE2E8F0)),
                  _buildAccountRow('Payment Reference', 'HZ-20241001', true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  _copyToClipboard(
                    'Bank: GTBank\nAccount Number: 0123456789\nAccount Name: Hamza RMB / Sarah Okonjo\nRef: HZ-20241001',
                    'All bank details copied to clipboard!',
                  );
                  Navigator.of(ctx).pop();
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy All Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountRow(String label, String value, bool isCopyable) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.onBackground,
              ),
            ),
          ],
        ),
        if (isCopyable)
          GestureDetector(
            onTap: () => _copyToClipboard(value, '$value copied!'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.copy, color: Color(0xFF2563EB), size: 11),
                  const SizedBox(width: 4),
                  Text(
                    'Copy',
                    style: AppTypography.labelCaps.copyWith(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showWithdrawSheet() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Withdrawal request initiated to linked bank account.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Text(
              'My Wallet',
              style: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ACTIVE',
                    style: AppTypography.labelCaps.copyWith(
                      color: const Color(0xFF047857),
                      fontWeight: FontWeight.w800,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.onBackground,
            ),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ── 1. Elevated Luxury Balance Card ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLuxuryBalanceContainer(),
            ),

            const SizedBox(height: 20),

            // ── 2. Quick Action Buttons Row ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildActionButtonsRow(),
            ),

            const SizedBox(height: 24),

            // ── 3. Currency Accounts Section ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title: 'Currency Accounts',
                actionText: 'Manage',
                onActionPressed: () {},
              ),
            ),
            const SizedBox(height: 12),
            _buildCurrencyCardsList(),

            const SizedBox(height: 22),

            // ── 4. RMB Live Rate Banner ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildRmbRateBanner(),
            ),

            const SizedBox(height: 24),

            // ── 5. Recent Transactions Section ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title: 'Recent Transactions',
                actionText: 'View All',
                onActionPressed: () {},
              ),
            ),
            const SizedBox(height: 10),

            // Filter chips row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFilterChipsRow(),
            ),
            const SizedBox(height: 12),

            // Transactions list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTransactionsList(),
            ),

            const SizedBox(height: 100), // Bottom padding for shell nav
          ],
        ),
      ),
    );
  }

  // ── Luxury Balance Container ──────────────────────────────────────────────
  Widget _buildLuxuryBalanceContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Midnight Slate
            Color(0xFF0D253A), // Deep Ocean Navy
            Color(0xFF051D2A), // Dark Emerald Charcoal
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background ambient circular light
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D9488).withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              ),
            ),
          ),

          // Card contents
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Chip / Vault tag + Eye Visibility Toggle + ID Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shield_rounded,
                                color: Color(0xFF2DD4BF),
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'MULTI-VAULT',
                                style: AppTypography.labelCaps.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 8,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _copyToClipboard(
                            'HZ-20241001',
                            'Wallet ID HZ-20241001 copied!',
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'ID: HZ-20241001',
                                  style: AppTypography.labelCaps.copyWith(
                                    color: const Color(0xFFCBD5E1),
                                    fontSize: 9,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.copy_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Privacy Eye button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isBalanceVisible = !_isBalanceVisible;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isBalanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Balance Label
                Text(
                  'TOTAL ESTIMATED BALANCE',
                  style: AppTypography.labelCaps.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 9,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Big Balance Display
                if (_isBalanceVisible)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₦',
                        style: AppTypography.headlineLg.copyWith(
                          color: const Color(0xFF2DD4BF),
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '1,250,000',
                        style: AppTypography.headlineLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 34,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '.00',
                        style: AppTypography.headlineMd.copyWith(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      '••••••••••••',
                      style: AppTypography.headlineLg.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Multi-currency equivalents row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isBalanceVisible ? '≈ ¥6,346.60 CNY' : '≈ ¥••••',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFFFBBF24),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        _isBalanceVisible ? '≈ \$806.45 USD' : '≈ \$••••',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF38BDF8),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Divider line
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.1),
                ),

                const SizedBox(height: 14),

                // Bottom trend & monthly flow row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            color: Color(0xFF34D399),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+2.4% this week',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF34D399),
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Monthly Inflow: ₦3.45M',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Action Buttons Row ──────────────────────────────────────────────
  Widget _buildActionButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButtonItem(
          icon: Icons.add_rounded,
          label: 'Fund',
          isPrimary: true,
          onTap: _showFundWalletSheet,
        ),
        _buildActionButtonItem(
          icon: Icons.arrow_downward_rounded,
          label: 'Withdraw',
          isPrimary: false,
          onTap: _showWithdrawSheet,
        ),
        _buildActionButtonItem(
          icon: Icons.swap_horiz_rounded,
          label: 'Exchange',
          isPrimary: false,
          badgeText: 'SWAP',
          onTap: () => context.push('/exchange'),
        ),
        _buildActionButtonItem(
          icon: Icons.send_rounded,
          label: 'Transfer',
          isPrimary: false,
          onTap: () => _copyToClipboard(
            '0123456789',
            'Wallet transfer account copied!',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonItem({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isPrimary ? const Color(0xFF0D9488) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isPrimary
                        ? null
                        : Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: isPrimary
                            ? const Color(0xFF0D9488).withValues(alpha: 0.3)
                            : const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: isPrimary ? Colors.white : AppColors.onBackground,
                    size: 24,
                  ),
                ),
                if (badgeText != null)
                  Positioned(
                    top: -6,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: AppTypography.labelCaps.copyWith(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Currency Accounts List ────────────────────────────────────────────────
  Widget _buildCurrencyCardsList() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildEnhancedCurrencyCard(
            code: 'CNY',
            name: 'Chinese Yuan',
            amount: '¥45,000.00',
            rateTag: '1 CNY ≈ ₦228.50',
            flagColor: const Color(0xFFDE2910),
            gradientColors: const [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
            onAction: () => context.push('/exchange'),
          ),
          const SizedBox(width: 12),
          _buildEnhancedCurrencyCard(
            code: 'USD',
            name: 'US Dollar',
            amount: '\$2,450.00',
            rateTag: '1 USD ≈ ₦1,550.00',
            flagColor: const Color(0xFF1D4ED8),
            gradientColors: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
            onAction: () => context.push('/exchange'),
          ),
          const SizedBox(width: 12),
          _buildEnhancedCurrencyCard(
            code: 'NGN',
            name: 'Nigerian Naira',
            amount: '₦1,250,000',
            rateTag: 'Primary Currency',
            flagColor: const Color(0xFF059669),
            gradientColors: const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
            onAction: _showFundWalletSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCurrencyCard({
    required String code,
    required String name,
    required String amount,
    required String rateTag,
    required Color flagColor,
    required List<Color> gradientColors,
    required VoidCallback onAction,
  }) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: flagColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  code,
                  style: AppTypography.labelCaps.copyWith(
                    color: flagColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  name,
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            _isBalanceVisible ? amount : '••••••',
            style: AppTypography.headlineMd.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.onBackground,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  rateTag,
                  style: AppTypography.labelCaps.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onAction,
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF0D9488),
                  size: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── RMB Live Rate Banner ──────────────────────────────────────────────────
  Widget _buildRmbRateBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.currency_exchange_rounded,
              color: Color(0xFF2563EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Exchange: ¥1 = ₦228.50',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Direct payment to Alipay, WeChat & Chinese suppliers',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF3B82F6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/exchange'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Swap Now',
              style: AppTypography.bodySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chips Row ──────────────────────────────────────────────────────
  Widget _buildFilterChipsRow() {
    return Row(
      children: List.generate(_filters.length, (index) {
        final isSelected = _selectedFilterIndex == index;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                _filters[index],
                style: AppTypography.bodySm.copyWith(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Transactions List ─────────────────────────────────────────────────────
  Widget _buildTransactionsList() {
    final transactions = const [
      _TransactionData(
        icon: Icons.north_east_rounded,
        iconBgColor: Color(0xFFFEE2E2),
        iconColor: Color(0xFFDC2626),
        title: 'Air Freight Waybill Payment',
        subtitle: 'HZ-8839-LOS • Today, 10:45 AM',
        amount: '-₦150,000.00',
        amountColor: AppColors.onBackground,
        category: 'Outflow',
      ),
      _TransactionData(
        icon: Icons.south_west_rounded,
        iconBgColor: Color(0xFFD1FAE5),
        iconColor: Color(0xFF059669),
        title: 'Virtual Account Top-up',
        subtitle: 'GTBank Transfer • Yesterday, 2:15 PM',
        amount: '+₦500,000.00',
        amountColor: Color(0xFF059669),
        category: 'Inflow',
      ),
      _TransactionData(
        icon: Icons.currency_exchange_rounded,
        iconBgColor: Color(0xFFEFF6FF),
        iconColor: Color(0xFF2563EB),
        title: 'Currency Swap NGN ➔ CNY',
        subtitle: 'Alipay Recipient: Chen Wei • Oct 24',
        amount: '-₦350,000.00',
        secondaryAmount: '+¥5,500.00',
        amountColor: AppColors.onBackground,
        category: 'Exchange',
      ),
      _TransactionData(
        icon: Icons.north_east_rounded,
        iconBgColor: Color(0xFFFEE2E2),
        iconColor: Color(0xFFDC2626),
        title: '1688 Supplier Procurement',
        subtitle: 'Shenzhen Electronics Ltd • Oct 22',
        amount: '-¥12,000.00',
        amountColor: AppColors.onBackground,
        category: 'Outflow',
      ),
    ];

    final filtered = transactions.where((tx) {
      if (_selectedFilterIndex == 0) return true;
      if (_selectedFilterIndex == 1) return tx.category == 'Inflow';
      if (_selectedFilterIndex == 2) return tx.category == 'Outflow';
      if (_selectedFilterIndex == 3) return tx.category == 'Exchange';
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(filtered.length, (index) {
          final tx = filtered[index];
          final isLast = index == filtered.length - 1;
          return _buildTransactionTileItem(tx, isLast);
        }),
      ),
    );
  }

  Widget _buildTransactionTileItem(_TransactionData tx, bool isLast) {
    return InkWell(
      onTap: () => context.push('/transaction-details'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                color: tx.iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(tx.icon, color: tx.iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.onBackground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tx.subtitle,
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _isBalanceVisible ? tx.amount : '••••',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tx.amountColor,
                    fontSize: 13,
                  ),
                ),
                if (tx.secondaryAmount != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _isBalanceVisible ? tx.secondaryAmount! : '••••',
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0D9488),
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

class _TransactionData {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  final String? secondaryAmount;
  final Color amountColor;
  final String category;

  const _TransactionData({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.secondaryAmount,
    required this.amountColor,
    required this.category,
  });
}
