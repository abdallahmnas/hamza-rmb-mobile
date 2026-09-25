import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_bar_logo_title.dart';
import '../../home/presentation/providers/system_metadata_provider.dart';
import '../models/exchange_review_data.dart';
import '../presentation/providers/exchange_provider.dart';

class ExchangePage extends ConsumerStatefulWidget {
  const ExchangePage({super.key});

  @override
  ConsumerState<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends ConsumerState<ExchangePage> {
  final _sendController = TextEditingController(text: '100000');
  final _cnyController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(systemMetadataProvider.notifier).refreshAll();
      ref.read(exchangeProvider.notifier).fetchSavedAccounts();
      _calculateFromNgn(_sendController.text);
    });
  }

  @override
  void dispose() {
    _sendController.dispose();
    _cnyController.dispose();
    super.dispose();
  }

  double _getEffectiveRate() {
    final meta = ref.read(systemMetadataProvider);
    final cnySetting = meta.settings.cnyExchangeRate;
    if (cnySetting > 0) return cnySetting;
    final platformRate = meta.exchangeRate.platformRate;
    if (platformRate > 0) return platformRate;
    return 215.0;
  }

  void _calculateFromNgn(String value) {
    if (_isUpdating) return;
    _isUpdating = true;
    final rate = _getEffectiveRate();
    final cleaned = value.replaceAll(',', '').trim();
    final amountNgn = double.tryParse(cleaned) ?? 0.0;
    if (rate > 0 && amountNgn > 0) {
      final cny = amountNgn / rate;
      _cnyController.text = cny.toStringAsFixed(2);
    } else {
      _cnyController.text = '';
    }
    _isUpdating = false;
    setState(() {});
  }

  void _calculateFromCny(String value) {
    if (_isUpdating) return;
    _isUpdating = true;
    final rate = _getEffectiveRate();
    final cleaned = value.replaceAll(',', '').trim();
    final amountCny = double.tryParse(cleaned) ?? 0.0;
    if (rate > 0 && amountCny > 0) {
      final ngn = amountCny * rate;
      _sendController.text = ngn.toStringAsFixed(2);
    } else {
      _sendController.text = '';
    }
    _isUpdating = false;
    setState(() {});
  }

  void _applyPresetAmount(double amount) {
    _sendController.text = amount.toStringAsFixed(0);
    _calculateFromNgn(_sendController.text);
  }

  void _navigateToReview() {
    final rate = _getEffectiveRate();
    final cleanedNgn = _sendController.text.replaceAll(',', '').trim();
    final amountNgn = double.tryParse(cleanedNgn) ?? 0.0;

    final cleanedCny = _cnyController.text.replaceAll(',', '').trim();
    final amountCny = double.tryParse(cleanedCny) ?? 0.0;

    if (amountNgn <= 0 || amountCny <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount to swap'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final exchangeState = ref.read(exchangeProvider);
    final savedAccount = exchangeState.selectedSavedAccount;

    final data = ExchangeReviewData(
      sendAmount: NumberFormat('#,##0.00').format(amountNgn),
      receiveAmount: NumberFormat('#,##0.00').format(amountCny),
      sendCurrency: 'NGN',
      receiveCurrency: 'CNY',
      exchangeRate: '1 CNY = ₦${rate.toStringAsFixed(2)} NGN',
      selectedPlatform: savedAccount?.platform ?? 'wechat_pay',
      beneficiaryName: savedAccount?.accountName ?? '',
      accountId: savedAccount?.accountNumber ?? '',
      imageUrl: savedAccount?.barcodeUrl,
      savedAccount: savedAccount,
    );
    context.push('/exchange-review', extra: data);
  }

  @override
  Widget build(BuildContext context) {
    final meta = ref.watch(systemMetadataProvider);
    final liveRate = meta.settings.cnyExchangeRate > 0
        ? meta.settings.cnyExchangeRate
        : meta.exchangeRate.platformRate > 0
            ? meta.exchangeRate.platformRate
            : 215.0;
    final usdRate = meta.settings.usdExchangeRate > 0
        ? meta.settings.usdExchangeRate
        : 1550.0;

    final liveRateStr = '₦${liveRate.toStringAsFixed(2)}';
    final usdRateStr = '₦${usdRate.toStringAsFixed(2)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: AppBarLogoTitle(
          title: 'Currency Exchange',
          style: AppTypography.headlineMd,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined, color: AppColors.primary),
            tooltip: 'Saved RMB Accounts',
            onPressed: () => context.push('/exchange-saved-accounts'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Exchange Rates Section ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Exchange Rates',
                    style: AppTypography.headlineMd.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live market data synchronized with China Hub',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Rate Cards ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _RateCard(
                      fromCurrency: 'CNY',
                      toCurrency: 'NGN',
                      rate: liveRateStr,
                      change: 'Platform Rate',
                      changePeriod: 'Live',
                      isPositive: true,
                      gradientColors: const [
                        Color(0xFF10B981),
                        Color(0xFF059669),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RateCard(
                      fromCurrency: 'USD',
                      toCurrency: 'NGN',
                      rate: usdRateStr,
                      change: 'Official Rate',
                      changePeriod: 'Daily',
                      isPositive: true,
                      gradientColors: const [
                        Color(0xFF3B82F6),
                        Color(0xFF2563EB),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Saved Accounts Quick Bar ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer(
                builder: (context, ref, _) {
                  final exState = ref.watch(exchangeProvider);
                  final count = exState.savedAccounts.length;
                  final defaultAcc = exState.selectedSavedAccount;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                count > 0
                                    ? 'Saved Account: ${defaultAcc?.label.isNotEmpty == true ? defaultAcc!.label : defaultAcc?.accountName ?? "Active"}'
                                    : 'Saved RMB Accounts',
                                style: AppTypography.bodySm.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                              Text(
                                count > 0
                                    ? '${defaultAcc?.accountName ?? ""} (${defaultAcc?.accountNumber ?? ""})'
                                    : 'Add WeChat or Alipay for quick 1-tap swaps',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push('/exchange-saved-accounts'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            count > 0 ? 'Manage' : '+ Add',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── Quick Convert Card (Dark) ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Convert Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instant Calculator',
                              style: AppTypography.bodyLg.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Alipay / WeChat / Bank',
                            style: AppTypography.labelCaps.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // You Send
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'You Send (Nigerian Naira)',
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'NGN',
                          style: AppTypography.labelCaps.copyWith(
                            color: const Color(0xFF38BDF8),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF334155),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _sendController,
                              onChanged: _calculateFromNgn,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              textAlign: TextAlign.left,
                              style: AppTypography.bodyLg.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                                isDense: true,
                                hintText: '0.00',
                                hintStyle: TextStyle(color: Color(0xFF64748B)),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const _CurrencyBadge(
                            currency: 'NGN',
                            color: Color(0xFF10B981),
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                        ],
                      ),
                    ),

                    // Quick presets
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [50000.0, 100000.0, 500000.0, 1000000.0].map((amt) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () => _applyPresetAmount(amt),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF334155),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '₦${NumberFormat.compact().format(amt)}',
                                  style: AppTypography.labelCaps.copyWith(
                                    color: const Color(0xFFCBD5E1),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Real-Time Recipient Gets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recipient Gets (Chinese Yuan)',
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'EDITABLE / REAL-TIME',
                          style: AppTypography.labelCaps.copyWith(
                            color: const Color(0xFF10B981),
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cnyController,
                              onChanged: _calculateFromCny,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              textAlign: TextAlign.left,
                              style: AppTypography.bodyLg.copyWith(
                                color: const Color(0xFF34D399),
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                                isDense: true,
                                hintText: '0.00',
                                hintStyle: TextStyle(
                                  color: Color(0xFF047857),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const _CurrencyBadge(
                            currency: 'CNY',
                            color: Color(0xFFEF4444),
                            icon: Icons.currency_yen_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Exchange Rate Info
                    _InfoRow(
                      icon: Icons.trending_up_rounded,
                      label: 'Applied Rate',
                      value: '1 CNY = ₦${liveRate.toStringAsFixed(2)} NGN',
                      valueStyle: AppTypography.bodySm.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.check_circle_outline,
                      label: 'Settlement Fee',
                      value: '₦0.00 (Zero Hidden Fee)',
                      valueStyle: AppTypography.bodySm.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.flash_on_rounded,
                      label: 'Payout Speed',
                      valueWidget: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '15-30 Mins Direct Deposit',
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF34D399),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Request Exchange Button ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F473E), Color(0xFF115E59)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F473E).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _navigateToReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Proceed to Recipient Details',
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rate Card ────────────────────────────────────────────────────────────────
class _RateCard extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final String rate;
  final String change;
  final String changePeriod;
  final bool isPositive;
  final List<Color> gradientColors;

  const _RateCard({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.change,
    required this.changePeriod,
    required this.isPositive,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  fromCurrency,
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.swap_horiz,
                color: AppColors.onSurfaceVariant,
                size: 14,
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  toCurrency,
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rate,
            style: AppTypography.headlineMd.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$change • $changePeriod',
            style: AppTypography.bodySm.copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Currency Badge ───────────────────────────────────────────────────────────
class _CurrencyBadge extends StatelessWidget {
  final String currency;
  final Color color;
  final IconData icon;

  const _CurrencyBadge({
    required this.currency,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            currency,
            style: AppTypography.bodySm.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? value;
  final TextStyle? valueStyle;
  final Widget? valueWidget;

  const _InfoRow({
    this.icon,
    required this.label,
    this.value,
    this.valueStyle,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: const Color(0xFF94A3B8), size: 14),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: const Color(0xFF94A3B8),
            fontSize: 11.5,
          ),
        ),
        const Spacer(),
        if (valueWidget != null)
          valueWidget!
        else
          Text(value ?? '', style: valueStyle),
      ],
    );
  }
}
