import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class SupportTicketsPage extends StatelessWidget {
  const SupportTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support Tickets', style: AppTypography.headlineMd),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.onBackground),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final isOpen = index % 2 == 0;
            return AppCard(
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TKT-100${index}',
                        style: AppTypography.labelCaps.copyWith(color: AppColors.secondary),
                      ),
                      AppStatusBadge(
                        text: isOpen ? 'OPEN' : 'RESOLVED',
                        status: isOpen ? AppBadgeStatus.info : AppBadgeStatus.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Missing package from consolidation',
                    style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: 2h ago',
                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
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
