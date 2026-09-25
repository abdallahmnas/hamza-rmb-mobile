import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../data/models/clearance_request_model.dart';

class ClearanceConfirmationPage extends StatelessWidget {
  final ClearanceRequestModel request;

  const ClearanceConfirmationPage({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(request.createdAt);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.onBackground),
            onPressed: () => context.go('/customs-clearance'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Animated Success Checkmark
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Color(0xFF059669),
                    size: 42,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Request Submitted',
                style: AppTypography.headlineLg.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Your customs clearance request has been received and assigned to our Lagos clearing operations desk.',
                style: AppTypography.bodyMd.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Request Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'REQUEST NUMBER',
                          style: AppTypography.labelCaps.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            request.requestNumber,
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1D4ED8),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 22, color: Color(0xFFE2E8F0)),
                    _buildInfoRow('Date Submitted', dateStr),
                    _buildInfoRow('Shipment Type', '${request.shipmentType} Cargo'),
                    _buildInfoRow('Port of Entry', request.portOfEntry),
                    _buildInfoRow('Origin Country', request.originCountry),
                    _buildInfoRow('Cargo Items', request.itemsSummary),
                    _buildInfoRow(
                      'Initial Status',
                      ClearanceStatus.getLabel(request.status),
                      statusColor: const Color(0xFF059669),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Color(0xFF2563EB), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can view real-time clearance milestones, messages, and uploaded documents in your tracking portal.',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF1E40AF),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Primary CTA: Track Request
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.pushReplacement(
                      '/customs-clearance/details/${request.id}',
                      extra: request,
                    );
                  },
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
                      const Icon(Icons.track_changes_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Track Request',
                        style: AppTypography.bodyLg.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Secondary CTA: Back to Customs Clearance
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/customs-clearance'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Back to Customs Clearance',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                fontWeight: FontWeight.w700,
                color: statusColor ?? AppColors.onBackground,
                fontSize: 12,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
