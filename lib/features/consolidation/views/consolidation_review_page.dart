import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';
import '../../shipments/data/models/package_model.dart';
import '../../shipments/presentation/providers/shipments_provider.dart';
import '../../home/presentation/providers/system_metadata_provider.dart';

class ConsolidationReviewPage extends ConsumerStatefulWidget {
  final List<PackageModel> selectedPackages;

  const ConsolidationReviewPage({
    super.key,
    this.selectedPackages = const [],
  });

  @override
  ConsumerState<ConsolidationReviewPage> createState() =>
      _ConsolidationReviewPageState();
}

class _ConsolidationReviewPageState
    extends ConsumerState<ConsolidationReviewPage> {
  String _shippingMethod = 'air';
  String _paymentMethod = 'wallet';
  bool _isSubmitting = false;

  final _currencyFormat = NumberFormat('#,##0', 'en_US');

  @override
  Widget build(BuildContext context) {
    final metaState = ref.watch(systemMetadataProvider);
    final rate = metaState.exchangeRate.rate;

    final totalWeightKg = widget.selectedPackages.fold<double>(
      0.0,
      (sum, p) => sum + (p.weightKg > 0 ? p.weightKg : 0.5),
    );

    final totalDeclaredUsd = widget.selectedPackages.fold<double>(
      0.0,
      (sum, p) => sum + p.declaredValueUsd,
    );

    // Approximate fees
    final ratePerKgUsd = _shippingMethod == 'air' ? 8.5 : 2.5;
    final shippingFeeUsd = totalWeightKg * ratePerKgUsd;
    final shippingFeeNgn = shippingFeeUsd * rate;
    const consolidationFeeNgn = 5000.0;
    final grandTotalNgn = shippingFeeNgn + consolidationFeeNgn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leadingWidth: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Consolidation Review',
          style: AppTypography.headlineMd.copyWith(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Review Details',
                        style: AppTypography.headlineMd.copyWith(fontSize: 18),
                      ),
                      Text(
                        'STEP 2 OF 2',
                        style: AppTypography.labelCaps.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Finalize shipping and payment method',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress bar (full)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 1.0,
                      minHeight: 6,
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Shipping Method ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Shipping Method',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ShippingMethodCard(
                      icon: Icons.flight,
                      title: 'Air Freight',
                      subtitle: '5-7 Business Days',
                      isSelected: _shippingMethod == 'air',
                      onTap: () => setState(() => _shippingMethod = 'air'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ShippingMethodCard(
                      icon: Icons.sailing_outlined,
                      title: 'Sea Freight',
                      subtitle: '30-45 Business Days',
                      isSelected: _shippingMethod == 'sea',
                      onTap: () => setState(() => _shippingMethod = 'sea'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Payment Method ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Payment Method',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _PaymentMethodCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Pay Now',
                      subtitle: 'Wallet Balance',
                      isSelected: _paymentMethod == 'wallet',
                      onTap: () => setState(() => _paymentMethod = 'wallet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PaymentMethodCard(
                      icon: Icons.local_shipping_outlined,
                      title: 'Pay on Delivery',
                      subtitle: 'At destination',
                      isSelected: _paymentMethod == 'delivery',
                      onTap: () => setState(() => _paymentMethod = 'delivery'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Cost Breakdown ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cost Breakdown',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CostRow(
                      label: 'Selected Packages',
                      value: '${widget.selectedPackages.length} Packages',
                    ),
                    const SizedBox(height: 10),
                    _CostRow(
                      label: 'Total Weight',
                      value: '${totalWeightKg.toStringAsFixed(1)} KG',
                    ),
                    if (totalDeclaredUsd > 0) ...[
                      const SizedBox(height: 10),
                      _CostRow(
                        label: 'Declared Value',
                        value: '\$${totalDeclaredUsd.toStringAsFixed(0)} USD',
                      ),
                    ],
                    const SizedBox(height: 10),
                    _CostRow(
                      label: 'Est. Freight Fee ($_shippingMethod.toUpperCase())',
                      value: '₦${_currencyFormat.format(shippingFeeNgn.round())}',
                    ),
                    const SizedBox(height: 10),
                    const _CostRow(
                      label: 'Consolidation Service Fee',
                      value: '₦5,000',
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Total',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₦${_currencyFormat.format(grandTotalNgn.round())}',
                          style: AppTypography.headlineMd.copyWith(
                            color: AppColors.secondary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
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
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleConsolidate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Confirm & Consolidate',
                              style: AppTypography.bodyLg.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Secure checkout process',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleConsolidate() async {
    setState(() => _isSubmitting = true);

    final packageIds = widget.selectedPackages.map((p) => p.id).toList();
    final success =
        await ref.read(shipmentsProvider.notifier).createConsolidation(
              packageIds: packageIds,
              shippingMethod: _shippingMethod,
              destinationWarehouse: 'Lagos Warehouse',
              paymentMethod: _paymentMethod,
            );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consolidation request created successfully!'),
          backgroundColor: AppColors.secondary,
        ),
      );
      context.go('/track');
    } else {
      final error = ref.read(shipmentsProvider).error ??
          'Failed to create consolidation request.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// ── Shipping Method Card ───────────────────────────────────────────────────
class _ShippingMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShippingMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.secondary
                        : Colors.transparent,
                    border: isSelected
                        ? null
                        : Border.all(color: const Color(0xFFCBD5E1), width: 2),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.bodySm.copyWith(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Payment Method Card ────────────────────────────────────────────────────
class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.bodySm.copyWith(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cost Row ───────────────────────────────────────────────────────────────
class _CostRow extends StatelessWidget {
  final String label;
  final String value;

  const _CostRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

