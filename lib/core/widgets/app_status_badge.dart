import 'package:flutter/material.dart';
import '../../app/theme/app_typography.dart';
import '../../app/theme/app_colors.dart';

enum AppBadgeStatus { success, warning, error, info, pending }

class AppStatusBadge extends StatelessWidget {
  final String text;
  final AppBadgeStatus status;

  const AppStatusBadge({
    super.key,
    required this.text,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case AppBadgeStatus.success:
        backgroundColor = const Color(0xFFD1FAE5); // Emerald-100
        textColor = const Color(0xFF065F46); // Emerald-800
        break;
      case AppBadgeStatus.warning:
        backgroundColor = const Color(0xFFFEF3C7); // Amber-100
        textColor = const Color(0xFF92400E); // Amber-800
        break;
      case AppBadgeStatus.error:
        backgroundColor = const Color(0xFFFEE2E2); // Red-100
        textColor = const Color(0xFF991B1B); // Red-800
        break;
      case AppBadgeStatus.info:
        backgroundColor = const Color(0xFFE0F2FE); // Sky-100
        textColor = const Color(0xFF075985); // Sky-800
        break;
      case AppBadgeStatus.pending:
        backgroundColor = const Color(0xFFF1F5F9); // Slate-100
        textColor = const Color(0xFF475569); // Slate-600
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9999), // Pill-shaped
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.labelCaps.copyWith(color: textColor),
      ),
    );
  }
}
