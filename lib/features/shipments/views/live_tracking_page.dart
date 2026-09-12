import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class LiveTrackingPage extends StatefulWidget {
  const LiveTrackingPage({super.key});

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  final TextEditingController _waybillController =
      TextEditingController(text: 'HZ-AWB-8920412-CN');

  @override
  void dispose() {
    _waybillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ───────────────────────────────────────────────
            _buildAppBar(),

            // ── Scrollable Content ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Search bar
                    _buildSearchBar(),

                    const SizedBox(height: 16),

                    // Shipment header card
                    const _ShipmentHeaderCard(),

                    const SizedBox(height: 24),

                    // Consolidated Cargo Specs
                    const _CargoSpecsSection(),

                    const SizedBox(height: 24),

                    // Checkpoint History
                    const _CheckpointHistorySection(),

                    const SizedBox(height: 24),

                    // Proof photos
                    const _ProofPhotosSection(),

                    const SizedBox(height: 20),

                    // Action buttons
                    _buildActionButtons(),

                    const SizedBox(height: 16),

                    // Help banner
                    _buildHelpBanner(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.background,
      child: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'HZ',
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HAMZA RMB',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                  letterSpacing: 0.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                'Live Cargo Tracking',
                style: AppTypography.headlineMd.copyWith(fontSize: 16),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.onBackground,
              size: 22,
            ),
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.secondary,
            child: Text(
              'S',
              style: AppTypography.bodySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          children: [
            Text(
              'LIVE WAYBILL ENQUIRY',
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 9,
                letterSpacing: 0.8,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Global Radar Active',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Search field
        Row(
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
                    const Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _waybillController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter waybill number...',
                          hintStyle: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radar, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Track',
                    style: AppTypography.bodySm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Action Buttons ───────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined, size: 16),
              label: Text(
                'Share Tracking',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onBackground,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.receipt_long_outlined, size: 16),
              label: Text(
                'Waybill Slip',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onBackground,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Help Banner ──────────────────────────────────────────────────────────
  Widget _buildHelpBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.headset_mic_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need assistance with this flight?',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lagos clearance desk is online',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chat Now',
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── SHIPMENT HEADER CARD ───────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ShipmentHeaderCard extends StatelessWidget {
  const _ShipmentHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waybill + status row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Waybill info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WAYBILL NUMBER',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'HZ-AWB-\n8920412-CN',
                            style: AppTypography.headlineLg.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'IN TRANSIT •',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            'FLIGHT CZ-3055',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Route visualization
                _buildRouteVisualization(),

                const SizedBox(height: 16),

                // Bottom stats
                Row(
                  children: [
                    _buildStatItem(
                      Icons.calendar_today_outlined,
                      'Estimated\nArrival',
                      'Nov 04,\n2024',
                    ),
                    const Spacer(),
                    _buildStatItem(
                      Icons.linear_scale,
                      'Stage 3 / 5',
                      '(60%)',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Progress bar
          Container(
            height: 4,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              color: Color(0xFF2D3748),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.secondary, Color(0xFF2DD4BF)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const Expanded(flex: 40, child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteVisualization() {
    return Row(
      children: [
        // Origin
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'CAN • GUANGZHOU',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                    fontSize: 8,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Guangzhou\nHub',
                style: AppTypography.bodyMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Baiyun Int\'l',
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        // Airplane icon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.flight,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Express',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        // Destination
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LOS • LAGOS',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                    fontSize: 8,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Lagos\nHub',
                style: AppTypography.bodyMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.2,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 3),
              Text(
                'Ikeja Cargo Depot',
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 14),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 9,
                height: 1.3,
              ),
            ),
            Text(
              value,
              style: AppTypography.bodySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── CARGO SPECS SECTION ────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _CargoSpecsSection extends StatelessWidget {
  const _CargoSpecsSection();

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
              const Icon(Icons.inventory_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Consolidated Cargo\nSpecs',
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
          const SizedBox(height: 16),

          // Specs grid
          Row(
            children: [
              Expanded(
                child: _buildSpecItem(Icons.scale, 'Gross Weight', '14.50 KG'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSpecItem(Icons.view_in_ar, 'CBM Volume', '0.062 CBM'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSpecItem(Icons.widgets_outlined, 'Units Packed', '3 Parcels (Ma...'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSpecItem(Icons.description_outlined, 'Manifest\nContent', 'Electronics/A...'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
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
// ── CHECKPOINT HISTORY SECTION ─────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _CheckpointHistorySection extends StatelessWidget {
  const _CheckpointHistorySection();

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
                'Checkpoint History',
                style: AppTypography.headlineMd.copyWith(fontSize: 16),
              ),
              const Spacer(),
              Text(
                '5 Events Logged',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timeline entries
          const _CheckpointEntry(
            dotColor: Color(0xFFEF4444),
            title: 'Flight Departed CAN',
            dateTime: 'Nov 02 · 14:30',
            description:
                'Departed Guangzhou Baiyun Int\'l Airport aboard commercial flight CZ-3055. En route to transit connection.',
            location: 'Guangzhou Baiyun Airport (CAN), China',
            isFirst: true,
          ),
          const _CheckpointEntry(
            dotColor: Color(0xFF2563EB),
            title: 'Customs Clearance Passed',
            dateTime: 'Nov 02 · 09:15',
            description:
                'China export declaration verified, duty tax processed, and airport security scan completed.',
          ),
          const _CheckpointEntry(
            dotColor: Color(0xFFF59E0B),
            title: 'Palletized & Weighed',
            dateTime: 'Nov 01 · 15:40',
            description:
                'Secured onto consolidated Air cargo pallet #PL-CAN-9812. Ready for airport handover.',
          ),
          const _CheckpointEntry(
            dotColor: Color(0xFF0D9488),
            title: 'Warehouse Intake & Inspection',
            dateTime: 'Nov 01 · 11:20',
            description:
                'Received 3 supplier packages. Full visual quality inspection passed and recorded.',
            hasProof: true,
            proofText: '3 Proof Photos Attached',
          ),
          const _CheckpointEntry(
            dotColor: Color(0xFF8B5CF6),
            title: 'Pre-Alert Created',
            dateTime: 'Oct 31 · 16:00',
            description:
                'Customer registered electronic shipment alert via Hamza RMB Mobile Client.',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _CheckpointEntry extends StatelessWidget {
  final Color dotColor;
  final String title;
  final String dateTime;
  final String description;
  final String? location;
  final bool hasProof;
  final String? proofText;
  final bool isFirst;
  final bool isLast;

  const _CheckpointEntry({
    required this.dotColor,
    required this.title,
    required this.dateTime,
    required this.description,
    this.location,
    this.hasProof = false,
    this.proofText,
    this.isFirst = false,
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
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: Border.all(
                      color: dotColor.withValues(alpha: 0.3),
                      width: 3,
                    ),
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
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + date row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        dateTime,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                  if (location != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.onSurfaceVariant,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location!,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.secondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (hasProof && proofText != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_library_outlined,
                            color: Color(0xFF7C3AED),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            proofText!,
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF7C3AED),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
// ── PROOF PHOTOS SECTION ───────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ProofPhotosSection extends StatelessWidget {
  const _ProofPhotosSection();

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
              const Icon(Icons.photo_camera_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Guangzhou Intake Proofs',
                style: AppTypography.headlineMd.copyWith(fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Time-Stamped',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Photo placeholders
          Row(
            children: [
              _buildPhotoPlaceholder(Icons.inventory_2_outlined, 'Package\nCarton'),
              const SizedBox(width: 10),
              _buildPhotoPlaceholder(Icons.verified_outlined, 'Weight\nVerification'),
              const SizedBox(width: 10),
              _buildPhotoPlaceholder(Icons.qr_code, 'Waybill\nBarcode'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(IconData icon, String label) {
    return Expanded(
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
