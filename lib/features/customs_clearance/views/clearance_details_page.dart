import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../features/wallet/presentation/providers/wallet_provider.dart';
import '../data/models/clearance_request_model.dart';
import '../presentation/providers/customs_clearance_provider.dart';

class ClearanceDetailsPage extends ConsumerStatefulWidget {
  final String? initialRequestId;
  final ClearanceRequestModel? initialRequest;

  const ClearanceDetailsPage({
    super.key,
    this.initialRequestId,
    this.initialRequest,
  });

  @override
  ConsumerState<ClearanceDetailsPage> createState() => _ClearanceDetailsPageState();
}

class _ClearanceDetailsPageState extends ConsumerState<ClearanceDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  ClearanceRequestModel? _getCurrentRequest() {
    final clearanceState = ref.watch(customsClearanceProvider);
    final targetId = widget.initialRequest?.id ?? widget.initialRequestId;

    if (targetId != null) {
      final found = clearanceState.requests.where((r) => r.id == targetId);
      if (found.isNotEmpty) return found.first;
    }
    return widget.initialRequest;
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = _getCurrentRequest();

    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Clearance Request')),
        body: const Center(child: Text('Request not found.')),
      );
    }

    final statusColor = _getStatusColor(request.status);

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customs Clearance',
              style: AppTypography.labelCaps.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                Text(
                  request.requestNumber,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _copyToClipboard(
                      request.requestNumber, 'Request number copied'),
                  child: const Icon(Icons.copy_rounded,
                      size: 13, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.primary),
            onPressed: () => _tabController.animateTo(3),
            tooltip: 'Messages',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
              unselectedLabelStyle: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              tabs: [
                const Tab(text: 'Overview'),
                Tab(text: 'Docs (${request.documents.length})'),
                Tab(
                  text: request.status == ClearanceStatus.awaitingPayment
                      ? 'Charges (!)'
                      : 'Charges',
                ),
                Tab(text: 'Messages (${request.messages.length})'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Status Header Card ───────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(
                    color: statusColor.withValues(alpha: 0.15), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(request.status),
                    color: statusColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ClearanceStatus.getLabel(request.status),
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ClearanceStatus.getDescription(request.status),
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF475569),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Action Required Alert Banner (Section 13) ────────────────────
          if (request.isActionRequired) ...[
            _buildActionRequiredBanner(request),
          ],

          // ── Tab Views ────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(request),
                _buildDocumentsTab(request),
                _buildChargesTab(request),
                _buildMessagesTab(request),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Required Alert (Section 13) ────────────────────────────────────
  Widget _buildActionRequiredBanner(ClearanceRequestModel request) {
    final missingDocs = request.documents
        .where((d) => d.status == 'More information required' || d.isNotAvailable)
        .toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.priority_high_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                'ACTION REQUIRED',
                style: AppTypography.labelCaps.copyWith(
                  color: const Color(0xFFB91C1C),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            request.requiredActionNote ??
                'We need additional information or clearer copies of your documents to continue processing your customs clearance.',
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF991B1B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'WHAT WE NEED:',
            style: AppTypography.labelCaps.copyWith(
              color: const Color(0xFF7F1D1D),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          ...missingDocs.map((doc) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.documentType,
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        if (doc.note != null && doc.note!.isNotEmpty)
                          Text(
                            doc.note!,
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFFDC2626),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showUploadMissingDocDialog(request, doc),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Upload Document',
                      style: AppTypography.bodySm.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Tab 1: Overview & Interactive Timeline ────────────────────────────────
  Widget _buildOverviewTab(ClearanceRequestModel request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline Section ────────────────────────────────────────────
          Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Clearance Progress Timeline',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'STEP ${ClearanceStatus.getTimelineStep(request.status) + 1} OF 7',
                        style: AppTypography.labelCaps.copyWith(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTimeline(request),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Shipment Summary ────────────────────────────────────────────
          _buildCardContainer(
            title: 'Shipment Details',
            icon: request.shipmentType == 'Sea'
                ? Icons.directions_boat_rounded
                : Icons.flight_takeoff_rounded,
            iconColor: const Color(0xFF2563EB),
            children: [
              _buildInfoRow('Shipment Mode', '${request.shipmentType} Cargo'),
              _buildInfoRow('Port of Entry', request.portOfEntry),
              _buildInfoRow('Country of Origin', request.originCountry),
              _buildInfoRow('Shipment Status', request.shipmentStatus),
              if (request.shippingLine != null)
                _buildInfoRow('Shipping Carrier', request.shippingLine!),
              if (request.airline != null)
                _buildInfoRow('Airline Carrier', request.airline!),
              if (request.billOfLadingNumber != null)
                _buildInfoRow('Bill of Lading', request.billOfLadingNumber!),
              if (request.airWaybillNumber != null)
                _buildInfoRow('Air Waybill', request.airWaybillNumber!),
              if (request.containerNumber != null)
                _buildInfoRow('Container Number', request.containerNumber!),
              if (request.estimatedArrivalDate != null)
                _buildInfoRow('Est. Arrival Date',
                    DateFormat('MMM dd, yyyy').format(request.estimatedArrivalDate!)),
            ],
          ),

          const SizedBox(height: 16),

          // ── Goods / Products Summary ────────────────────────────────────
          _buildCardContainer(
            title: 'Imported Goods (${request.items.length})',
            icon: Icons.inventory_2_outlined,
            iconColor: const Color(0xFFEA580C),
            children: [
              ...request.items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: AppTypography.bodyMd.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            '${item.quantity.toInt()} ${item.unit}',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Category: ${item.category} • Value: ${item.currency} ${NumberFormat('#,##0.00').format(item.purchaseValue * item.quantity)}',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                      if (item.hsCode != null)
                        Text(
                          'HS Code: ${item.hsCode}',
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildInfoRow(
                'Total Declared Goods Value',
                '${request.primaryCurrency} ${NumberFormat('#,##0.00').format(request.totalValue)}',
                isBold: true,
              ),
              _buildInfoRow(
                'Total Weight / Volume',
                request.totalWeight > 0 ? '${request.totalWeight.toStringAsFixed(1)} kg' : 'Standard',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Delivery Information ────────────────────────────────────────
          _buildCardContainer(
            title: 'Delivery Preference',
            icon: Icons.local_shipping_outlined,
            iconColor: const Color(0xFF10B981),
            children: [
              _buildInfoRow('Preference', request.deliveryPreference),
              if (request.deliveryAddress != null) ...[
                _buildInfoRow('Contact Person', request.deliveryAddress!.fullName),
                _buildInfoRow('Phone', request.deliveryAddress!.phone),
                _buildInfoRow('Destination',
                    '${request.deliveryAddress!.address}, ${request.deliveryAddress!.city}, ${request.deliveryAddress!.state}'),
                if (request.deliveryAddress!.instructions != null)
                  _buildInfoRow('Instructions',
                      request.deliveryAddress!.instructions!),
              ],
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── 7-Stage Progress Timeline ─────────────────────────────────────────────
  Widget _buildTimeline(ClearanceRequestModel request) {
    final currentStep = ClearanceStatus.getTimelineStep(request.status);

    final stages = [
      {'title': 'Request Submitted', 'desc': 'Your request was received'},
      {'title': 'Documents Review', 'desc': 'Documents verified & classified'},
      {'title': 'Clearance Processing', 'desc': 'Customs manifest entry'},
      {'title': 'Customs Assessment', 'desc': 'Tariff & duty assessment'},
      {'title': 'Customs Release', 'desc': 'Terminal gate pass granted'},
      {'title': 'Delivery', 'desc': 'Dispatched to customer'},
      {'title': 'Completed', 'desc': 'Cargo received in good order'},
    ];

    return Column(
      children: List.generate(stages.length, (index) {
        final isDone = currentStep > index;
        final isCurrent = currentStep == index;
        final isPending = currentStep < index;
        final isLast = index == stages.length - 1;

        Color dotColor;
        Widget dotIcon;

        if (isDone) {
          dotColor = const Color(0xFF059669);
          dotIcon = const Icon(Icons.check_rounded, color: Colors.white, size: 12);
        } else if (isCurrent) {
          dotColor = request.isActionRequired
              ? const Color(0xFFDC2626)
              : (request.status == ClearanceStatus.awaitingPayment
                  ? const Color(0xFFD97706)
                  : const Color(0xFF2563EB));
          dotIcon = Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          );
        } else {
          dotColor = const Color(0xFFE2E8F0);
          dotIcon = const SizedBox.shrink();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: isPending
                        ? Border.all(color: const Color(0xFFCBD5E1), width: 1.5)
                        : null,
                  ),
                  child: Center(child: dotIcon),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 28,
                    color: isDone
                        ? const Color(0xFF059669)
                        : const Color(0xFFE2E8F0),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        stages[index]['title']!,
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight:
                              isCurrent ? FontWeight.w900 : FontWeight.w700,
                          color: isPending
                              ? const Color(0xFF94A3B8)
                              : AppColors.onBackground,
                          fontSize: 13,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: dotColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CURRENT',
                            style: AppTypography.labelCaps.copyWith(
                              color: dotColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stages[index]['desc']!,
                    style: AppTypography.bodySm.copyWith(
                      color: isPending
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Tab 2: Documents Management ───────────────────────────────────────────
  Widget _buildDocumentsTab(ClearanceRequestModel request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                    'Clearance Documents',
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Only you and authorized clearing officers have access.',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddNewDocModal(request),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...request.documents.map((doc) {
            Color badgeColor;
            switch (doc.status.toLowerCase()) {
              case 'accepted':
                badgeColor = const Color(0xFF059669);
                break;
              case 'more information required':
                badgeColor = const Color(0xFFDC2626);
                break;
              case 'under review':
                badgeColor = const Color(0xFFD97706);
                break;
              default:
                badgeColor = const Color(0xFF2563EB);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: doc.status == 'More information required'
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.description_outlined,
                            size: 20, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.documentType,
                              style: AppTypography.bodyMd.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              doc.fileName.isNotEmpty
                                  ? doc.fileName
                                  : 'Not yet uploaded',
                              style: AppTypography.bodySm.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          doc.status.toUpperCase(),
                          style: AppTypography.labelCaps.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (doc.note != null && doc.note!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Officer Note: ${doc.note}',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF991B1B),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Uploaded ${DateFormat('MMM dd, yyyy').format(doc.uploadedAt)}',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                      Row(
                        children: [
                          if (doc.fileName.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Previewing ${doc.fileName}...'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility_outlined, size: 14),
                              label: const Text('Preview'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                            ),
                          TextButton.icon(
                            onPressed: () => _showUploadMissingDocDialog(request, doc),
                            icon: const Icon(Icons.sync_rounded, size: 14),
                            label: const Text('Replace'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              textStyle: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Tab 3: Charges, Quotes & Payment (Section 14 & 15) ────────────────────
  Widget _buildChargesTab(ClearanceRequestModel request) {
    final govtCharges = request.charges
        .where((c) => c.category == 'Customs/Government Charges')
        .toList();
    final serviceCharges = request.charges
        .where((c) => c.category == 'Service Charges')
        .toList();
    final deliveryCharges =
        request.charges.where((c) => c.category == 'Delivery').toList();

    final isAwaitingPayment = request.status == ClearanceStatus.awaitingPayment ||
        request.unpaidChargesAmount > 0;
    final wallet = ref.watch(walletProvider).wallet;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Amount Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL CLEARANCE CHARGES',
                      style: AppTypography.labelCaps.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 9,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: request.areChargesConfirmed
                            ? const Color(0xFF10B981).withValues(alpha: 0.2)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        request.areChargesConfirmed
                            ? 'CONFIRMED QUOTE'
                            : 'ESTIMATED QUOTE',
                        style: AppTypography.labelCaps.copyWith(
                          color: request.areChargesConfirmed
                              ? const Color(0xFF34D399)
                              : const Color(0xFFFBBF24),
                          fontWeight: FontWeight.w900,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₦${NumberFormat('#,##0.00').format(request.totalChargesAmount)}',
                  style: AppTypography.headlineLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.areChargesConfirmed
                      ? 'Official customs assessment & port terminal invoice generated.'
                      : 'Estimated charges based on declared invoice. Official assessment will confirm final tariffs.',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Pay Now Action if Awaiting Payment
          if (isAwaitingPayment && request.unpaidChargesAmount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payment_rounded,
                          color: Color(0xFFD97706), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Required to Release Cargo',
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Outstanding balance: ₦${NumberFormat('#,##0.00').format(request.unpaidChargesAmount)}. Available in your wallet: ₦${NumberFormat('#,##0.00').format(wallet.balance)}.',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFFB45309),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isPaying ? null : () => _handlePayNow(request),
                      icon: _isPaying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.account_balance_wallet_rounded,
                              size: 18),
                      label: Text(
                        _isPaying
                            ? 'Processing Payment...'
                            : (wallet.balance >= request.unpaidChargesAmount
                                ? 'Pay ₦${NumberFormat('#,##0.00').format(request.unpaidChargesAmount)} from Wallet'
                                : 'Fund Wallet & Pay'),
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
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
          ],

          const SizedBox(height: 20),

          // Group 1: Customs & Government Charges
          if (govtCharges.isNotEmpty)
            _buildChargesGroup(
              title: 'Customs & Government Statutory Charges',
              charges: govtCharges,
            ),

          const SizedBox(height: 14),

          // Group 2: Clearing Service Charges
          if (serviceCharges.isNotEmpty)
            _buildChargesGroup(
              title: 'Clearing Service & Terminal Handling Charges',
              charges: serviceCharges,
            ),

          const SizedBox(height: 14),

          // Group 3: Delivery Charges
          if (deliveryCharges.isNotEmpty)
            _buildChargesGroup(
              title: 'Delivery & Transport Charges',
              charges: deliveryCharges,
            ),

          const SizedBox(height: 24),

          // Payment History (Section 15)
          if (request.payments.isNotEmpty) ...[
            Text(
              'Payment History',
              style: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ...request.payments.map((pmt) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Color(0xFF059669), size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pmt.paymentNumber,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${pmt.description} • ${pmt.paymentMethod}',
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
                          '₦${NumberFormat('#,##0.00').format(pmt.amount)}',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF059669),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(pmt.paidAt),
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildChargesGroup({
    required String title,
    required List<ClearanceCharge> charges,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ...charges.map((c) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.description,
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: c.isConfirmed
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                c.isConfirmed ? 'CONFIRMED' : 'ESTIMATED',
                                style: AppTypography.labelCaps.copyWith(
                                  color: c.isConfirmed
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB45309),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              c.status,
                              style: AppTypography.bodySm.copyWith(
                                color: c.status == 'Paid'
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF64748B),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₦${NumberFormat('#,##0.00').format(c.amount)}',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.onBackground,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _handlePayNow(ClearanceRequestModel request) async {
    final wallet = ref.read(walletProvider).wallet;
    final amount = request.unpaidChargesAmount;

    if (wallet.balance < amount) {
      final shouldFund = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Insufficient Wallet Balance'),
          content: Text(
            'Your current wallet balance is ₦${NumberFormat('#,##0.00').format(wallet.balance)}. You need ₦${NumberFormat('#,##0.00').format(amount)} to settle this customs assessment.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Fund Wallet Now'),
            ),
          ],
        ),
      );

      if (shouldFund == true && mounted) {
        context.push('/fund-wallet');
      }
      return;
    }

    // Confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Customs Payment'),
        content: Text(
          'Confirm debit of ₦${NumberFormat('#,##0.00').format(amount)} from your wallet to pay duty & terminal fees for ${request.requestNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
            child: const Text('Confirm & Pay'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isPaying = true);
      final success = await ref
          .read(customsClearanceProvider.notifier)
          .payChargesWithWallet(request.id);
      if (!mounted) return;
      setState(() => _isPaying = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Customs payment completed successfully! Terminal release order granted.'),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // ── Tab 4: Messages / Support (Section 17) ─────────────────────────────────
  Widget _buildMessagesTab(ClearanceRequestModel request) {
    return Column(
      children: [
        Expanded(
          child: request.messages.isEmpty
              ? Center(
                  child: Text(
                    'No messages yet. Send a message to the clearing desk below.',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _messagesScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: request.messages.length,
                  itemBuilder: (context, index) {
                    final msg = request.messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
        ),

        // Message input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file_rounded,
                      color: Color(0xFF64748B)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Select image or document attachment'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: AppTypography.bodyMd.copyWith(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Type your message to clearing desk...',
                      hintStyle: AppTypography.bodySm.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                  onPressed: () {
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty) {
                      ref
                          .read(customsClearanceProvider.notifier)
                          .sendMessage(request.id, text);
                      _messageController.clear();
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (_messagesScrollController.hasClients) {
                          _messagesScrollController.animateTo(
                            _messagesScrollController.position.maxScrollExtent +
                                60,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ClearanceMessage msg) {
    final isSystem = msg.senderType == 'system';
    final isCustomer = msg.senderType == 'customer';
    final timeStr = DateFormat('hh:mm a').format(msg.createdAt);

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 14, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg.message,
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF475569),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeStr,
              style: AppTypography.bodySm.copyWith(
                color: const Color(0xFF94A3B8),
                fontSize: 9,
              ),
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isCustomer ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: isCustomer ? const Radius.circular(14) : Radius.zero,
            bottomRight: isCustomer ? Radius.zero : const Radius.circular(14),
          ),
          border: isCustomer ? null : Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isCustomer) ...[
              Text(
                msg.senderName,
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.brandOrange,
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 2),
            ],
            Text(
              msg.message,
              style: AppTypography.bodySm.copyWith(
                color: isCustomer ? Colors.white : AppColors.onBackground,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: AppTypography.labelCaps.copyWith(
                color: isCustomer
                    ? Colors.white.withValues(alpha: 0.7)
                    : const Color(0xFF94A3B8),
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Modals / Dialogs ──────────────────────────────────────────────────────
  Future<void> _showUploadMissingDocDialog(
      ClearanceRequestModel request, ClearanceDocument doc) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Upload ${doc.documentType}',
                style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: const Text('Take photo of document'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Upload from phone gallery / files'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    String fileName = '${doc.documentType.replaceAll(' ', '_')}_uploaded.pdf';
    try {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        fileName = picked.name;
      }
    } catch (_) {}

    final updatedDoc = doc.copyWith(
      fileName: fileName,
      fileUrl: 'https://example.com/uploads/$fileName',
      status: 'Uploaded',
      isNotAvailable: false,
      uploadedAt: DateTime.now(),
      note: null,
    );

    await ref
        .read(customsClearanceProvider.notifier)
        .uploadAdditionalDocument(request.id, updatedDoc);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uploaded ${doc.documentType} successfully!'),
        backgroundColor: const Color(0xFF059669),
      ),
    );
  }

  Future<void> _showAddNewDocModal(ClearanceRequestModel request) async {
    final typeController = TextEditingController(text: 'Commercial Invoice');
    final nameController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Supporting Document',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Document Type',
                hintText: 'e.g. SONCAP, NAFDAC permit, Form M',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'File Name',
                hintText: 'e.g. Permitted_Certificate.pdf',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final newDoc = ClearanceDocument(
                    id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
                    documentType: typeController.text.trim(),
                    fileName: nameController.text.trim().isNotEmpty
                        ? nameController.text.trim()
                        : '${typeController.text.trim()}.pdf',
                    fileUrl: 'https://example.com/doc.pdf',
                    status: 'Uploaded',
                    uploadedAt: DateTime.now(),
                  );
                  ref
                      .read(customsClearanceProvider.notifier)
                      .uploadAdditionalDocument(request.id, newDoc);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save & Upload'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────────
  Widget _buildCardContainer({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
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
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodySm.copyWith(
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
                color: AppColors.onBackground,
                fontSize: 12,
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case ClearanceStatus.completed:
      case ClearanceStatus.customsReleased:
        return Icons.check_circle_outline_rounded;
      case ClearanceStatus.additionalInfoRequired:
        return Icons.warning_amber_rounded;
      case ClearanceStatus.awaitingPayment:
        return Icons.payment_rounded;
      case ClearanceStatus.delivery:
        return Icons.local_shipping_outlined;
      default:
        return Icons.hourglass_top_rounded;
    }
  }
}
