import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class ShipmentsListPage extends StatelessWidget {
  const ShipmentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Shipments',
          style: AppTypography.headlineMd,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.onBackground),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: 5,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return AppCard(
              onTap: () {
                // Navigate to details
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tracking: HZ-98234${index}',
                        style: AppTypography.labelCaps.copyWith(color: AppColors.secondary),
                      ),
                      AppStatusBadge(
                        text: index == 0 ? 'IN TRANSIT' : 'DELIVERED',
                        status: index == 0 ? AppBadgeStatus.info : AppBadgeStatus.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Summer Collection Restock',
                    style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '12.5 kg • 0.5 CBM',
                        style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Delivery',
                            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          Text(
                            'Oct 24, 2024',
                            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
