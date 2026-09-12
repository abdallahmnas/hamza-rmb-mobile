import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class SeaFreightDetailsPage extends StatefulWidget {
  const SeaFreightDetailsPage({super.key});

  @override
  State<SeaFreightDetailsPage> createState() => _SeaFreightDetailsPageState();
}

class _SeaFreightDetailsPageState extends State<SeaFreightDetailsPage> {
  bool _isDimensionsMode = true;
  double _lengthCm = 100;
  double _widthCm = 80;
  double _heightCm = 120;
  int _quantity = 1;
  double _directCbm = 0.96;

  static const double _ratePerCbmUsd = 190.0;
  static const double _ngnPerUsd = 1500.0;

  double get _calculatedCbm {
    if (_isDimensionsMode) {
      final singleCbm = (_lengthCm * _widthCm * _heightCm) / 1000000.0;
      return singleCbm * _quantity;
    }
    return _directCbm * _quantity;
  }

  double get _totalUsd => _calculatedCbm * _ratePerCbmUsd;
  double get _totalNgn => _totalUsd * _ngnPerUsd;

  void _copySeaWarehouseAddress() {
    Clipboard.setData(
      const ClipboardData(
        text:
            'Hamza Sea Freight Logistics Hub, Nanhai District, Foshan, Guangdong, China\nCode: HZ-SEA-8992',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sea Freight Warehouse address copied!'),
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
          'Sea Freight Service Details',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Corridor Notice Ribbon ───────────────────────────────
              _buildTopNoticeRibbon(),
              const SizedBox(height: 12),

              // ── Hero Maritime Card ──────────────────────────────────────
              _buildHeroMaritimeCard(),
              const SizedBox(height: 16),

              // ── What is Sea Freight Cargo? ──────────────────────────────
              _buildWhatIsSeaFreightCard(),
              const SizedBox(height: 20),

              // ── Why Ship by Ocean? ───────────────────────────────────────
              _buildWhyShipByOceanSection(),
              const SizedBox(height: 20),

              // ── CBM Shipping Calculator ──────────────────────────────────
              _buildCbmCalculatorSection(),
              const SizedBox(height: 24),

              // ── How Sea Freight Works ────────────────────────────────────
              _buildHowSeaFreightWorksSection(),
              const SizedBox(height: 24),

              // ── Guidelines & Prohibited Items ────────────────────────────
              _buildGuidelinesAccordionSection(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  // ── Top Notice Ribbon ─────────────────────────────────────────────────────
  Widget _buildTopNoticeRibbon() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF0D9488),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_boat, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'CHINA TO LAGOS OCEAN RO...',
              style: AppTypography.labelCaps.copyWith(
                color: const Color(0xFF1E3A8A),
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.dns_outlined, color: Color(0xFF0D9488), size: 10),
                const SizedBox(width: 4),
                Text(
                  'CBM CARGO',
                  style: AppTypography.labelCaps.copyWith(
                    color: const Color(0xFF0D9488),
                    fontWeight: FontWeight.w800,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Maritime Card ────────────────────────────────────────────────────
  Widget _buildHeroMaritimeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E1A29), Color(0xFF082238), Color(0xFF031622)],
        ),
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
          // Graphic container with ship representation
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1E3A5F).withValues(alpha: 0.8),
                  const Color(0xFF0D253F),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Stylized decorative ocean wave lines
                Positioned(
                  bottom: -10,
                  left: -20,
                  right: -20,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0284C7).withValues(alpha: 0.3),
                          const Color(0xFF0D9488).withValues(alpha: 0.4),
                          const Color(0xFF0C4A6E).withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.elliptical(200, 30),
                      ),
                    ),
                  ),
                ),
                // Ship icon / silhouette
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_boat_filled_rounded,
                        size: 46,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'VESSEL CARGO LINE • GUANGZHOU / FOSHAN',
                        style: AppTypography.labelCaps.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 8,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Top Tags
                Positioned(
                  top: 12,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.all_inbox_rounded,
                              color: Colors.white,
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'FCL & LCL Groupage',
                              style: AppTypography.labelCaps.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
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
                          color: const Color(0xFFD97706).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.sell_outlined,
                              color: Colors.white,
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'From \$190 / CBM',
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
                ),
              ],
            ),
          ),

          // Content below graphic
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFF2DD4BF),
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'TRANSIT TIME',
                      style: AppTypography.labelCaps.copyWith(
                        color: const Color(0xFF2DD4BF),
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '35 – 45 Days',
                  style: AppTypography.headlineMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Port-to-Door • Direct vessel calls into Apapa & Tincan',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),

                // 3 Stats Row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildHeroStatColumn('DEPARTS', 'Bi-Weekly', Colors.white),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      _buildHeroStatColumn(
                        'WEIGHT CAP',
                        'Unlimited',
                        const Color(0xFF2DD4BF),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      _buildHeroStatColumn(
                        'CUSTOMS',
                        'Full Clearance',
                        const Color(0xFFFBBF24),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatColumn(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelCaps.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.bodySm.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── What is Sea Freight Cargo? ────────────────────────────────────────────
  Widget _buildWhatIsSeaFreightCard() {
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
                'What is Sea Freight Cargo?',
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
            'Our premium maritime channel engineered specifically for African importers and e-commerce merchants. Move bulky industrial stock, manufacturing equipment, raw components, and oversized retail pallets straight from industrial hubs in Guangzhou, Foshan, Yiwu, and Ningbo to Lagos, Nigeria with uncompromising security.',
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF475569),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDCFCE7)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            color: Color(0xFF16A34A),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Bulky Items',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: AppColors.onBackground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Furniture, gym fixtures, homeware & sanitary fittings.',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.precision_manufacturing_outlined,
                            color: Color(0xFF2563EB),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Heavy Machinery',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: AppColors.onBackground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Industrial motors, agro mills & packaging equipment.',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 10,
                          height: 1.3,
                        ),
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

  // ── Why Ship by Ocean? ────────────────────────────────────────────────────
  Widget _buildWhyShipByOceanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Why Ship by Ocean?',
              style: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.onBackground,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'MAX ROI',
                style: AppTypography.labelCaps.copyWith(
                  color: const Color(0xFF0D9488),
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Benefit 1
              _buildBenefitRow(
                icon: Icons.savings_outlined,
                iconBg: const Color(0xFFA7F3D0),
                iconColor: const Color(0xFF065F46),
                title: '70% Cost Reduction',
                badgeText: 'Economy',
                badgeColor: const Color(0xFF2563EB),
                badgeBg: const Color(0xFFEFF6FF),
                description:
                    'Slash landing costs drastically compared to express air freight. Save capital to scale larger factory purchase volumes.',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              // Benefit 2
              _buildBenefitRow(
                icon: Icons.local_mall_outlined,
                iconBg: const Color(0xFFE0E7FF),
                iconColor: const Color(0xFF4338CA),
                title: 'No Strict Weight Pe...',
                badgeText: 'Density Free',
                badgeColor: const Color(0xFF1E3A8A),
                badgeBg: const Color(0xFFDBEAFE),
                description:
                    'Billed strictly by space (Cubic Metres). Ideal for heavy hardware, ceramics, metals, liquids, and automotive spares.',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              // Benefit 3
              _buildBenefitRow(
                icon: Icons.local_shipping_outlined,
                iconBg: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFC2410C),
                title: 'All-Inclusive Terminal ...',
                badgeText: 'Door Ready',
                badgeColor: const Color(0xFFFDE68A),
                badgeBg: const Color(0xFF292524),
                description:
                    'Zero hidden customs surcharges or terminal demurrage headaches. Seamless handover at our secure Ikeja/Trade Fair hubs or your door.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.onBackground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: AppTypography.bodySm.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
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

  // ── CBM Shipping Calculator ──────────────────────────────────────────────
  Widget _buildCbmCalculatorSection() {
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESTIMATOR ENGINE',
                    style: AppTypography.labelCaps.copyWith(
                      color: const Color(0xFFD97706),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'CBM Shipping Calculator',
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.onBackground,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'LCL Cargo',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mode switcher tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDimensionsMode = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isDimensionsMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _isDimensionsMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        'Dimensions (cm)',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: _isDimensionsMode
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 11,
                          color: _isDimensionsMode
                              ? AppColors.onBackground
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDimensionsMode = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isDimensionsMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !_isDimensionsMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        'Direct CBM',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: !_isDimensionsMode
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 11,
                          color: !_isDimensionsMode
                              ? AppColors.onBackground
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Dimensions inputs
          if (_isDimensionsMode) ...[
            Row(
              children: [
                Expanded(
                  child: _buildDimInputField(
                    label: 'LENGTH',
                    value: _lengthCm.toStringAsFixed(0),
                    unit: 'cm',
                    onChanged: (val) {
                      setState(() {
                        _lengthCm = double.tryParse(val) ?? 100;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDimInputField(
                    label: 'WIDTH',
                    value: _widthCm.toStringAsFixed(0),
                    unit: 'cm',
                    onChanged: (val) {
                      setState(() {
                        _widthCm = double.tryParse(val) ?? 80;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDimInputField(
                    label: 'HEIGHT',
                    value: _heightCm.toStringAsFixed(0),
                    unit: 'cm',
                    onChanged: (val) {
                      setState(() {
                        _heightCm = double.tryParse(val) ?? 120;
                      });
                    },
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildDimInputField(
              label: 'ENTER TOTAL CBM',
              value: _directCbm.toStringAsFixed(2),
              unit: 'CBM',
              onChanged: (val) {
                setState(() {
                  _directCbm = double.tryParse(val) ?? 1.0;
                });
              },
            ),
          ],
          const SizedBox(height: 16),

          // Carton / Package Quantity Stepper
          Text(
            'CARTON / PACKAGE QUANTITY',
            style: AppTypography.labelCaps.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() => _quantity--);
                    }
                  },
                  icon: const Icon(Icons.remove, color: Colors.black, size: 18),
                ),
                Text(
                  '$_quantity',
                  style: AppTypography.headlineMd.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.onBackground,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _quantity++);
                  },
                  icon: const Icon(Icons.add, color: Colors.black, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Calculation Result Box (Dark Slate Card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CALCULATED VOLUME',
                          style: AppTypography.labelCaps.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_calculatedCbm.toStringAsFixed(2)} CBM',
                          style: AppTypography.headlineMd.copyWith(
                            color: const Color(0xFF38BDF8),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'BASE RATE',
                          style: AppTypography.labelCaps.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$190 / CBM',
                          style: AppTypography.bodySm.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'ESTIMATED FREIGHT FEE',
                  style: AppTypography.labelCaps.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₦${_formatMoney(_totalNgn)}',
                      style: AppTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(\$${_totalUsd.toStringAsFixed(2)} USD)',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFFFBBF24),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF10B981),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Includes sea bill of lading & customs documentation',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
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

  Widget _buildDimInputField({
    required String label,
    required String value,
    required String unit,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelCaps.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: value,
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.onBackground,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ),
              Text(
                unit,
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── How Sea Freight Works ─────────────────────────────────────────────────
  Widget _buildHowSeaFreightWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  'How Sea Freight Works',
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.onBackground,
                  ),
                ),
              ],
            ),
            Text(
              '4 SIMPLE STEPS',
              style: AppTypography.labelCaps.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 9,
              ),
            ),
          ],
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
              _buildSeaStepRow(
                number: '1',
                title: 'Obtain Sea Warehouse Address',
                description:
                    'Each client gets a unique Sea shipping code (HZ-SEA-8992) to stamp on all pallets.',
                hasCopy: true,
                onCopy: _copySeaWarehouseAddress,
              ),
              const SizedBox(height: 16),
              _buildSeaStepRow(
                number: '2',
                title: 'Supplier Dispatches Pallets',
                description:
                    'Your manufacturer delivers to our Guangzhou / Foshan consolidation hubs with your marks clearly visible.',
              ),
              const SizedBox(height: 16),
              _buildSeaStepRow(
                number: '3',
                title: 'Packing List & Pre-Alert',
                description:
                    'Upload your invoice or itemized goods declaration in-app to verify container loading schedules.',
              ),
              const SizedBox(height: 16),
              _buildSeaStepRow(
                number: '4',
                title: 'Arrival Notice & Lagos Dispatch',
                description:
                    'Once cleared through Tincan Port, collect at our warehouse or trigger regional doorstep trailer delivery.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeaStepRow({
    required String number,
    required String title,
    required String description,
    bool hasCopy = false,
    VoidCallback? onCopy,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF0D9488),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.labelCaps.copyWith(
                color: Colors.white,
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
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.onBackground,
                      ),
                    ),
                  ),
                  if (hasCopy) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onCopy,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.copy,
                              color: Color(0xFF2563EB),
                              size: 10,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Copy',
                              style: AppTypography.labelCaps.copyWith(
                                color: const Color(0xFF2563EB),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
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

  // ── Guidelines & Prohibited Items ─────────────────────────────────────────
  Widget _buildGuidelinesAccordionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guidelines & Prohibited Items',
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
              _buildAccordionItem(
                icon: Icons.cancel_outlined,
                iconColor: const Color(0xFFDC2626),
                title: 'What items CANNOT go via Sea Freight?',
                content:
                    'Hazardous chemical compounds, uncertified standalone lithium battery packs, flammable pressurized aerosols, ammunition, and counterfeit trademarked replicas. All other commercial and industrial goods are fully eligible.',
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildAccordionItem(
                icon: Icons.account_balance_outlined,
                iconColor: const Color(0xFF0D9488),
                title: 'What is the minimum volume accepted?',
                content:
                    'For LCL (Less than Container Load) groupage consolidation, the minimum billable space is 0.1 CBM. For FCL (Full Container Load) we provide 20ft and 40ft high cube containers upon request.',
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildAccordionItem(
                icon: Icons.payments_outlined,
                iconColor: const Color(0xFFD97706),
                title: 'How do I settle the shipping fee?',
                content:
                    'Shipping fees are calculated upon container departure and can be paid anytime before cargo collection in Lagos via your Hamza RMB wallet, direct NGN transfer, or RMB bank swap.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccordionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: iconColor, size: 20),
      title: Text(
        title,
        style: AppTypography.bodySm.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: AppColors.onBackground,
        ),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      iconColor: const Color(0xFF64748B),
      collapsedIconColor: const Color(0xFF94A3B8),
      shape: const Border(),
      children: [
        Text(
          content,
          style: AppTypography.bodySm.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ],
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
            // Get Estimate Button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Estimate: ${_calculatedCbm.toStringAsFixed(2)} CBM = ₦${_formatMoney(_totalNgn)}',
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.list_alt_rounded, size: 16),
                label: Text(
                  'Get Estimate',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF6FF),
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Book Sea Freight Button
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/pre-alert'),
                icon: const Icon(Icons.anchor_rounded, size: 16),
                label: Text(
                  'Book Sea Freight',
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
