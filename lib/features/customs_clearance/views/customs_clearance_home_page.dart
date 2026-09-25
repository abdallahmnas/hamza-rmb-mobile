import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_bar_logo_title.dart';
import '../data/models/clearance_request_model.dart';
import '../presentation/providers/customs_clearance_provider.dart';

class CustomsClearanceHomePage extends ConsumerWidget {
  const CustomsClearanceHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clearanceState = ref.watch(customsClearanceProvider);
    final activeRequest = clearanceState.latestActiveRequest;

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
          title: 'Customs Clearance',
          style: AppTypography.bodyLg.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.onBackground,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
            tooltip: 'My Requests',
            onPressed: () => context.push('/customs-clearance/my-requests'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Banner ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A), // Midnight Navy
                    Color(0xFF0D253A),
                    Color(0xFF064E3B), // Forest Emerald
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xFF34D399),
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'NIGERIAN PORTS & AIRPORTS CLEARANCE',
                          style: AppTypography.labelCaps.copyWith(
                            color: const Color(0xFF34D399),
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Customs Clearance',
                    style: AppTypography.headlineLg.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get help clearing your imported goods through Nigerian customs without hassle or delay.',
                    style: AppTypography.bodyMd.copyWith(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/customs-clearance/new'),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                          label: Text(
                            'Request Clearance',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 5,
                        child: OutlinedButton(
                          onPressed: () =>
                              context.push('/customs-clearance/my-requests'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'My Requests (${clearanceState.requests.where((r) => r.status != ClearanceStatus.draft).length})',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Active Request Quick Card (If available) ────────────────────
            if (activeRequest != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildActiveRequestBanner(context, activeRequest),
              ),
            ],

            const SizedBox(height: 24),

            // ── How It Works ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'How It Works',
                        style: AppTypography.headlineMd.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Simple 4-step process from shipping manifest to goods release',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildStepCard(
                    stepNumber: '1',
                    title: 'Submit your shipment details',
                    description:
                        'Tell us about the goods you imported, the port of entry, and shipping numbers.',
                    icon: Icons.inventory_2_outlined,
                    iconBgColor: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 12),
                  _buildStepCard(
                    stepNumber: '2',
                    title: 'Upload your documents',
                    description:
                        'Provide your commercial invoice, packing list, bill of lading, and available permits.',
                    icon: Icons.upload_file_rounded,
                    iconBgColor: const Color(0xFFF0FDF4),
                    iconColor: const Color(0xFF059669),
                  ),
                  const SizedBox(height: 12),
                  _buildStepCard(
                    stepNumber: '3',
                    title: 'We process your clearance',
                    description:
                        'Our licensed clearing agents assess duty tariffs, handle inspections, and resolve port fees.',
                    icon: Icons.gavel_rounded,
                    iconBgColor: const Color(0xFFFFFBEB),
                    iconColor: const Color(0xFFD97706),
                  ),
                  const SizedBox(height: 12),
                  _buildStepCard(
                    stepNumber: '4',
                    title: 'Track your request & receive goods',
                    description:
                        'Receive live milestones until customs release and have cargo delivered to your door.',
                    icon: Icons.local_shipping_outlined,
                    iconBgColor: const Color(0xFFF5F3FF),
                    iconColor: const Color(0xFF7C3AED),
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Supported Ports & Terminals ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supported Ports & Entry Points',
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildPortItem(
                          title: 'Sea Ports',
                          subtitle: 'Apapa Port • Tin Can Island • Lekki Deep Sea Port • Onne',
                          icon: Icons.directions_boat_rounded,
                          color: const Color(0xFF0D9488),
                        ),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _buildPortItem(
                          title: 'Airports (Cargo Sheds)',
                          subtitle: 'Murtala Muhammed Airport (NAHCO/SAHCO) • Nnamdi Azikiwe Cargo',
                          icon: Icons.flight_takeoff_rounded,
                          color: const Color(0xFF2563EB),
                        ),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        _buildPortItem(
                          title: 'Land Borders & Dry Ports',
                          subtitle: 'Seme Border • Idiroko • Kaduna & Kano Inland Dry Ports',
                          icon: Icons.domain_rounded,
                          color: const Color(0xFFEA580C),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Service Guarantees ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF16A34A),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transparent Customs Brokerage',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF14532D),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Duty assessments are computed against official tariff schedules with no arbitrary terminal surprises.',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF166534),
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Bottom Start CTA ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/customs-clearance/new'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Start New Clearance Request',
                        style: AppTypography.bodyLg.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRequestBanner(
      BuildContext context, ClearanceRequestModel request) {
    final statusColor = request.isActionRequired
        ? const Color(0xFFDC2626)
        : (request.status == ClearanceStatus.awaitingPayment
            ? const Color(0xFFD97706)
            : const Color(0xFF2563EB));

    return InkWell(
      onTap: () => context.push('/customs-clearance/details/${request.id}',
          extra: request),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: request.isActionRequired
                ? const Color(0xFFFECACA)
                : const Color(0xFFE2E8F0),
            width: request.isActionRequired ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ACTIVE CLEARANCE',
                      style: AppTypography.labelCaps.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 0.8,
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
                    ClearanceStatus.getLabel(request.status).toUpperCase(),
                    style: AppTypography.labelCaps.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              request.requestNumber,
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${request.itemsSummary} • ${request.portOfEntry}',
              style: AppTypography.bodySm.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (request.isActionRequired) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        request.requiredActionNote ??
                            'Action Required: Please upload missing documentation.',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF991B1B),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ETA: ${request.portOfEntry}',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Track Clearance',
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'STEP $stepNumber',
                        style: AppTypography.labelCaps.copyWith(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
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
      ),
    );
  }

  Widget _buildPortItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
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
          ),
        ),
      ],
    );
  }
}
