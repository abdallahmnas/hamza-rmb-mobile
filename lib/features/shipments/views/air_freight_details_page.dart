import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class AirFreightDetailsPage extends StatefulWidget {
  const AirFreightDetailsPage({super.key});

  @override
  State<AirFreightDetailsPage> createState() => _AirFreightDetailsPageState();
}

class _AirFreightDetailsPageState extends State<AirFreightDetailsPage> {
  double _weightKg = 5.0;
  static const double _usdRatePerKg = 8.50;
  static const double _ngnPerUsd = 1550.0;
  static const double _rmbPerUsd = 7.25;

  double get _totalUsd => _weightKg * _usdRatePerKg;
  double get _totalNgn => _totalUsd * _ngnPerUsd;
  double get _totalRmb => _totalUsd * _rmbPerUsd;

  void _copyHubAddress() {
    Clipboard.setData(
      const ClipboardData(
        text:
            'Baiyun District, Airport Cargo Rd #18, Guangzhou, Guangdong, China\nCode: HZ-8832-LOS (Air Cargo)',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Guangzhou Air Hub address copied!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Air Freight Service Details',
          style: AppTypography.bodyLg.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.onBackground,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.onBackground),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Corridor Card ─────────────────────────────────────
              _buildHeroCorridorCard(),
              const SizedBox(height: 14),

              // ── 3 Quick Highlight Cards ─────────────────────────────────
              _buildThreeHighlightsRow(),
              const SizedBox(height: 16),

              // ── Sourcing info Card ──────────────────────────────────────
              _buildSourcingInfoCard(),
              const SizedBox(height: 20),

              // ── Cargo Specs & Schedules ─────────────────────────────────
              _buildCargoSpecsSection(),
              const SizedBox(height: 20),

              // ── Cost Estimator Section ──────────────────────────────────
              _buildCostEstimatorCard(),
              const SizedBox(height: 24),

              // ── How Air Freight Works ───────────────────────────────────
              _buildHowItWorksSection(),
              const SizedBox(height: 18),

              // ── CAN Warehouse Address Box ───────────────────────────────
              _buildWarehouseAddressCard(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  // ── Hero Card ─────────────────────────────────────────────────────────────
  Widget _buildHeroCorridorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1017),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Tags
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flight_takeoff, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'CAN  ✈  LOS DIRECT',
                      style: AppTypography.labelCaps.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'ACTIVE CORRIDOR',
                      style: AppTypography.labelCaps.copyWith(
                        color: const Color(0xFFCBD5E1),
                        fontWeight: FontWeight.w600,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Label & Title
          Text(
            'FAST CARGO LINE',
            style: AppTypography.labelCaps.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Guangzhou to Lagos Express',
            style: AppTypography.headlineMd.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),

          // Metric Boxes
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transit Window',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '3-5',
                            style: AppTypography.headlineMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Work Days',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFFCBD5E1),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Standard Air Rate',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$8.50',
                            style: AppTypography.headlineMd.copyWith(
                              color: const Color(0xFFF59E0B),
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/ KG',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Three Highlight Metric Tiles ──────────────────────────────────────────
  Widget _buildThreeHighlightsRow() {
    return Row(
      children: [
        _buildHighlightTile(
          icon: Icons.verified_user_outlined,
          title: 'MMIA\nCleared',
          subtitle: 'Duty Paid',
        ),
        const SizedBox(width: 10),
        _buildHighlightTile(
          icon: Icons.battery_charging_full_rounded,
          title: 'DG /\nBattery',
          subtitle: 'Special Flights',
        ),
        const SizedBox(width: 10),
        _buildHighlightTile(
          icon: Icons.track_changes_rounded,
          title: 'Radar\nPing',
          subtitle: 'Real-time GPS',
        ),
      ],
    );
  }

  Widget _buildHighlightTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF0D9488), size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                height: 1.2,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sourcing Info Card ───────────────────────────────────────────────────
  Widget _buildSourcingInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Sourcing from China Made Swift',
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Engineered for Nigerian merchant enterprises procuring from 1688, Taobao, and factory outlets in Guangzhou, Shenzhen, and Yiwu. Our direct air stream bypasses port congestion with guaranteed weekly aircraft holds, automated customs processing at Murtala Muhammed Airport (LOS), and door delivery in Lagos and interstate terminals.',
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF475569),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'General Cargo: \$8.50/KG',
                  style: AppTypography.labelCaps.copyWith(
                    color: const Color(0xFF1E3A8A),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sensitives/Battery: \$10.20/KG',
                  style: AppTypography.labelCaps.copyWith(
                    color: const Color(0xFF1E3A8A),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Cargo Specs & Schedules ──────────────────────────────────────────────
  Widget _buildCargoSpecsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cargo Specs & Schedules',
          style: AppTypography.bodyLg.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Row 1: Flight Days
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_month_outlined,
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
                            'Flight Days',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.onBackground,
                            ),
                          ),
                          Text(
                            'Guangzhou (CAN) Hub departures',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA7F3D0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Mon · Wed · Fri',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF065F46),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Row 2: Minimum Billable
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.scale_outlined,
                        color: Color(0xFF0284C7),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Minimum Billable',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.onBackground,
                            ),
                          ),
                          Text(
                            'No bulk threshold required',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '1.0 KG',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Row 3: Lagos Hub Terminal
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.verified_outlined,
                        color: Color(0xFF0D9488),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lagos Hub Terminal',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.onBackground,
                            ),
                          ),
                          Text(
                            'Inspection & complete customs clearance',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '100%',
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF10B981),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Cleared',
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Estimate Air Cargo Cost Card ─────────────────────────────────────────
  Widget _buildCostEstimatorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Estimate Air Cargo\nCost',
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 1.2,
                    color: AppColors.onBackground,
                  ),
                ),
              ),
              Text(
                'Peg: \$1 =\n₦1,550',
                textAlign: TextAlign.right,
                style: AppTypography.labelCaps.copyWith(
                  color: const Color(0xFF475569),
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Slider row label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Weight',
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              Text(
                '${_weightKg.toStringAsFixed(1)} KG',
                style: AppTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.black,
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: Colors.black,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: _weightKg,
              min: 1.0,
              max: 50.0,
              divisions: 98,
              onChanged: (val) {
                setState(() {
                  _weightKg = val;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 KG',
                  style: AppTypography.labelCaps.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
                Text(
                  '25 KG',
                  style: AppTypography.labelCaps.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
                Text(
                  '50+ KG',
                  style: AppTypography.labelCaps.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Result box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Naira Total (All Inclusive)',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₦${_formatMoney(_totalNgn)}',
                      style: AppTypography.headlineMd.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: AppColors.onBackground,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Approx. RMB / USD',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¥${_totalRmb.toStringAsFixed(2)} / \$${_totalUsd.toStringAsFixed(2)}',
                      style: AppTypography.labelCaps.copyWith(
                        color: const Color(0xFFD97706),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
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

  // ── How Air Freight Works ─────────────────────────────────────────────────
  Widget _buildHowItWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How Air Freight Works',
          style: AppTypography.bodyLg.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildStepRow(
                number: '01',
                isDark: true,
                title: 'Obtain Your Guangzhou Warehouse ID',
                description:
                    'Copy your designated Hamza Air Hub address containing your unique client identifier code (HZ-8832-LOS).',
              ),
              const SizedBox(height: 18),
              _buildStepRow(
                number: '02',
                isDark: false,
                title: "Ship from Supplier or 'Buy For Me'",
                description:
                    'Instruct your 1688 manufacturer or Taobao merchant to deliver parcels locally to our Guangzhou sorting facility.',
              ),
              const SizedBox(height: 18),
              _buildStepRow(
                number: '03',
                isDark: false,
                title: 'Submit Air Pre-Alert',
                description:
                    'Upload the local Chinese courier tracking number (e.g., ZTO, SF Express) in-app for prompt flight manifests.',
              ),
              const SizedBox(height: 18),
              _buildStepRow(
                number: '04',
                isDark: false,
                title: 'MMIA Release & Door Delivery',
                description:
                    'Track real-time flight stages. Collect in Ikeja Hub or request direct nationwide motor dispatch to your shop.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow({
    required String number,
    required bool isDark,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark ? Colors.black : const Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.labelCaps.copyWith(
                color: isDark ? Colors.white : const Color(0xFF2563EB),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── CAN Warehouse Address Card ───────────────────────────────────────────
  Widget _buildWarehouseAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CAN WAREHOUSE ADDRESS',
                style: AppTypography.labelCaps.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'AIR DIVISION ONLY',
                style: AppTypography.labelCaps.copyWith(
                  color: const Color(0xFF0284C7),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Baiyun District, Airport Cargo Rd #18, Guangz...',
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: AppColors.onBackground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'HZ-8832-LOS (Air Cargo)',
                        style: AppTypography.labelCaps.copyWith(
                          color: const Color(0xFFEA580C),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _copyHubAddress,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Fixed Action Bar ──────────────────────────────────────────────
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Copy Hub Button
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: _copyHubAddress,
                icon: const Icon(Icons.copy_outlined, size: 16),
                label: Text(
                  'Copy Hub',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onBackground,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Start Air Shipment Button
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/pre-alert'),
                icon: const Icon(Icons.add_box_outlined, size: 16),
                label: Text(
                  'Start Air Shipment',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMoney(double amount) {
    final intValue = amount.round();
    final str = intValue.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join();
  }
}
