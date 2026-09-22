import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';
import '../../shipments/data/models/package_model.dart';
import '../../shipments/presentation/providers/shipments_provider.dart';

class PreAlertHistoryPage extends ConsumerStatefulWidget {
  const PreAlertHistoryPage({super.key});

  @override
  ConsumerState<PreAlertHistoryPage> createState() =>
      _PreAlertHistoryPageState();
}

class _PreAlertHistoryPageState extends ConsumerState<PreAlertHistoryPage> {
  int _selectedTab = 0;
  final _tabs = ['All Pre-alerts', 'Pending', 'Received'];
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PackageModel> _filterPackages(List<PackageModel> packages) {
    var list = packages;

    if (_selectedTab == 1) {
      list = list
          .where((p) =>
              p.status.toLowerCase().contains('pending') ||
              p.status.toLowerCase().contains('process'))
          .toList();
    } else if (_selectedTab == 2) {
      list = list
          .where((p) =>
              p.status.toLowerCase().contains('received') ||
              p.status.toLowerCase().contains('delivered') ||
              p.status.toLowerCase().contains('arrived'))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) {
        final trk = p.trackingNumber.toLowerCase();
        final cour = (p.courier ?? '').toLowerCase();
        final desc = (p.description ?? '').toLowerCase();
        return trk.contains(q) || cour.contains(q) || desc.contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final shipmentsState = ref.watch(shipmentsProvider);
    final filtered = _filterPackages(shipmentsState.packages);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.onBackground,
          ),
        ),
        title: Text(
          'Pre Alert History',
          style: AppTypography.headlineMd.copyWith(fontSize: 18),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(shipmentsProvider.notifier).refresh(),
        color: AppColors.primary,
        child: Column(
          children: [
            // ── Search Bar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.search,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() => _searchQuery = val.trim());
                        },
                        decoration: InputDecoration(
                          hintText: 'Search tracking or courier',
                          hintStyle: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: AppTypography.bodySm,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Tab Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          _tabs[index],
                          style: AppTypography.bodySm.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.onSurfaceVariant,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // ── Pre-Alert List ──────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: AppColors.primary,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Pre-alerts Found',
                                style: AppTypography.headlineMd.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                shipmentsState.packages.isEmpty
                                    ? 'You have not submitted any pre-alerts yet. Tap below to create your first pre-alert.'
                                    : 'No pre-alerts match your active filter.',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _PackagePreAlertCard(package: item);
                      },
                    ),
            ),
          ],
        ),
      ),

      // ── Floating Action Button ──────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/pre-alert'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          'New Pre-alert',
          style: AppTypography.bodySm.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Pre-Alert Card ─────────────────────────────────────────────────────────
class _PackagePreAlertCard extends StatelessWidget {
  final PackageModel package;

  const _PackagePreAlertCard({required this.package});

  Color _statusColor() {
    final s = package.status.toLowerCase();
    if (s.contains('pending')) return AppColors.tertiary;
    if (s.contains('process') || s.contains('transit')) {
      return AppColors.secondary;
    }
    if (s.contains('received') || s.contains('delivered') || s.contains('arrived')) {
      return AppColors.success;
    }
    return AppColors.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final courierName = package.courier?.isNotEmpty == true
        ? package.courier!
        : 'Express Courier';
    final desc = package.description?.isNotEmpty == true
        ? package.description!
        : 'Package Intake';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + info + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courierName,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      package.trackingNumber,
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      package.status.toUpperCase(),
                      style: AppTypography.bodySm.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            desc,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),

          // Bottom row: weight / value + action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight: ${package.weight > 0 ? '${package.weight} kg' : 'Pending'}${package.declaredValue != null && package.declaredValue! > 0 ? ' • Declared: ¥${package.declaredValue}' : ''}',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/live-tracking'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Live Radar',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

