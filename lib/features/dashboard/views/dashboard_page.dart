import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_service.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final PageController _bannerPageController = PageController();
  int _currentBannerIndex = 0;

  @override
  void dispose() {
    _bannerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authServiceProvider);
    final isLoggedIn = authState.isLoggedIn;
    final displayName = authState.displayName ?? 'Sarah Okonjo';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Header Profile Bar ───────────────────────────────
                _buildTopHeaderBar(context, isLoggedIn, displayName),
                const SizedBox(height: 16),

                // ── Top Promo Carousel Banner Card ───────────────────────
                _buildPromoCarouselBanner(context),
                const SizedBox(height: 20),

                // ── "● All Services" Grid Section ────────────────────────
                _buildAllServicesSection(context),
                const SizedBox(height: 16),

                // ── Live Tracking & Milestones Bar ────────────────────────
                _buildLiveTrackingBar(context),
                const SizedBox(height: 24),

                // ── Logistics Shortcuts ───────────────────────────────────
                _buildLogisticsShortcuts(context),
                const SizedBox(height: 24),

                // ── Live Shipment Card ────────────────────────────────────
                _buildLiveShipmentSection(context),
                const SizedBox(height: 90), // Bottom padding for shell nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 1. Top Header Profile Bar ─────────────────────────────────────────────
  Widget _buildTopHeaderBar(
    BuildContext context,
    bool isLoggedIn,
    String displayName,
  ) {
    return Row(
      children: [
        // Avatar with status indicator
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF0F473E),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'SO',
                  style: AppTypography.bodyLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      isLoggedIn ? displayName : 'Sarah Oko...',
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.onBackground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEDBB2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'VIP',
                      style: AppTypography.labelCaps.copyWith(
                        color: const Color(0xFF78350F),
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF64748B),
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Lagos, NG',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Exchange rate pill
        GestureDetector(
          onTap: () => context.push('/exchange'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0284C7),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '¥1 = ₦228.5',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF0369A1),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF0284C7),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 2. Top Promo Carousel Banner Card ─────────────────────────────────────
  Widget _buildPromoCarouselBanner(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView(
            controller: _bannerPageController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            children: [
              // Slide 1: Air Express
              _buildAirExpressBannerSlide(context),
              // Slide 2: Sea Freight
              _buildSeaFreightBannerSlide(context),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _currentBannerIndex == 0 ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentBannerIndex == 0
                    ? const Color(0xFF0D9488)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _currentBannerIndex == 1 ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentBannerIndex == 1
                    ? const Color(0xFF0D9488)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAirExpressBannerSlide(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F14),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient circular gradient
          Positioned(
            right: -20,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D9488).withValues(alpha: 0.25),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top tag & flight icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DD4BF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'EXPRESS FLIGHT',
                      style: AppTypography.labelCaps.copyWith(
                        color: const Color(0xFF042F2E),
                        fontWeight: FontWeight.w800,
                        fontSize: 9.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.flight_takeoff_rounded,
                    color: Color(0xFF2DD4BF),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                'Air Express: 3-5 Days Direct',
                style: AppTypography.headlineMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18.5,
                ),
              ),
              const SizedBox(height: 5),

              // Subtitle
              Text(
                'Daily departures Guangzhou (CAN) to Lagos (LOS).\nFast-track clearance included.',
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const Spacer(),

              // Action Link
              GestureDetector(
                onTap: () => context.push('/air-freight'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Book space now',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF2DD4BF),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF2DD4BF),
                      size: 15,
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

  Widget _buildSeaFreightBannerSlide(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF031622),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0284C7).withValues(alpha: 0.25),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'OCEAN ROUTE',
                      style: AppTypography.labelCaps.copyWith(
                        color: const Color(0xFF082F49),
                        fontWeight: FontWeight.w800,
                        fontSize: 9.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.directions_boat_rounded,
                    color: Color(0xFF38BDF8),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Sea Cargo: From \$190 / CBM',
                style: AppTypography.headlineMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Container loads & groupage straight to Apapa & Tincan.\nCustoms clearance included.',
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/sea-freight'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get quote',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF38BDF8),
                      size: 15,
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

  // ── 3. "● All Services" 6-Card Grid ───────────────────────────────────────
  Widget _buildAllServicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D9488),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'All Services',
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppColors.onBackground,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  size: 13,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 3),
                Text(
                  'ACTIVE',
                  style: AppTypography.labelCaps.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 1: Air Freight & Sea Freight
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                title: 'Air Freight',
                description: 'Direct air cargo dispatch from China hubs to Lagos.',
                actionText: 'Book flight',
                badgeText: '3-5 DAYS',
                icon: Icons.flight_takeoff_rounded,
                gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                onTap: () => context.push('/air-freight'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildServiceCard(
                title: 'Sea Freight',
                description: 'Large volume CBM, container loads &...',
                actionText: 'Get quote',
                badgeText: 'FROM \$190',
                icon: Icons.directions_boat_rounded,
                gradientColors: const [Color(0xFF0D9488), Color(0xFF0F766E)],
                onTap: () => context.push('/sea-freight'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Consolidation & Buy For Me
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                title: 'Consolidation',
                description: 'Merge multiple 1688 / Taobao parcels into 1...',
                actionText: 'Start packing',
                badgeText: 'SAVE 35%',
                icon: Icons.inventory_2_outlined,
                gradientColors: const [Color(0xFFEA580C), Color(0xFFF97316)],
                onTap: () => context.push('/consolidate'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildServiceCard(
                title: 'Buy For Me',
                description: 'Sourcing, negotiation & factory inspection.',
                actionText: 'Request item',
                badgeText: '0% AGENT',
                icon: Icons.shopping_cart_outlined,
                gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
                onTap: () => context.push('/buy-for-me'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 3: RMB Exchange & Local Delivery
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                title: 'RMB Exchange',
                description: 'Instant NGN to Alipay, WeChat & bank pay.',
                actionText: 'Swap now',
                badgeText: 'INSTANT',
                icon: Icons.currency_exchange_rounded,
                gradientColors: const [Color(0xFFDC2626), Color(0xFFEF4444)],
                onTap: () => context.push('/exchange'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildServiceCard(
                title: 'Local Delivery',
                description: 'Dispatch across Lagos Mainland, Island & States.',
                actionText: 'Send parcel',
                badgeText: 'DOORSTEP',
                icon: Icons.local_shipping_outlined,
                gradientColors: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                onTap: () => _showDeliveryDialog(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String description,
    required String actionText,
    required String badgeText,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 172,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon container + Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTypography.labelCaps.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              title,
              style: AppTypography.bodyLg.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
              ),
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              description,
              style: AppTypography.bodySm.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Bottom Action link + Circle Arrow Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  actionText,
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 4. Live Tracking & Milestones Bar ─────────────────────────────────────
  Widget _buildLiveTrackingBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/live-tracking'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Radar Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.radar_rounded,
                color: Color(0xFF2DD4BF),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Tracking & Milestones',
                    style: AppTypography.bodyMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Real-time status from Guangzhou hub to ...',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // GPS LIVE Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF042F2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'GPS',
                        style: AppTypography.labelCaps.copyWith(
                          color: const Color(0xFF2DD4BF),
                          fontWeight: FontWeight.w800,
                          fontSize: 7,
                        ),
                      ),
                      Text(
                        'LIVE',
                        style: AppTypography.labelCaps.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Arrow button
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 5. Logistics Shortcuts ────────────────────────────────────────────────
  Widget _buildLogisticsShortcuts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOGISTICS SHORTCUTS',
          style: AppTypography.labelCaps.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 10,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildShortcutButton(
                icon: Icons.store_outlined,
                label: 'China Hub',
                onTap: () => context.push('/warehouse-addresses'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildShortcutButton(
                icon: Icons.calculate_outlined,
                label: 'Calculator',
                onTap: () => context.push('/air-freight'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildShortcutButton(
                icon: Icons.notification_add_outlined,
                label: 'Pre-Alert',
                onTap: () => context.push('/pre-alert'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildShortcutButton(
                icon: Icons.support_agent_outlined,
                label: 'Help Line',
                onTap: () => context.push('/support-tickets'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShortcutButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF0284C7), size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── 6. Live Shipment Card ─────────────────────────────────────────────────
  Widget _buildLiveShipmentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFF0D9488),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Live Shipment',
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.onBackground,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => context.push('/track'),
              child: Text(
                'VIEW ALL (4)',
                style: AppTypography.labelCaps.copyWith(
                  color: const Color(0xFF0284C7),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Route Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row tags
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'AIR-EXPRESS',
                          style: AppTypography.labelCaps.copyWith(
                            color: const Color(0xFF0369A1),
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HZ-8839-LOS',
                        style: AppTypography.labelCaps.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'IN FLIGHT',
                      style: AppTypography.labelCaps.copyWith(
                        color: const Color(0xFFB45309),
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Route Display: Origin -> Airplane/Bar -> Destination
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Origin
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CAN Guangzhou',
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Departed Nov 20',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  // Center Route Bar
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Text(
                            'ETA: 18h',
                            style: AppTypography.labelCaps.copyWith(
                              color: const Color(0xFF0D9488),
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0D9488),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: const Color(0xFF0D9488),
                                ),
                              ),
                              const Icon(
                                Icons.flight,
                                color: Color(0xFF0D9488),
                                size: 14,
                              ),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFCBD5E1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '2.4 kg · 3 pkgs',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Destination
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LOS Ikeja Hub',
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Expected Nov 22',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bottom bar container: "Electronics & Textile Samples" + "TRACK LIVE"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFF0284C7),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Electronics & Textile Samples',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onBackground,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push('/live-tracking'),
                      child: Text(
                        'TRACK LIVE',
                        style: AppTypography.labelCaps.copyWith(
                          color: const Color(0xFF0284C7),
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
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

  void _showDeliveryDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              color: Color(0xFF7C3AED),
            ),
            const SizedBox(width: 8),
            Text(
              'Local Delivery',
              style: AppTypography.headlineMd.copyWith(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Doorstep delivery dispatch is available across Lagos and all Nigerian states from our Ikeja Central Hub.',
          style: AppTypography.bodyMd.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/support-tickets');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
            ),
            child: const Text('Book Delivery'),
          ),
        ],
      ),
    );
  }
}
