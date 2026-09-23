import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../data/datasources/shipments_remote_data_source.dart';
import '../presentation/providers/shipments_provider.dart';

class LiveTrackingPage extends ConsumerStatefulWidget {
  final String? initialTrackingId;

  const LiveTrackingPage({super.key, this.initialTrackingId});

  @override
  ConsumerState<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends ConsumerState<LiveTrackingPage> {
  late TextEditingController _waybillController;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _trackingData;

  @override
  void initState() {
    super.initState();
    _waybillController = TextEditingController(
      text: widget.initialTrackingId ?? '',
    );

    Future.microtask(() {
      _initializeTracking();
    });
  }

  @override
  void dispose() {
    _waybillController.dispose();
    super.dispose();
  }

  void _initializeTracking() {
    if (widget.initialTrackingId != null && widget.initialTrackingId!.isNotEmpty) {
      _fetchTracking(widget.initialTrackingId!);
    } else {
      final shipmentsState = ref.read(shipmentsProvider);
      if (shipmentsState.packages.isNotEmpty) {
        final defaultPkg = shipmentsState.packages.first;
        final trackingNum = defaultPkg.trackingNumber.isNotEmpty
            ? defaultPkg.trackingNumber
            : defaultPkg.id;
        _waybillController.text = trackingNum;
        _fetchTracking(trackingNum);
      } else {
        // If packages are not loaded, fetch them and then track
        ref.read(shipmentsProvider.notifier).fetchAll().then((_) {
          if (!mounted) return;
          final updatedState = ref.read(shipmentsProvider);
          if (updatedState.packages.isNotEmpty) {
            final defaultPkg = updatedState.packages.first;
            final trackingNum = defaultPkg.trackingNumber.isNotEmpty
                ? defaultPkg.trackingNumber
                : defaultPkg.id;
            _waybillController.text = trackingNum;
            _fetchTracking(trackingNum);
          }
        });
      }
    }
  }

  Future<void> _fetchTracking(String queryId) async {
    final cleanId = queryId.trim();
    if (cleanId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final remote = ref.read(shipmentsRemoteDataSourceProvider);
      final data = await remote.fetchTracking(cleanId);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (data.isNotEmpty) {
            _trackingData = data;
            _errorMessage = null;
          } else {
            // Check if we have this package locally in shipmentsProvider
            final localPkg = ref.read(shipmentsProvider).packages.where(
                  (p) =>
                      p.trackingNumber.toLowerCase() == cleanId.toLowerCase() ||
                      p.id.toLowerCase() == cleanId.toLowerCase(),
                );
            if (localPkg.isNotEmpty) {
              final p = localPkg.first;
              _trackingData = {
                'trackingNumber': p.trackingNumber.isNotEmpty ? p.trackingNumber : p.id,
                'courierName': p.courierName,
                'weightKg': p.weightKg,
                'cbm': p.cbm,
                'declaredValueUsd': p.declaredValueUsd,
                'status': p.status,
                'photos': p.photos,
                'originWarehouse': 'Guangzhou Hub (CAN)',
                'destinationWarehouse': 'Lagos Hub (LOS)',
                'events': [
                  {
                    'title': 'Intake Verified & Weighed',
                    'location': 'Guangzhou Facility',
                    'timestamp': p.receivedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
                    'isCompleted': true,
                  },
                ],
              };
            } else {
              _errorMessage = 'No shipment records found for "$cleanId". Please verify the tracking number.';
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load tracking data: ${e.toString()}';
        });
      }
    }
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

                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_errorMessage != null)
                      _buildErrorBanner(_errorMessage!)
                    else if (_trackingData != null) ...[
                      // Shipment Header Card
                      _buildShipmentHeaderCard(_trackingData!),

                      const SizedBox(height: 20),

                      // Consolidated Cargo Specs
                      _buildCargoSpecsSection(_trackingData!),

                      const SizedBox(height: 20),

                      // Checkpoint History Timeline
                      _buildCheckpointHistorySection(_trackingData!),

                      const SizedBox(height: 20),

                      // Proof Photos
                      _buildProofPhotosSection(_trackingData!),

                      const SizedBox(height: 20),

                      // Action buttons
                      _buildActionButtons(_trackingData!),

                      const SizedBox(height: 16),

                      // Help banner
                      _buildHelpBanner(),
                    ] else
                      _buildEmptyPrompt(),
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
      color: AppColors.surface,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.onBackground,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE TRACK & TRACE',
                style: AppTypography.labelCaps.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 9.5,
                  letterSpacing: 0.6,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                'Cargo Radar',
                style: AppTypography.headlineMd.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'API Live',
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ],
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
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _waybillController,
                        onSubmitted: (val) => _fetchTracking(val),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter waybill, tracking # or batch ID...',
                          hintStyle: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    if (_waybillController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                        onPressed: () {
                          _waybillController.clear();
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _fetchTracking(_waybillController.text),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.radar_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Track',
                      style: AppTypography.bodySm.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyPrompt() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.track_changes_rounded, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            'Search Any Consignment',
            style: AppTypography.headlineMd.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your China domestic waybill, 1688 express code, or batch reference to see live transit events.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracking Enquiry Notice',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTypography.bodySm.copyWith(
                    color: const Color(0xFFB91C1C),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shipment Header Card ─────────────────────────────────────────────────
  Widget _buildShipmentHeaderCard(Map<String, dynamic> data) {
    final trackingNum = data['trackingNumber']?.toString() ??
        data['id']?.toString() ??
        '--';
    final status = data['status']?.toString() ?? 'in_transit';
    final courier = data['courierName']?.toString() ??
        data['carrierName']?.toString() ??
        'Express Cargo';
    final shippingType = data['shippingType']?.toString() ?? 'Air Freight';
    final flightNo = data['flightVoyageNo']?.toString() ?? data['flightNo']?.toString();

    final origin = data['originWarehouse']?.toString() ?? 'Guangzhou Hub (CAN)';
    final dest = data['destinationWarehouse']?.toString() ?? 'Lagos Ikeja Hub (LOS)';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CONSIGNMENT REFERENCE',
                            style: AppTypography.labelCaps.copyWith(
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w800,
                              fontSize: 9.5,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trackingNum,
                            style: AppTypography.headlineMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            '$courier • ${shippingType.toUpperCase()}',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF38BDF8),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),

                const SizedBox(height: 20),

                // Flight / Route Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORIGIN',
                            style: AppTypography.labelCaps.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            origin,
                            style: AppTypography.bodySm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(
                            Icons.flight_takeoff_rounded,
                            color: Color(0xFF38BDF8),
                            size: 20,
                          ),
                          if (flightNo != null)
                            Text(
                              flightNo,
                              style: AppTypography.labelCaps.copyWith(
                                color: const Color(0xFF38BDF8),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'DESTINATION',
                            style: AppTypography.labelCaps.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dest,
                            style: AppTypography.bodySm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
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
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFF0284C7);
    String label = status.replaceAll('_', ' ').toUpperCase();

    if (status.contains('received') || status.contains('warehouse')) {
      bg = const Color(0xFF2563EB);
      label = 'AT CHINA HUB';
    } else if (status.contains('transit') || status.contains('flight')) {
      bg = const Color(0xFF0D9488);
      label = 'IN TRANSIT';
    } else if (status.contains('arrived') || status.contains('pickup')) {
      bg = const Color(0xFFD97706);
      label = 'ARRIVED NIGERIA';
    } else if (status.contains('delivered')) {
      bg = const Color(0xFF16A34A);
      label = 'DELIVERED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTypography.labelCaps.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 9.5,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Cargo Specs Section ──────────────────────────────────────────────────
  Widget _buildCargoSpecsSection(Map<String, dynamic> data) {
    final weight = (data['weightKg'] as num?)?.toDouble() ?? 0.0;
    final cbm = (data['cbm'] as num?)?.toDouble() ?? 0.0;
    final declaredUsd = (data['declaredValueUsd'] as num?)?.toDouble() ?? 0.0;
    final desc = data['itemDescription']?.toString() ?? 'General Merchandise / Samples';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Cargo Specifications (Verified API Data)',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSpecTile(
                  label: 'Gross Weight',
                  value: '${weight > 0 ? weight.toStringAsFixed(2) : "--"} KG',
                ),
              ),
              Expanded(
                child: _buildSpecTile(
                  label: 'Volume CBM',
                  value: '${cbm > 0 ? cbm.toStringAsFixed(3) : "--"} CBM',
                ),
              ),
              Expanded(
                child: _buildSpecTile(
                  label: 'Declared Val.',
                  value: '\$${declaredUsd.toStringAsFixed(0)} USD',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    desc,
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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

  Widget _buildSpecTile({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelCaps.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── Checkpoint History ───────────────────────────────────────────────────
  Widget _buildCheckpointHistorySection(Map<String, dynamic> data) {
    final rawEvents = data['events'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Transit Milestones & Clearance Events',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (rawEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Cargo received and awaiting departure batching.',
                style: AppTypography.bodySm.copyWith(color: const Color(0xFF64748B)),
              ),
            )
          else
            ...rawEvents.asMap().entries.map((entry) {
              final idx = entry.key;
              final ev = entry.value as Map<String, dynamic>;
              final title = ev['title']?.toString() ?? ev['status']?.toString() ?? 'Milestone';
              final desc = ev['description']?.toString() ?? '';
              final location = ev['location']?.toString() ?? '';
              final timeRaw = ev['timestamp']?.toString();
              String timeStr = '';
              if (timeRaw != null) {
                final dt = DateTime.tryParse(timeRaw);
                if (dt != null) {
                  timeStr = DateFormat('MMM dd, hh:mm a').format(dt);
                }
              }

              final isFirst = idx == 0;
              final isLast = idx == rawEvents.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: isFirst ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                            shape: BoxShape.circle,
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: AppTypography.bodyMd.copyWith(
                                    fontWeight: isFirst ? FontWeight.w800 : FontWeight.w600,
                                    color: isFirst ? AppColors.onBackground : const Color(0xFF475569),
                                    fontSize: 13,
                                  ),
                                ),
                                if (timeStr.isNotEmpty)
                                  Text(
                                    timeStr,
                                    style: AppTypography.bodySm.copyWith(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 10.5,
                                    ),
                                  ),
                              ],
                            ),
                            if (location.isNotEmpty || desc.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                location.isNotEmpty && desc.isNotEmpty
                                    ? '$location — $desc'
                                    : location.isNotEmpty
                                        ? location
                                        : desc,
                                style: AppTypography.bodySm.copyWith(
                                  color: const Color(0xFF64748B),
                                  fontSize: 11.5,
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
            }),
        ],
      ),
    );
  }

  // ── Proof Photos ─────────────────────────────────────────────────────────
  Widget _buildProofPhotosSection(Map<String, dynamic> data) {
    final rawPhotos = data['photos'] as List<dynamic>? ?? [];
    if (rawPhotos.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Warehouse Intake Proof Photos (${rawPhotos.length})',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: rawPhotos.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final url = rawPhotos[idx].toString();
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.broken_image_outlined, size: 24),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ───────────────────────────────────────────────────────
  Widget _buildActionButtons(Map<String, dynamic> data) {
    final trackingNum = data['trackingNumber']?.toString() ?? '';
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: trackingNum));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Waybill reference copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: Text(
                'Copy Waybill',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onBackground,
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/local-delivery'),
              icon: const Icon(Icons.local_shipping_outlined, size: 16),
              label: Text(
                'Doorstep Delivery',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.headset_mic_outlined, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customs or Clearance Inquiries?',
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  'Lagos & Guangzhou dispatch desks are live',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/support-tickets'),
            child: const Text('Open Ticket'),
          ),
        ],
      ),
    );
  }
}
