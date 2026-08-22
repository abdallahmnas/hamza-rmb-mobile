import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class PreAlertHistoryPage extends StatefulWidget {
  const PreAlertHistoryPage({super.key});

  @override
  State<PreAlertHistoryPage> createState() => _PreAlertHistoryPageState();
}

class _PreAlertHistoryPageState extends State<PreAlertHistoryPage> {
  int _selectedTab = 0;
  final _tabs = ['All Pre-alerts', 'Pending', 'Received'];

  // Mock data
  final List<_PreAlertItem> _allItems = [
    _PreAlertItem(
      courier: 'FedEx Express',
      trackingNumber: 'FX-9823-7491-X',
      status: 'Pending',
      submittedDate: 'Oct 24, 2023',
      icon: Icons.local_shipping_outlined,
    ),
    _PreAlertItem(
      courier: 'DHL International',
      trackingNumber: 'DHL-4491-8820-A',
      status: 'Processing',
      submittedDate: 'Oct 22, 2023',
      icon: Icons.flight_takeoff,
    ),
    _PreAlertItem(
      courier: 'UPS Ground',
      trackingNumber: 'UP-1120-4339-B',
      status: 'Received',
      submittedDate: 'Oct 15, 2023',
      icon: Icons.inventory_2_outlined,
    ),
  ];

  List<_PreAlertItem> get _filteredItems {
    if (_selectedTab == 0) return _allItems;
    if (_selectedTab == 1) {
      return _allItems
          .where((i) => i.status == 'Pending' || i.status == 'Processing')
          .toList();
    }
    return _allItems.where((i) => i.status == 'Received').toList();
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'History',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
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
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return _PreAlertCard(item: item);
              },
            ),
          ),
        ],
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

// ── Data Model ─────────────────────────────────────────────────────────────
class _PreAlertItem {
  final String courier;
  final String trackingNumber;
  final String status;
  final String submittedDate;
  final IconData icon;

  const _PreAlertItem({
    required this.courier,
    required this.trackingNumber,
    required this.status,
    required this.submittedDate,
    required this.icon,
  });
}

// ── Pre-Alert Card ─────────────────────────────────────────────────────────
class _PreAlertCard extends StatelessWidget {
  final _PreAlertItem item;

  const _PreAlertCard({required this.item});

  Color _statusColor() {
    switch (item.status) {
      case 'Pending':
        return AppColors.tertiary;
      case 'Processing':
        return AppColors.secondary;
      case 'Received':
        return AppColors.success;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final isReceived = item.status == 'Received';

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
                child: Icon(
                  item.icon,
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
                      item.courier,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.trackingNumber,
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
                      item.status,
                      style: AppTypography.bodySm.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),

          // Bottom row: date + action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Submitted ${item.submittedDate}',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              if (isReceived)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Archived',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.archive_outlined,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                )
              else
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
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
