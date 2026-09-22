import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';
import '../../shipments/presentation/providers/shipments_provider.dart';

class ConsolidationFlowPage extends ConsumerStatefulWidget {
  const ConsolidationFlowPage({super.key});

  @override
  ConsumerState<ConsolidationFlowPage> createState() =>
      _ConsolidationFlowPageState();
}

class _ConsolidationFlowPageState extends ConsumerState<ConsolidationFlowPage> {
  final Set<String> _selectedPackageIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shipmentsProvider.notifier).fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final shipmentState = ref.watch(shipmentsProvider);
    final availablePackages = shipmentState.packages;

    final selectedPackages = availablePackages
        .where((p) => _selectedPackageIds.contains(p.id))
        .toList();
    final totalWeight = selectedPackages.fold<double>(
      0.0,
      (sum, p) => sum + (p.weightKg > 0 ? p.weightKg : 0.5),
    );

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
          'Consolidation',
          style: AppTypography.headlineMd.copyWith(fontSize: 16),
        ),
        actions: [
          IconButton(
            onPressed: () => ref
                .read(shipmentsProvider.notifier)
                .fetchAll(isUserInitiated: true),
            icon: const Icon(
              Icons.refresh_outlined,
              color: AppColors.onBackground,
              size: 22,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Packages',
                      style: AppTypography.headlineMd.copyWith(fontSize: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        'Step 1 of 2',
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose received warehouse packages to combine into one shipment',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.5,
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

          const SizedBox(height: 16),

          // ── Item List ──────────────────────────────────────────────
          Expanded(
            child: shipmentState.isLoading && availablePackages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : availablePackages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              size: 36,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Packages in Warehouse',
                            style: AppTypography.headlineMd.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Once your packages arrive at the China warehouse, they will appear here ready for consolidation.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/pre-alert'),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Pre-Alert Package'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(shipmentsProvider.notifier)
                        .fetchAll(isUserInitiated: true),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: availablePackages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = availablePackages[index];
                        final isSelected = _selectedPackageIds.contains(
                          item.id,
                        );

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedPackageIds.remove(item.id);
                              } else {
                                _selectedPackageIds.add(item.id);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.secondary.withValues(alpha: 0.6)
                                    : const Color(0xFFF1F5F9),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0F172A,
                                  ).withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.secondary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: isSelected
                                        ? null
                                        : Border.all(
                                            color: const Color(0xFFCBD5E1),
                                            width: 2,
                                          ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.trackingNumber.isNotEmpty
                                            ? item.trackingNumber
                                            : 'Package #${item.id.length > 8 ? item.id.substring(0, 8) : item.id}',
                                        style: AppTypography.bodyMd.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.courierName.isNotEmpty
                                            ? item.courierName
                                            : 'Status: ${item.status.replaceAll('_', ' ').toUpperCase()}',
                                        style: AppTypography.bodySm.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.scale_outlined,
                                            size: 14,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${item.weightKg > 0 ? item.weightKg.toStringAsFixed(1) : "0.5"} KG',
                                            style: AppTypography.labelCaps
                                                .copyWith(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                          if (item.declaredValueUsd > 0) ...[
                                            const SizedBox(width: 12),
                                            Text(
                                              '\$${item.declaredValueUsd.toStringAsFixed(0)} USD',
                                              style: AppTypography.labelCaps
                                                  .copyWith(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.secondary,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
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
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SELECTED',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_selectedPackageIds.length} Packages',
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EST. TOTAL WEIGHT',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${totalWeight.toStringAsFixed(1)} KG',
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedPackageIds.isNotEmpty
                      ? () => context.push(
                          '/consolidation-review',
                          extra: selectedPackages,
                        )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Proceed to Shipping',
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
            ],
          ),
        ),
      ),
    );
  }
}
