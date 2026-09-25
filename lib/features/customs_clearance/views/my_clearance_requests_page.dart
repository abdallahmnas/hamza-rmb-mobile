import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_bar_logo_title.dart';
import '../data/models/clearance_request_model.dart';
import '../presentation/providers/customs_clearance_provider.dart';

class MyClearanceRequestsPage extends ConsumerStatefulWidget {
  const MyClearanceRequestsPage({super.key});

  @override
  ConsumerState<MyClearanceRequestsPage> createState() =>
      _MyClearanceRequestsPageState();
}

class _MyClearanceRequestsPageState
    extends ConsumerState<MyClearanceRequestsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = const ['All', 'Active', 'Completed', 'Cancelled'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clearanceState = ref.watch(customsClearanceProvider);
    final selectedFilter = clearanceState.selectedFilter;

    // Filter by tab + search
    final list = clearanceState.filteredRequests.where((req) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final numMatch = req.requestNumber.toLowerCase().contains(query);
      final itemMatch = req.itemsSummary.toLowerCase().contains(query);
      final portMatch = req.portOfEntry.toLowerCase().contains(query);
      final blMatch = (req.billOfLadingNumber ?? '').toLowerCase().contains(query);
      final awbMatch = (req.airWaybillNumber ?? '').toLowerCase().contains(query);
      return numMatch || itemMatch || portMatch || blMatch || awbMatch;
    }).toList();

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
          title: 'My Clearance Requests',
          style: AppTypography.bodyLg.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.onBackground,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary),
            tooltip: 'New Clearance Request',
            onPressed: () => context.push('/customs-clearance/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter Row ─────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              children: [
                // Search Input
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    style: AppTypography.bodyMd.copyWith(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search by CLR number, goods, port, or B/L...',
                      hintStyle: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected =
                          selectedFilter.toLowerCase() == filter.toLowerCase();

                      int count = 0;
                      if (filter == 'All') {
                        count = clearanceState.requests
                            .where((r) => r.status != ClearanceStatus.draft)
                            .length;
                      } else if (filter == 'Active') {
                        count = clearanceState.activeRequests.length;
                      } else if (filter == 'Completed') {
                        count = clearanceState.completedRequests.length;
                      } else if (filter == 'Cancelled') {
                        count = clearanceState.cancelledRequests.length;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(customsClearanceProvider.notifier)
                                .setFilter(filter);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  filter,
                                  style: AppTypography.bodySm.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: AppTypography.labelCaps.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF475569),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Requests Cards List ─────────────────────────────────────────
          Expanded(
            child: list.isEmpty
                ? _buildEmptyState(selectedFilter)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _buildRequestCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, ClearanceRequestModel req) {
    final statusColor = _getStatusColor(req.status);
    final dateStr = DateFormat('MMM dd, yyyy').format(req.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: req.isActionRequired
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFE2E8F0),
          width: req.isActionRequired ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(
            '/customs-clearance/details/${req.id}',
            extra: req,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: req.shipmentType == 'Sea'
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            req.shipmentType == 'Sea'
                                ? Icons.directions_boat_rounded
                                : (req.shipmentType == 'Air'
                                    ? Icons.flight_takeoff_rounded
                                    : Icons.local_shipping_rounded),
                            size: 16,
                            color: req.shipmentType == 'Sea'
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          req.requestNumber,
                          style: AppTypography.headlineMd.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ClearanceStatus.getLabel(req.status).toUpperCase(),
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

                // Goods Title
                Text(
                  req.itemsSummary,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.onBackground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Port & Origin
                Text(
                  '${req.portOfEntry} • Origin: ${req.originCountry}',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Action Required Callout Banner
                if (req.isActionRequired) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFEE2E2)),
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
                            req.requiredActionNote ??
                                'Action Required: Additional document needed.',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF991B1B),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Awaiting Payment Callout Banner
                if (req.status == ClearanceStatus.awaitingPayment) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.payment_rounded,
                              color: Color(0xFFD97706),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Duty & Fees Payable: ₦${NumberFormat('#,##0.00').format(req.unpaidChargesAmount)}',
                              style: AppTypography.bodySm.copyWith(
                                color: const Color(0xFF92400E),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'PAY NOW →',
                          style: AppTypography.labelCaps.copyWith(
                            color: const Color(0xFFB45309),
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Card Footer: Date & CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Submitted $dateStr',
                      style: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'View Details',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
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
        ),
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 38,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No $filter Requests Found',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You have no customs clearance applications matching this filter.',
              style: AppTypography.bodySm.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.push('/customs-clearance/new'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Start New Clearance Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case ClearanceStatus.completed:
      case ClearanceStatus.customsReleased:
        return const Color(0xFF059669);
      case ClearanceStatus.additionalInfoRequired:
      case ClearanceStatus.cancelled:
        return const Color(0xFFDC2626);
      case ClearanceStatus.awaitingPayment:
      case ClearanceStatus.customsAssessment:
        return const Color(0xFFD97706);
      case ClearanceStatus.clearanceProcessing:
      case ClearanceStatus.inspection:
      case ClearanceStatus.delivery:
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF475569);
    }
  }
}
