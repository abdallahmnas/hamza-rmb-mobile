import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../../core/widgets/shipment_timeline_tracker.dart';
import '../../../core/widgets/section_header.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class ShipmentDetailsPage extends StatelessWidget {
  const ShipmentDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shipment Details', style: AppTypography.headlineMd),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tracking: HZ-982347',
                          style: AppTypography.labelCaps.copyWith(color: AppColors.secondary),
                        ),
                        const AppStatusBadge(
                          text: 'IN TRANSIT',
                          status: AppBadgeStatus.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Summer Collection Restock',
                      style: AppTypography.headlineMd,
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem('Weight', '12.5 kg'),
                        _buildDetailItem('Volume', '0.5 CBM'),
                        _buildDetailItem('Items', '3 Boxes'),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const SectionHeader(title: 'Tracking History'),
              const SizedBox(height: 16),
              
              AppCard(
                child: ShipmentTimelineTracker(
                  steps: [
                    TimelineStep(
                      title: 'Dispatched from China Hub',
                      subtitle: 'Oct 15, 2024 - 14:30',
                      isCompleted: true,
                    ),
                    TimelineStep(
                      title: 'In Transit',
                      subtitle: 'Expected Arrival: Oct 20',
                      isCompleted: true,
                      isCurrent: true,
                    ),
                    TimelineStep(
                      title: 'Arrived at Destination Hub',
                      subtitle: 'Pending Arrival',
                    ),
                    TimelineStep(
                      title: 'Out for Delivery',
                      subtitle: 'Pending Dispatch',
                    ),
                    TimelineStep(
                      title: 'Delivered',
                      subtitle: 'Pending Delivery',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const SectionHeader(title: 'Associated Costs'),
              const SizedBox(height: 16),
              
              AppCard(
                child: Column(
                  children: [
                    _buildCostItem('Freight Charge', '¥ 1,250.00'),
                    const SizedBox(height: 12),
                    _buildCostItem('Customs Duty', '¥ 350.00'),
                    const SizedBox(height: 12),
                    _buildCostItem('Insurance', '¥ 120.00'),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Cost',
                          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '¥ 1,720.00',
                          style: AppTypography.headlineMd.copyWith(color: AppColors.tertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildCostItem(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        Text(
          amount,
          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
