import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class ShipmentDetailsPage extends StatelessWidget {
  const ShipmentDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Shipment Details',
          style: AppTypography.headlineMd.copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.onBackground),
            onPressed: () {},
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Waybill Header Card ─────────────────────────────────
            _WaybillHeaderCard(),
            SizedBox(height: 20),

            // ── Cargo Specs ─────────────────────────────────────────
            _CargoSpecsGrid(),
            SizedBox(height: 20),

            // ── Freight & Invoicing ─────────────────────────────────
            _FreightInvoicingSection(),
            SizedBox(height: 20),

            // ── Guangzhou Intake Proofs ──────────────────────────────
            _IntakeProofsSection(),
            SizedBox(height: 20),

            // ── Milestones & Journey ────────────────────────────────
            _MilestonesSection(),
            SizedBox(height: 20),

            // ── Merged Sub-Packages ─────────────────────────────────
            _SubPackagesSection(),
          ],
        ),
      ),

      // ── Floating CTA ────────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/live-tracking'),
            icon: const Icon(Icons.radar, size: 18),
            label: Text(
              'Track Live Flight Radar',
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
// ── WAYBILL HEADER CARD ────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _WaybillHeaderCard extends StatelessWidget {
  const _WaybillHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top labels
          Row(
            children: [
              Text(
                'MASTER\nWAYBILL',
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  letterSpacing: 0.5,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flight, color: AppColors.secondary, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'ACTIVE AIR CARGO',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Waybill number
          Text(
            'HZ-AWB-8920412-\nCN',
            style: AppTypography.headlineLg.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Route card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3748),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Origin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORIGIN HUB',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CAN',
                        style: AppTypography.headlineMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        'Guangzhou, CN',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                // Flight info
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'FLIGHT CZ-3055',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(width: 20, height: 1, color: const Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        const Icon(Icons.flight, color: AppColors.secondary, size: 16),
                        const SizedBox(width: 4),
                        Container(width: 20, height: 1, color: const Color(0xFF64748B)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Direct',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),

                // Destination
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'DEST HUB',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'LOS',
                        style: AppTypography.headlineMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        'Lagos, NG',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Estimated arrival
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B), size: 14),
              const SizedBox(width: 6),
              Text(
                'Est. Arrival Mon, Nov 14, 2024',
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '5S SEGMENTS',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── CARGO SPECS GRID ───────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _CargoSpecsGrid extends StatelessWidget {
  const _CargoSpecsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _specTile(Icons.scale, 'GROSS WEIGHT', '14.50 KG'),
              const SizedBox(height: 10),
              _specTile(Icons.widgets_outlined, 'PACKAGES', '3 Cartons'),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              _specTile(Icons.view_in_ar, 'TOTAL VOLUME', '0.082 C...'),
              const SizedBox(height: 10),
              _specTile(Icons.local_shipping_outlined, 'SERVICE', 'Air Express'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _specTile(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── FREIGHT & INVOICING ────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _FreightInvoicingSection extends StatelessWidget {
  const _FreightInvoicingSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          // Header
          Row(
            children: [
              Text(
                'Freight &\nInvoicing',
                style: AppTypography.headlineMd.copyWith(fontSize: 16, height: 1.2),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'PAID IN FULL',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Fee note
          Text(
            'Freight Rate Applicable \$7.50 / KG (₦6,950/KG)',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 12),

          // Line items
          _feeRow('Base Freight (14.50 KG)', '₦123,975', '(\$108.75)'),
          const SizedBox(height: 8),
          _feeRow('Customs Duty & Clearance', '₦15,000', null),
          const SizedBox(height: 8),
          _feeRow('Terminal Handling & Doc', '₦3,500', null),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL SETTLED',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₦142,475',
                    style: AppTypography.headlineMd.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Settlement Ref',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TXN-99412-CN',
                    style: AppTypography.labelCaps.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feeRow(String label, String amount, String? secondary) {
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
        Row(
          children: [
            Text(
              amount,
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (secondary != null) ...[
              const SizedBox(width: 4),
              Text(
                secondary,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── INTAKE PROOFS SECTION ──────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _IntakeProofsSection extends StatelessWidget {
  const _IntakeProofsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              const Icon(Icons.photo_camera_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Guangzhou Intake\nProofs',
                style: AppTypography.headlineMd.copyWith(fontSize: 16, height: 1.2),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, color: AppColors.success, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _proofTile('Photos'),
              const SizedBox(width: 10),
              _proofTile('Photos'),
              const SizedBox(width: 10),
              _proofTile('Photos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _proofTile(String label) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, color: AppColors.onSurfaceVariant, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── MILESTONES & JOURNEY ───────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _MilestonesSection extends StatelessWidget {
  const _MilestonesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          // Header
          Row(
            children: [
              const Icon(Icons.timeline, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Milestones & Journey',
                style: AppTypography.headlineMd.copyWith(fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LIVE UPDATES',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Milestone entries
          const _MilestoneEntry(
            dotColor: Color(0xFF8B5CF6),
            iconData: Icons.receipt_long,
            title: 'Order Received',
            dateTime: 'Oct 31, 16:00',
            description: 'Booking and consolidation declared by Sarah Okonjo via Hamza Mobile App.',
            isCompleted: true,
          ),
          const _MilestoneEntry(
            dotColor: Color(0xFF0D9488),
            iconData: Icons.warehouse_outlined,
            title: 'Received at China Warehouse',
            dateTime: 'Nov 01, 10:20',
            description: 'Received domestic vendor parcels at Hamza Guangzhou Baiyun Logistics Depot.',
            isCompleted: true,
          ),
          const _MilestoneEntry(
            dotColor: Color(0xFFF59E0B),
            iconData: Icons.inventory,
            title: 'Processing / Consolidating',
            dateTime: 'Nov 01, 15:40',
            description: 'Assigned to Air Cargo Master ULD Pallet and ready for stikerage.',
            isCompleted: true,
          ),
          const _MilestoneEntry(
            dotColor: Color(0xFF10B981),
            iconData: Icons.flight_takeoff,
            title: 'Shipped from China',
            dateTime: 'Nov 02, 09:15',
            description: 'Air Cargo Flight departed Baiyun International Airport en route to Lagos hub.',
            isCompleted: true,
          ),
          const _MilestoneEntry(
            dotColor: Color(0xFF94A3B8),
            iconData: Icons.flight_land,
            title: 'Arrived in Nigeria',
            dateTime: 'Pending',
            description: 'Flight arrived at Lagos international Air Cargo.',
            isCompleted: false,
          ),
          const _MilestoneEntry(
            dotColor: Color(0xFF94A3B8),
            iconData: Icons.gavel,
            title: 'Customs Clearance',
            dateTime: 'Pending',
            description: 'Lagos Airport Customs formalities and import manifest checks.',
            isCompleted: false,
          ),
          const _MilestoneEntry(
            dotColor: Color(0xFF94A3B8),
            iconData: Icons.local_shipping_outlined,
            title: 'Ready for Delivery',
            dateTime: 'Pending',
            description: 'Package ready for final handover to directed courier dispatch.',
            isCompleted: false,
          ),
          const _MilestoneEntry(
            dotColor: Color(0xFF94A3B8),
            iconData: Icons.check_circle_outline,
            title: 'Delivered',
            dateTime: 'Pending',
            description: 'Package delivered to the final destination.',
            isCompleted: false,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _MilestoneEntry extends StatelessWidget {
  final Color dotColor;
  final IconData iconData;
  final String title;
  final String dateTime;
  final String description;
  final bool isCompleted;
  final bool isLast;

  const _MilestoneEntry({
    required this.dotColor,
    required this.iconData,
    required this.title,
    required this.dateTime,
    required this.description,
    required this.isCompleted,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? dotColor.withValues(alpha: 0.15)
                        : const Color(0xFFF1F5F9),
                  ),
                  child: Icon(
                    iconData,
                    color: isCompleted ? dotColor : const Color(0xFF94A3B8),
                    size: 14,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isCompleted
                                ? AppColors.onBackground
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateTime,
                        style: AppTypography.bodySm.copyWith(
                          color: isCompleted
                              ? AppColors.onSurfaceVariant
                              : const Color(0xFFCBD5E1),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodySm.copyWith(
                      color: isCompleted
                          ? AppColors.onSurfaceVariant
                          : const Color(0xFFCBD5E1),
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── MERGED SUB-PACKAGES ────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _SubPackagesSection extends StatelessWidget {
  const _SubPackagesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              const Icon(Icons.account_tree_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Merged Sub-Packages (3)',
                style: AppTypography.headlineMd.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Consolidated domestic supplier shipments',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),

          // Sub-package items
          _subPackageItem(
            'SF EXPRESS',
            'PSF10492842',
            '5.10 KG',
            'Taobao Smart Watch Silicone Bands',
            'Vendor: Shenzhen High-Tech Store',
            const Color(0xFFCCFBF1),
            AppColors.secondary,
          ),
          const SizedBox(height: 10),
          _subPackageItem(
            'ZTO',
            'KT708B217423',
            '4.80 KG',
            'Shockproof Phone Cases & 9D Temp...',
            'Vendor: Guangzhou Digital Wholesale Hub',
            const Color(0xFFFEF3C7),
            const Color(0xFFD97706),
          ),
          const SizedBox(height: 10),
          _subPackageItem(
            'YTO EXPRESS',
            'YTT4741330194',
            '4.60 KG',
            'Fast Chargers & Braided Type-C Ca...',
            'Vendor: Dongguan Elec-Factory Grovoll',
            const Color(0xFFDBEAFE),
            const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _subPackageItem(
    String carrier,
    String tracking,
    String weight,
    String itemName,
    String vendor,
    Color chipBgColor,
    Color chipTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: carrier badge + tracking + weight
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: chipBgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  carrier,
                  style: AppTypography.bodySm.copyWith(
                    color: chipTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 8,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                tracking,
                style: AppTypography.labelCaps.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              Text(
                weight,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            itemName,
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            vendor,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
