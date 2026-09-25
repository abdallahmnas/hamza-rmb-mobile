import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_service.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../home/data/models/banner_model.dart';
import '../../home/presentation/providers/system_metadata_provider.dart';
import '../../shipments/presentation/providers/shipments_provider.dart';
import '../../customs_clearance/data/models/clearance_request_model.dart';
import '../../customs_clearance/presentation/providers/customs_clearance_provider.dart';
import '../../wallet/presentation/providers/wallet_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final PageController _bannerPageController = PageController();
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(systemMetadataProvider.notifier).refreshAll();
      ref.read(shipmentsProvider.notifier).fetchAll();
      ref.read(walletProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authServiceProvider);
    final metadataState = ref.watch(systemMetadataProvider);
    final isLoggedIn = authState.isLoggedIn;
    final displayName = authState.user?.fullName.isNotEmpty == true
        ? authState.user!.fullName
        : (authState.displayName ?? 'Guest User');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(systemMetadataProvider.notifier).refreshAll(isUserInitiated: true),
              ref.read(shipmentsProvider.notifier).fetchAll(isUserInitiated: true),
              ref.read(walletProvider.notifier).refresh(),
              if (isLoggedIn) ref.read(authServiceProvider.notifier).refreshProfile(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Header Profile Bar ───────────────────────────────
                  _buildTopHeaderBar(context, isLoggedIn, displayName, metadataState),
                  const SizedBox(height: 16),

                  // ── Top Promo Carousel Banner Card ───────────────────────
                  _buildPromoCarouselBanner(context, metadataState),
                  const SizedBox(height: 20),

                  // ── "● All Services" Grid Section ────────────────────────
                  _buildAllServicesSection(context, metadataState),
                  const SizedBox(height: 16),

                  // ── Customs Clearance Dashboard Card (Requirement #20) ───
                  _buildCustomsClearanceDashboardCard(context),
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
      ),
    );
  }

  // ── 1. Top Header Profile Bar ─────────────────────────────────────────────
  Widget _buildTopHeaderBar(
    BuildContext context,
    bool isLoggedIn,
    String displayName,
    SystemMetadataState metadataState,
  ) {
    final initials = displayName.trim().isNotEmpty
        ? displayName
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .take(2)
            .join()
        : 'HZ';

    final cnyRate = metadataState.settings.cnyExchangeRate > 0
        ? metadataState.settings.cnyExchangeRate
        : (metadataState.exchangeRate.platformRate > 0
            ? metadataState.exchangeRate.platformRate
            : 215.0);

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
                  initials.isNotEmpty ? initials : 'HZ',
                  style: AppTypography.bodyLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
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
                  color: isLoggedIn ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
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
                      isLoggedIn ? displayName : 'Welcome, Guest',
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
                      isLoggedIn ? 'MEMBER' : 'VISITOR',
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
                    'Nigeria Hub',
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
                  '¥1 = ₦${cnyRate.toStringAsFixed(cnyRate.truncateToDouble() == cnyRate ? 0 : 1)}',
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
  Widget _buildPromoCarouselBanner(BuildContext context, SystemMetadataState metadataState) {
    final banners = metadataState.banners;
    final bannerCount = banners.isNotEmpty ? banners.length : 2;

    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _bannerPageController,
            itemCount: bannerCount,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              if (banners.isNotEmpty) {
                final banner = banners[index];
                return _buildDynamicBannerSlide(context, banner, metadataState);
              }
              return index == 0
                  ? _buildAirExpressBannerSlide(context, metadataState)
                  : _buildSeaFreightBannerSlide(context, metadataState);
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerCount,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBannerIndex == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? const Color(0xFF0D9488)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicBannerSlide(
    BuildContext context,
    BannerModel banner,
    SystemMetadataState metadataState,
  ) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
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
          // Background Network Image (Cached)
          if (banner.imageUrl.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF0F172A),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2DD4BF),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),

          // Gradient Overlay for High Contrast Legibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.88),
                    Colors.black.withValues(alpha: 0.70),
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),

          // Ambient Teal Glow
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

          // Banner Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                        color: const Color(0xFF2DD4BF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'PROMO SPECIAL',
                        style: AppTypography.labelCaps.copyWith(
                          color: const Color(0xFF042F2E),
                          fontWeight: FontWeight.w800,
                          fontSize: 9.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.campaign_rounded,
                      color: Color(0xFF2DD4BF),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  banner.title,
                  style: AppTypography.headlineMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  banner.subtitle,
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 12,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final target = banner.targetScreen?.toLowerCase();
                    switch (target) {
                      case 'air_freight':
                        context.push('/air-freight');
                        break;
                      case 'sea_freight':
                        context.push('/sea-freight');
                        break;
                      case 'exchange':
                      case 'rmb_exchange':
                        context.push('/exchange');
                        break;
                      case 'consolidation':
                      case 'consolidate':
                        context.push('/consolidate');
                        break;
                      case 'buy_for_me':
                      case 'procurement':
                        context.push('/buy-for-me');
                        break;
                      case 'local_delivery':
                      case 'delivery':
                        context.push('/local-delivery');
                        break;
                      default:
                        context.push('/air-freight');
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore now',
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
          ),
        ],
      ),
    );
  }

  Widget _buildAirExpressBannerSlide(BuildContext context, SystemMetadataState metadataState) {
    final rateKg = metadataState.settings.airFreightRatePerKg;
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
              Text(
                'Air Express: 3-5 Days Direct',
                style: AppTypography.headlineMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Guangzhou (CAN) to Lagos (LOS) @ ₦${rateKg.toStringAsFixed(0)}/kg.\nCustoms clearance included.',
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const Spacer(),
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

  Widget _buildSeaFreightBannerSlide(BuildContext context, SystemMetadataState metadataState) {
    final seaRate = metadataState.settings.seaFreightRatePerCbm;
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
                'Sea Cargo: ₦${seaRate.toStringAsFixed(0)} / CBM',
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
  Widget _buildAllServicesSection(BuildContext context, SystemMetadataState metadataState) {
    final settings = metadataState.settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            GestureDetector(
              onTap: () => context.push('/services'),
              child: Row(
                children: [
                  Text(
                    'Services Hub',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: AppColors.primary,
                  ),
                ],
              ),
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
                badgeText: '₦${settings.airFreightRatePerKg.toStringAsFixed(0)}/KG',
                icon: Icons.flight_takeoff_rounded,
                gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                onTap: () => context.push('/air-freight'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildServiceCard(
                title: 'Sea Freight',
                description: 'Large volume CBM, container loads & groupage.',
                actionText: 'Get quote',
                badgeText: '₦${settings.seaFreightRatePerKg.toStringAsFixed(0)}/KG',
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
                description: 'Merge multiple 1688 / Taobao parcels into 1 package.',
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
                description: 'Sourcing, negotiation & factory purchasing.',
                actionText: 'Request item',
                badgeText: '${settings.buyForMeFeePercent.toStringAsFixed(0)}% FEE',
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
                description: 'Instant NGN to Alipay, WeChat & bank payout.',
                actionText: 'Swap now',
                badgeText: 'LIVE RATE',
                icon: Icons.currency_exchange_rounded,
                gradientColors: const [Color(0xFFDC2626), Color(0xFFEF4444)],
                onTap: () => context.push('/exchange'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildServiceCard(
                title: 'Local Delivery',
                description: 'Doorstep dispatch across Lagos and Nigerian States.',
                actionText: 'Send parcel',
                badgeText: 'DOORSTEP',
                icon: Icons.local_shipping_outlined,
                gradientColors: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                onTap: () => context.push('/local-delivery'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 4: Customs Clearance & Services Hub
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                title: 'Customs Clearance',
                description: 'Nigerian ports & airport customs clearing.',
                actionText: 'Clear goods',
                badgeText: 'PORT & AIRPORT',
                icon: Icons.shield_outlined,
                gradientColors: const [Color(0xFF065F46), Color(0xFF047857)],
                onTap: () => context.push('/customs-clearance'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildServiceCard(
                title: 'Services Hub',
                description: 'All freight, sourcing, and logistics solutions.',
                actionText: 'Explore all',
                badgeText: 'DIRECTORY',
                icon: Icons.grid_view_rounded,
                gradientColors: const [Color(0xFF1E293B), Color(0xFF334155)],
                onTap: () => context.push('/services'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Customs Clearance Dashboard Card (Requirement #20) ────────────────────
  Widget _buildCustomsClearanceDashboardCard(BuildContext context) {
    final clearanceState = ref.watch(customsClearanceProvider);
    final activeRequest = clearanceState.latestActiveRequest;

    if (activeRequest != null) {
      Color statusColor;
      if (activeRequest.isActionRequired) {
        statusColor = const Color(0xFFDC2626);
      } else if (activeRequest.status == ClearanceStatus.awaitingPayment) {
        statusColor = const Color(0xFFD97706);
      } else {
        statusColor = const Color(0xFF2563EB);
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: activeRequest.isActionRequired
                ? const Color(0xFFFECACA)
                : const Color(0xFFE2E8F0),
            width: activeRequest.isActionRequired ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF065F46).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF059669),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Customs Clearance',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ClearanceStatus.getLabel(activeRequest.status).toUpperCase(),
                    style: AppTypography.labelCaps.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              activeRequest.requestNumber,
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${activeRequest.itemsSummary} • ${activeRequest.portOfEntry}',
              style: AppTypography.bodySm.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (activeRequest.isActionRequired) ...[
              const SizedBox(height: 8),
              Text(
                activeRequest.requiredActionNote ??
                    'Action Required: Please upload missing documentation.',
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  '/customs-clearance/details/${activeRequest.id}',
                  extra: activeRequest,
                ),
                icon: const Icon(Icons.track_changes_rounded, size: 16),
                label: const Text('Track Clearance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // No active request
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF059669),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Customs Clearance',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Need help clearing imported goods?',
            style: AppTypography.headlineMd.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Submit your bill of lading or air waybill and let our licensed clearing specialists clear your cargo through Nigerian customs.',
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/customs-clearance/new'),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: const Text('Request Customs Clearance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
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
    final shipmentsState = ref.watch(shipmentsProvider);
    final packages = shipmentsState.packages;
    final totalCount = packages.length;

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
                totalCount > 0 ? 'VIEW ALL ($totalCount)' : 'ALL SHIPMENTS',
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

        if (packages.isNotEmpty) ...[
          // Route Card with real data
          Builder(
            builder: (context) {
              final pkg = packages.first;
              final statusUpper = pkg.status.replaceAll('_', ' ').toUpperCase();
              final courier = pkg.courierName.isNotEmpty ? pkg.courierName : 'China Express';
              final weightText = pkg.weightKg > 0 ? '${pkg.weightKg.toStringAsFixed(1)} kg' : 'Awaiting scale';

              Color statusColor;
              Color statusBg;
              switch (pkg.status.toLowerCase()) {
                case 'delivered':
                case 'arrived_ng':
                  statusColor = const Color(0xFF16A34A);
                  statusBg = const Color(0xFFDCFCE7);
                  break;
                case 'in_transit':
                case 'in_flight':
                case 'clearing_customs':
                  statusColor = const Color(0xFF0284C7);
                  statusBg = const Color(0xFFE0F2FE);
                  break;
                default:
                  statusColor = const Color(0xFFB45309);
                  statusBg = const Color(0xFFFEF3C7);
              }

              return Container(
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
                                courier.toUpperCase(),
                                style: AppTypography.labelCaps.copyWith(
                                  color: const Color(0xFF0369A1),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              pkg.trackingNumber.isNotEmpty ? pkg.trackingNumber : pkg.id,
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
                            color: statusBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusUpper,
                            style: AppTypography.labelCaps.copyWith(
                              color: statusColor,
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
                              'China Hub',
                              style: AppTypography.bodySm.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.onBackground,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pkg.receivedDate != null
                                  ? 'Logged ${pkg.receivedDate!.month}/${pkg.receivedDate!.day}'
                                  : 'Intake Recorded',
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
                                  statusUpper,
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
                                  weightText,
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
                              'LOS Hub',
                              style: AppTypography.bodySm.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.onBackground,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Nigeria Dispatch',
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

                    // Bottom bar container: Description + "TRACK LIVE"
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
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Color(0xFF0284C7),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    pkg.description,
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.onBackground,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
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
              );
            },
          ),
        ] else ...[
          // Empty State Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF64748B),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No Active Shipments in Transit',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pre-alert incoming packages or enter a tracking number to monitor live shipment status.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.push('/pre-alert'),
                      icon: const Icon(Icons.add_alert_outlined, size: 16),
                      label: const Text('Pre-Alert Cargo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/track'),
                      icon: const Icon(Icons.search, size: 16),
                      label: const Text('Track Cargo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
