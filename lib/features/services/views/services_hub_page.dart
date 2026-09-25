import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_bar_logo_title.dart';
import '../../customs_clearance/presentation/providers/customs_clearance_provider.dart';

class ServicesHubPage extends ConsumerWidget {
  const ServicesHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clearanceState = ref.watch(customsClearanceProvider);
    final activeClearance = clearanceState.latestActiveRequest;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.onBackground,
          onPressed: () => context.pop(),
        ),
        title: AppBarLogoTitle(
          title: 'Logistics & Import Services',
          style: AppTypography.bodyLg.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.onBackground,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Customs Clearance (Featured Service) ────────────
            _buildSectionHeader(
              title: 'Customs Clearance',
              subtitle: 'Clear your imported goods through Nigerian ports & airports',
              badgeText: 'CORE SERVICE',
              badgeColor: const Color(0xFF059669),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF0D253A),
                    Color(0xFF064E3B),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield_outlined,
                                color: Color(0xFF34D399), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'LICENSED NIGERIAN AGENTS',
                              style: AppTypography.labelCaps.copyWith(
                                color: const Color(0xFF34D399),
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (activeClearance != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '1 ACTIVE REQUEST',
                            style: AppTypography.labelCaps.copyWith(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Nigerian Customs Clearance',
                    style: AppTypography.headlineMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Apapa Port, Tin Can, Lekki Port, MMIA Cargo Sheds & NAIA Abuja clearance handling with transparent statutory tariffs.',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              context.push('/customs-clearance/new'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Request Clearance',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              context.push('/customs-clearance/my-requests'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'My Requests',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Section 2: Freight & Shipping ───────────────────────────────
            _buildSectionHeader(
              title: 'Freight & Shipping',
              subtitle: 'Air cargo, sea containers, parcel consolidation & sourcing',
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildServiceTile(
                    title: 'Air Freight',
                    subtitle: 'Fast dispatch from Guangzhou to Lagos',
                    icon: Icons.flight_takeoff_rounded,
                    color: const Color(0xFF2563EB),
                    badgeText: 'FAST',
                    onTap: () => context.push('/air-freight'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildServiceTile(
                    title: 'Sea Freight',
                    subtitle: 'High volume CBM & full containers',
                    icon: Icons.directions_boat_rounded,
                    color: const Color(0xFF0D9488),
                    badgeText: 'ECONOMICAL',
                    onTap: () => context.push('/sea-freight'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildServiceTile(
                    title: 'Consolidation',
                    subtitle: 'Merge multiple parcel orders into one',
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFFEA580C),
                    badgeText: 'SAVE 35%',
                    onTap: () => context.push('/consolidate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildServiceTile(
                    title: 'Buy For Me',
                    subtitle: '1688 / Taobao purchasing & negotiation',
                    icon: Icons.shopping_cart_outlined,
                    color: const Color(0xFF10B981),
                    badgeText: 'SOURCING',
                    onTap: () => context.push('/buy-for-me'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Section 3: Delivery ─────────────────────────────────────────
            _buildSectionHeader(
              title: 'Delivery',
              subtitle: 'Last-mile dispatch across Lagos and Nigerian States',
            ),
            const SizedBox(height: 12),

            _buildWideServiceTile(
              title: 'Local Doorstep Delivery',
              subtitle:
                  'Instant and scheduled dispatch from Hamza Lagos Hub to your home, office, or interstate transit parks.',
              badgeText: 'DOORSTEP',
              icon: Icons.local_shipping_outlined,
              iconColor: const Color(0xFF7C3AED),
              onTap: () => context.push('/local-delivery'),
            ),

            const SizedBox(height: 12),

            _buildWideServiceTile(
              title: 'China Warehouse Addresses',
              subtitle:
                  'Copy your unique Chinese shipping address with phone and mark code for Taobao, 1688, or suppliers.',
              badgeText: 'FREE ADDRESS',
              icon: Icons.warehouse_outlined,
              iconColor: const Color(0xFFD97706),
              onTap: () => context.push('/warehouse-addresses'),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: AppTypography.labelCaps.copyWith(
                    color: badgeColor ?? AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.bodySm.copyWith(
            color: const Color(0xFF64748B),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTypography.labelCaps.copyWith(
                      color: const Color(0xFF475569),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideServiceTile({
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: AppTypography.labelCaps.copyWith(
                            color: const Color(0xFF475569),
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
