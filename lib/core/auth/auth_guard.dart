import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import 'auth_service.dart';

/// A reusable wrapper that protects pages requiring authentication.
///
/// If the user is logged in, renders [child].
/// If not, renders an attractive, illustrated "Login Required" view.
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final String? illustrationPath;
  final String? featureBadge;
  final List<String>? features;

  const AuthGuard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.illustrationPath,
    this.featureBadge,
    this.features,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authServiceProvider);

    if (authState.isLoggedIn) {
      return child;
    }

    return LoginRequiredView(
      title: title ?? 'Sign In Required',
      subtitle: subtitle ??
          'Please log in to your HamzaRMB account to unlock this feature.',
      illustrationPath: illustrationPath,
      featureBadge: featureBadge ?? 'AUTHENTICATION REQUIRED',
      features: features,
    );
  }
}

// ── Login Required View ────────────────────────────────────────────────────
class LoginRequiredView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? illustrationPath;
  final String featureBadge;
  final List<String>? features;

  const LoginRequiredView({
    super.key,
    required this.title,
    required this.subtitle,
    this.illustrationPath,
    required this.featureBadge,
    this.features,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Tag Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D9488),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        featureBadge.toUpperCase(),
                        style: AppTypography.labelCaps.copyWith(
                          color: const Color(0xFF0D9488),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Illustration Card
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 320, maxHeight: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(
                          alpha: isDark ? 0.3 : 0.05,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: illustrationPath != null
                        ? SvgPicture.asset(
                            illustrationPath!,
                            height: 160,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/app_logo.png',
                                height: 110,
                                fit: BoxFit.contain,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/app_logo.png',
                            height: 110,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  title,
                  style: AppTypography.headlineMd.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.onDarkBackground
                        : AppColors.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Subtitle
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Text(
                    subtitle,
                    style: AppTypography.bodyMd.copyWith(
                      color: isDark
                          ? AppColors.onDarkSurface.withValues(alpha: 0.7)
                          : AppColors.onSurfaceVariant,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Benefits Checklist (if provided)
                if (features != null && features!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 330),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: features!.map((feature) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF10B981),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: AppTypography.bodySm.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.onDarkBackground
                                        : AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Login Primary Button
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 330),
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/login'),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: Text(
                      'Log In to Continue',
                      style: AppTypography.bodyLg.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Subtle explore hint
                TextButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  child: Text(
                    'Return to Dashboard',
                    style: AppTypography.bodySm.copyWith(
                      color: const Color(0xFF0D9488),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 50), // Padding to clear bottom navigation
              ],
            ),
          ),
        ),
      ),
    );
  }
}
