import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/auth/auth_service.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authServiceProvider);
    final user = authState.user;
    final displayName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : (authState.displayName ?? 'Customer Account');
    final customerId = user?.customerId ?? 'HZ-2026-MEMBER';
    final isVerified = user?.isVerified ?? false;

    final initials = displayName.trim().isNotEmpty
        ? displayName
              .trim()
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
              .take(2)
              .join()
        : 'HZ';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authServiceProvider.notifier).refreshProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ── Profile Header ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
                decoration: const BoxDecoration(color: AppColors.background),
                child: Column(
                  children: [
                    // Avatar with edit badge
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF0F172A,
                                ).withValues(alpha: 0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initials.isNotEmpty ? initials : 'HZ',
                              style: AppTypography.headlineMd.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      displayName,
                      style: AppTypography.headlineMd.copyWith(fontSize: 20),
                    ),

                    if (user?.email.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        user!.email,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // ID row with copy
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: customerId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Customer ID $customerId copied!'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'CUSTOMER ID: ',
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            customerId,
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.copy_rounded,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Account Section ────────────────────────────────────
              _SectionLabel(label: 'Account'),
              const SizedBox(height: 8),

              _ProfileMenuItem(
                icon: Icons.person_outline,
                iconColor: AppColors.secondary,
                title: 'Personal Details',
                subtitle: user?.phone.isNotEmpty == true
                    ? '${user!.phone} · ${user.email}'
                    : 'Update your contact details',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: isVerified
                    ? Icons.verified_rounded
                    : Icons.pending_outlined,
                iconColor: isVerified
                    ? AppColors.success
                    : const Color(0xFFF59E0B),
                title: 'Verification Status',
                subtitle: isVerified
                    ? 'Email & identity verified'
                    : 'Pending verification',
                onTap: () {},
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isVerified
                                ? AppColors.success
                                : const Color(0xFFF59E0B))
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isVerified ? 'VERIFIED' : 'PENDING',
                    style: AppTypography.labelCaps.copyWith(
                      color: isVerified
                          ? AppColors.success
                          : const Color(0xFFF59E0B),
                      fontSize: 9,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              _ProfileMenuItem(
                icon: Icons.lock_outline,
                iconColor: AppColors.tertiary,
                title: 'Security & Preferences',
                subtitle: 'Change password, app notifications',
                onTap: () => context.push('/settings'),
              ),

              const SizedBox(height: 16),

              // ── Support & Operations Section ───────────────────────
              _SectionLabel(label: 'Support & Operations'),
              const SizedBox(height: 8),

              _ProfileMenuItem(
                icon: Icons.headset_mic_outlined,
                iconColor: AppColors.secondary,
                title: 'My Support Tickets',
                subtitle: 'Track inquiries and resolutions',
                onTap: () => context.push('/support-tickets'),
              ),
              _ProfileMenuItem(
                icon: Icons.warehouse_outlined,
                iconColor: AppColors.primary,
                title: 'Warehouse Addresses',
                subtitle: 'View global receiving centers',
                onTap: () => context.push('/warehouse-addresses'),
              ),

              const SizedBox(height: 16),

              // ── Legal Section ──────────────────────────────────────
              _SectionLabel(label: 'Legal'),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _LegalItem(title: 'Terms of Service', onTap: () {}),
                      const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                        indent: 16,
                        endIndent: 16,
                      ),
                      _LegalItem(title: 'Privacy Policy', onTap: () {}),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Log Out Button ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutConfirmation(context, ref),
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: Text(
                      'Log Out',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error.withValues(alpha: 0.08),
                      foregroundColor: AppColors.error,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24), // Added extra space below the button
              // Version footer
              Text(
                'Hamza RMB Mobile v1.4.2',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),

              const SizedBox(
                height: 90,
              ), // Generous padding to clear shell bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log Out',
          style: AppTypography.headlineMd.copyWith(fontSize: 20),
        ),
        content: Text(
          'Are you sure you want to log out of your HamzaRMB account? You will need to sign in again to view your shipments and wallet.',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authServiceProvider.notifier).logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Log Out',
              style: AppTypography.bodyMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        label,
        style: AppTypography.labelCaps.copyWith(
          color: AppColors.onSurfaceVariant,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Profile Menu Item ──────────────────────────────────────────────────────
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 8),
                          trailing!,
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Legal Item ─────────────────────────────────────────────────────────────
class _LegalItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _LegalItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w500),
            ),
            const Icon(
              Icons.open_in_new,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
