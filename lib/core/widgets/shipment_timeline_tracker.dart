import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

class TimelineStep {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;

  TimelineStep({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class ShipmentTimelineTracker extends StatelessWidget {
  final List<TimelineStep> steps;

  const ShipmentTimelineTracker({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline line and circle
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: step.isCompleted || step.isCurrent
                          ? AppColors.secondary // Teal
                          : Colors.transparent,
                      border: Border.all(
                        color: step.isCompleted || step.isCurrent
                            ? AppColors.secondary
                            : const Color(0xFFCBD5E1), // Slate-300
                        width: 2,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: step.isCompleted
                            ? AppColors.secondary
                            : const Color(0xFFE2E8F0), // Slate-200
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: AppTypography.bodyLg.copyWith(
                          fontWeight: FontWeight.w600,
                          color: step.isCurrent || step.isCompleted
                              ? AppColors.onBackground
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.subtitle,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant, // Slate-500
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
