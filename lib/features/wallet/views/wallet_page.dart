import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/widgets/section_header.dart';
import '../../home/presentation/providers/system_metadata_provider.dart';
import '../data/models/transaction_model.dart';
import '../data/models/wallet_deposit_model.dart';
import '../presentation/providers/wallet_provider.dart';
import '../../shipments/presentation/providers/shipments_provider.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  bool _isBalanceVisible = true;
  int _selectedFilterIndex = 0; // 0: All, 1: Inflow, 2: Outflow, 3: Exchange

  final List<String> _filters = const ['All', 'Inflow', 'Outflow', 'Exchange'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).refresh();
      ref.read(shipmentsProvider.notifier).fetchAll();
      ref.read(systemMetadataProvider.notifier).refreshAll();
    });
  }

  double _getCnyRate(SystemMetadataState meta) {
    if (meta.settings.cnyExchangeRate > 0) {
      return meta.settings.cnyExchangeRate;
    }
    if (meta.exchangeRate.platformRate > 0) {
      return meta.exchangeRate.platformRate;
    }
    if (meta.exchangeRate.rate > 0) {
      return meta.exchangeRate.rate;
    }
    return 215.0;
  }

  double _getUsdRate(SystemMetadataState meta) {
    if (meta.settings.usdExchangeRate > 0) {
      return meta.settings.usdExchangeRate;
    }
    return 1550.0;
  }

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
    context.push('/fund-wallet');
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
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(walletProvider.notifier).refresh(),
            ref.read(shipmentsProvider.notifier).fetchAll(isUserInitiated: true),
            ref.read(systemMetadataProvider.notifier).refreshAll(isUserInitiated: true),
          ]);
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              // ── 5. Recent Deposit Requests Section ────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(
                  title: 'Recent Deposit Requests',
                  actionText: 'Fund Wallet',
                  onActionPressed: _showFundWalletSheet,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDepositsList(),
              ),

              const SizedBox(height: 24),

              // ── 6. Recent Transactions Section ───────────────────────
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
      ),
    );
  }

  // ── Luxury Balance Container ──────────────────────────────────────────────
  Widget _buildLuxuryBalanceContainer() {
    final user = ref.watch(authServiceProvider).user;
    final wallet = ref.watch(walletProvider).wallet;
    final meta = ref.watch(systemMetadataProvider);

    final balance = wallet.balance;
    final liveRate = _getCnyRate(meta);
    final usdRate = _getUsdRate(meta);
    final cnyEquiv = liveRate > 0 ? balance / liveRate : 0.0;
    final usdEquiv = usdRate > 0 ? balance / usdRate : 0.0;

    final formatter = NumberFormat('#,##0.00');
    final formattedBalance = formatter.format(balance);
    final parts = formattedBalance.split('.');
    final wholePart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '.00';

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
                                Icons.verified_user_outlined,
                                color: Color(0xFF2DD4BF),
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user?.customerId ?? 'HZ-ACCOUNT',
                                style: AppTypography.labelCaps.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9,
                                ),
                              ),
                            ],
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
                        wholePart,
                        style: AppTypography.headlineLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 34,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        decimalPart,
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
                        _isBalanceVisible
                            ? '≈ ¥${formatter.format(cnyEquiv)} CNY'
                            : '≈ ¥••••',
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
                        _isBalanceVisible
                            ? '≈ \$${formatter.format(usdEquiv)} USD'
                            : '≈ \$••••',
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

                // Bottom trend & status
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
                            Icons.check_circle_outline,
                            color: Color(0xFF34D399),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active Tier 2 Account',
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
                      'Hamza Virtual Settlement',
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
          onTap: () {
            final wallet = ref.read(walletProvider).wallet;
            final user = ref.read(authServiceProvider).user;
            final acc = wallet.accountNumber.isNotEmpty
                ? wallet.accountNumber
                : (user?.phone ?? '0123456789');
            _copyToClipboard(
              acc,
              'Wallet transfer account copied!',
            );
          },
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
    final meta = ref.watch(systemMetadataProvider);
    final wallet = ref.watch(walletProvider).wallet;
    final balance = wallet.balance;
    final liveRate = _getCnyRate(meta);
    final usdRate = _getUsdRate(meta);
    final cnyEquiv = liveRate > 0 ? balance / liveRate : 0.0;
    final usdEquiv = usdRate > 0 ? balance / usdRate : 0.0;

    final formatter = NumberFormat('#,##0.00');

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildEnhancedCurrencyCard(
            code: 'CNY',
            name: 'Chinese Yuan',
            amount: '¥${formatter.format(cnyEquiv)}',
            rateTag: '1 CNY ≈ ₦${liveRate.toStringAsFixed(2)}',
            flagColor: const Color(0xFFDE2910),
            gradientColors: const [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
            onAction: () => context.push('/exchange'),
          ),
          const SizedBox(width: 12),
          _buildEnhancedCurrencyCard(
            code: 'USD',
            name: 'US Dollar',
            amount: '\$${formatter.format(usdEquiv)}',
            rateTag: '1 USD ≈ ₦${formatter.format(usdRate)}',
            flagColor: const Color(0xFF1D4ED8),
            gradientColors: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
            onAction: () => context.push('/exchange'),
          ),
          const SizedBox(width: 12),
          _buildEnhancedCurrencyCard(
            code: 'NGN',
            name: 'Nigerian Naira',
            amount: '₦${formatter.format(balance)}',
            rateTag: 'Primary Wallet Balance',
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
    final meta = ref.watch(systemMetadataProvider);
    final liveRate = _getCnyRate(meta);

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
                  'Live Exchange: ¥1 = ₦${liveRate.toStringAsFixed(2)}',
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
    final transactions = ref.watch(walletProvider).transactions;

    final filtered = transactions.where((tx) {
      if (_selectedFilterIndex == 0) return true;
      final type = tx.type.toLowerCase();
      if (_selectedFilterIndex == 1) {
        return type.contains('deposit') ||
            type.contains('credit') ||
            type.contains('topup') ||
            type.contains('inflow');
      }
      if (_selectedFilterIndex == 2) {
        return type.contains('debit') ||
            type.contains('withdrawal') ||
            type.contains('payment') ||
            type.contains('outflow');
      }
      if (_selectedFilterIndex == 3) {
        return type.contains('exchange') || type.contains('swap');
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF94A3B8),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Transactions Yet',
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your incoming and outgoing payments will appear here.',
              style: AppTypography.bodySm.copyWith(
                color: const Color(0xFF94A3B8),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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

  Widget _buildTransactionTileItem(TransactionModel tx, bool isLast) {
    final isCredit = tx.isCredit;
    final formatter = NumberFormat('#,##0.00');
    final formattedAmt = '${isCredit ? '+' : '-'}₦${formatter.format(tx.amount.abs())}';

    final iconData = isCredit
        ? Icons.south_west_rounded
        : (tx.type.toLowerCase().contains('exchange')
            ? Icons.currency_exchange_rounded
            : Icons.north_east_rounded);

    final iconBgColor = isCredit
        ? const Color(0xFFD1FAE5)
        : (tx.type.toLowerCase().contains('exchange')
            ? const Color(0xFFEFF6FF)
            : const Color(0xFFFEE2E2));

    final iconColor = isCredit
        ? const Color(0xFF059669)
        : (tx.type.toLowerCase().contains('exchange')
            ? const Color(0xFF2563EB)
            : const Color(0xFFDC2626));

    final dateStr =
        DateFormat('MMM dd, yyyy • hh:mm a').format(tx.createdAt);


    return InkWell(
      onTap: () => context.push('/transaction-details', extra: tx),
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
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description.isNotEmpty ? tx.description : tx.type.toUpperCase(),
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
                    dateStr,
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
                  _isBalanceVisible ? formattedAmt : '••••',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isCredit
                        ? const Color(0xFF059669)
                        : AppColors.onBackground,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.status.toUpperCase(),
                  style: AppTypography.labelCaps.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tx.status.toLowerCase() == 'completed' ||
                            tx.status.toLowerCase() == 'success'
                        ? const Color(0xFF059669)
                        : AppColors.tertiary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Recent Deposit Requests List ──────────────────────────────────────────
  Widget _buildDepositsList() {
    final deposits = ref.watch(walletProvider).deposits;

    if (deposits.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_outlined,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Pending Deposit Requests',
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bank deposits submitted for review will appear here.',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _showFundWalletSheet,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '+ Fund',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

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
        children: List.generate(deposits.length, (index) {
          final deposit = deposits[index];
          final isLast = index == deposits.length - 1;
          return _buildDepositTileItem(deposit, isLast);
        }),
      ),
    );
  }

  Widget _buildDepositTileItem(WalletDepositModel deposit, bool isLast) {
    final formatter = NumberFormat('#,##0.00');
    final formattedAmt = '₦${formatter.format(deposit.amount)}';

    Color statusColor;
    Color statusBgColor;
    String statusText;

    switch (deposit.status.toLowerCase()) {
      case 'approved':
      case 'confirmed':
      case 'completed':
        statusColor = const Color(0xFF059669);
        statusBgColor = const Color(0xFFD1FAE5);
        statusText = 'CONFIRMED';
        break;
      case 'rejected':
      case 'failed':
        statusColor = const Color(0xFFDC2626);
        statusBgColor = const Color(0xFFFEE2E2);
        statusText = 'REJECTED';
        break;
      default:
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFEF3C7);
        statusText = 'PENDING';
    }

    final dateStr = deposit.createdAt != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(deposit.createdAt!)
        : 'Recent';

    return InkWell(
      onTap: () => _showDepositDetailsSheet(deposit),
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
                color: statusBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.file_upload_outlined,
                color: statusColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _isBalanceVisible ? formattedAmt : '••••••',
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Sender: ${deposit.senderName} • Session: ${deposit.sessionId}',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (deposit.paymentReceiptUrl.isNotEmpty)
              IconButton(
                icon: const Icon(
                  Icons.receipt_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                tooltip: 'View Receipt',
                onPressed: () => _showReceiptDialog(deposit.paymentReceiptUrl),
              ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showDepositDetailsSheet(WalletDepositModel deposit) {
    final formatter = NumberFormat('#,##0.00');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deposit Request Details',
                    style: AppTypography.headlineMd.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Amount', '₦${formatter.format(deposit.amount)} ${deposit.currency}', isBold: true),
                    const Divider(height: 16),
                    _buildDetailRow('Status', deposit.status.toUpperCase(), isStatus: true),
                    const Divider(height: 16),
                    _buildDetailRow('Sender Name', deposit.senderName),
                    const Divider(height: 16),
                    _buildDetailRow('Session ID', deposit.sessionId, canCopy: true),
                    if (deposit.id.isNotEmpty) ...[
                      const Divider(height: 16),
                      _buildDetailRow('Deposit ID', deposit.id, canCopy: true),
                    ],
                    if (deposit.createdAt != null) ...[
                      const Divider(height: 16),
                      _buildDetailRow(
                        'Date Submitted',
                        DateFormat('MMM dd, yyyy • hh:mm a').format(deposit.createdAt!),
                      ),
                    ],
                    if (deposit.rejectionReason != null && deposit.rejectionReason!.isNotEmpty) ...[
                      const Divider(height: 16),
                      _buildDetailRow('Rejection Reason', deposit.rejectionReason!, isError: true),
                    ],
                  ],
                ),
              ),
              if (deposit.paymentReceiptUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showReceiptDialog(deposit.paymentReceiptUrl);
                    },
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: const Text('View Payment Receipt'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isStatus = false, bool canCopy = false, bool isError = false}) {
    Color valColor = AppColors.onBackground;
    if (isStatus) {
      valColor = value == 'CONFIRMED' || value == 'APPROVED' ? const Color(0xFF059669) : const Color(0xFFD97706);
    } else if (isError) {
      valColor = AppColors.error;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTypography.bodySm.copyWith(
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: valColor,
                fontSize: 12,
              ),
            ),
            if (canCopy) ...[
              const SizedBox(width: 6),
              InkWell(
                onTap: () => _copyToClipboard(value, '$label copied!'),
                child: const Icon(Icons.copy, size: 14, color: AppColors.primary),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showReceiptDialog(String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Receipt',
                    style: AppTypography.headlineMd.copyWith(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 160,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 40, color: AppColors.onSurfaceVariant),
                          SizedBox(height: 6),
                          Text('Unable to display receipt image'),
                        ],
                      ),
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

