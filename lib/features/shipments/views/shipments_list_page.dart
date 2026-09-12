import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

// ── Data model for a shipment item ─────────────────────────────────────────
class _ShipmentItem {
  final String name;
  final String waybill;
  final String status;
  final Color statusColor;
  final Color statusBgColor;
  final String location;
  final String weight;
  final String packages;
  final String extra; // e.g. "Est: Nov 04" or "Customs Cleared"
  final IconData icon;
  final Color iconColor;

  const _ShipmentItem({
    required this.name,
    required this.waybill,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
    required this.location,
    required this.weight,
    required this.packages,
    required this.extra,
    required this.icon,
    required this.iconColor,
  });
}

class ShipmentsListPage extends StatefulWidget {
  const ShipmentsListPage({super.key});

  @override
  State<ShipmentsListPage> createState() => _ShipmentsListPageState();
}

class _ShipmentsListPageState extends State<ShipmentsListPage> {
  int _selectedFilter = 0;

  final List<String> _filters = [
    'All Shipments',
    'In Transit',
    'Origin Hub (CAN)',
  ];

  final List<int> _filterCounts = [12, 3, 1];

  final List<_ShipmentItem> _shipments = const [
    _ShipmentItem(
      name: 'Smart Watch ...',
      waybill: 'HZ-AWB-8928412...',
      status: 'In Transit • Flight CZ-3055',
      statusColor: Color(0xFF0D9488),
      statusBgColor: Color(0xFFCCFBF1),
      location: 'En route (Guangzhou → Lagos Hub)',
      weight: '14.50 KG',
      packages: '3 pkgs',
      extra: 'Est: Nov 04',
      icon: Icons.flight_takeoff,
      iconColor: Color(0xFF0D9488),
    ),
    _ShipmentItem(
      name: 'Women Luxury ...',
      waybill: 'HZ-AWB-9841285-CN',
      status: 'At Origin Warehouse',
      statusColor: Color(0xFF2563EB),
      statusBgColor: Color(0xFFDBEAFE),
      location: 'Guangzhou Baiyun Consolidation Hub',
      weight: '6.20 KG',
      packages: '1 pkg',
      extra: 'Intake Verified',
      icon: Icons.warehouse_outlined,
      iconColor: Color(0xFF2563EB),
    ),
    _ShipmentItem(
      name: 'LED Ring Li...',
      waybill: 'HZ-AWB-77192...',
      status: 'Ready for Pickup / Dispatch',
      statusColor: Color(0xFFF59E0B),
      statusBgColor: Color(0xFFFEF3C7),
      location: 'Lagos Ikeja Main Facility',
      weight: '22.00 KG',
      packages: '5 cartons',
      extra: 'Customs Cleared',
      icon: Icons.local_shipping_outlined,
      iconColor: Color(0xFFF59E0B),
    ),
    _ShipmentItem(
      name: 'Auto Spare Parts & Sens...',
      waybill: 'HZ-AWB-6531980-CN',
      status: 'Delivered',
      statusColor: Color(0xFF64748B),
      statusBgColor: Color(0xFFF1F5F9),
      location: 'Delivered to Sarah Okonjo (Lagos)',
      weight: '8.40 KG',
      packages: '',
      extra: 'Oct 28',
      icon: Icons.check_circle_outline,
      iconColor: Color(0xFF10B981),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Stats Bar ───────────────────────────────────────────
            const SizedBox(height: 20),
            const _TopStatsBar(),
            const SizedBox(height: 10),

            // ── Search Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.search,
                            color: AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Search Waybill #, 1688 tag, or ite...',
                              style: AppTypography.bodySm.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Scan button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        Text(
                          'SCAN',
                          style: AppTypography.bodySm.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 7,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            // ── Filter Chips ────────────────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (context2, index2) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _filters[index],
                            style: AppTypography.bodySm.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.onBackground,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : const Color(0xFFF1F5F9),
                            ),
                            child: Center(
                              child: Text(
                                '${_filterCounts[index]}',
                                style: AppTypography.bodySm.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // ── Shipment List ───────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: _shipments.length,
                separatorBuilder: (context2, index2) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => context.push('/shipment-details'),
                    child: _ShipmentCard(item: _shipments[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ── Floating Bottom CTA ─────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/pre-alert'),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: Text(
              'Pre-Alert China Cargo',
              style: AppTypography.bodyMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppColors.secondary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── TOP STATS BAR ──────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _TopStatsBar extends StatelessWidget {
  const _TopStatsBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Active Freight stat
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.flight_takeoff,
                    color: Color(0xFF0D9488),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE FREIGHT',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '3 ',
                            style: AppTypography.headlineMd.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: 'In Transit',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),

          // At Hub stat
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warehouse_outlined,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AT IKEJA HUB',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '1 ',
                            style: AppTypography.headlineMd.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: 'Ready',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
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
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── SHIPMENT CARD ──────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ShipmentCard extends StatelessWidget {
  final _ShipmentItem item;

  const _ShipmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
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
          // Row 1: icon + name/waybill + status badge + chevron
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipment icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              // Name + waybill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status badge
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: item.statusBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.status,
                              style: AppTypography.bodySm.copyWith(
                                color: item.statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.waybill,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),

          const SizedBox(height: 10),

          // Row 2: location
          Row(
            children: [
              const SizedBox(width: 50), // indent to align with text above
              Icon(
                _getLocationIcon(item.status),
                color: AppColors.onSurfaceVariant,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.location,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Row 3: weight, packages, extra, chevron
          Row(
            children: [
              const SizedBox(width: 50),
              Text(
                item.weight,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: AppColors.onBackground,
                ),
              ),
              if (item.packages.isNotEmpty) ...[
                _dot(),
                Text(
                  item.packages,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
              _dot(),
              Expanded(
                child: Text(
                  item.extra,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getLocationIcon(String status) {
    if (status.contains('Transit') || status.contains('Flight')) {
      return Icons.flight;
    } else if (status.contains('Delivered')) {
      return Icons.check_circle_outline;
    } else if (status.contains('Pickup') || status.contains('Dispatch')) {
      return Icons.store_outlined;
    } else {
      return Icons.location_on_outlined;
    }
  }

  Widget _dot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '•',
        style: AppTypography.bodySm.copyWith(
          color: const Color(0xFFCBD5E1),
          fontSize: 11,
        ),
      ),
    );
  }
}
