import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _smsAlerts = false;
  bool _biometricLogin = true;
  bool _twoFactorAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.onBackground,
          ),
        ),
        title: Text(
          'Settings',
          style: AppTypography.headlineMd.copyWith(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── NOTIFICATIONS ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'NOTIFICATIONS',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _SettingsToggleTile(
              icon: Icons.notifications_active_outlined,
              iconBgColor: AppColors.secondary.withValues(alpha: 0.1),
              iconColor: AppColors.secondary,
              title: 'Push Notifications',
              subtitle: 'Real-time shipment tracking alerts',
              value: _pushNotifications,
              onChanged: (v) => setState(() => _pushNotifications = v),
            ),
            _SettingsToggleTile(
              icon: Icons.email_outlined,
              iconBgColor: AppColors.secondary.withValues(alpha: 0.1),
              iconColor: AppColors.secondary,
              title: 'Email Alerts',
              subtitle: 'Daily summaries and invoices',
              value: _emailAlerts,
              onChanged: (v) => setState(() => _emailAlerts = v),
            ),
            _SettingsToggleTile(
              icon: Icons.sms_outlined,
              iconBgColor: const Color(0xFFF1F5F9),
              iconColor: AppColors.onSurfaceVariant,
              title: 'SMS Alerts',
              subtitle: 'Critical wallet transaction alerts',
              value: _smsAlerts,
              onChanged: (v) => setState(() => _smsAlerts = v),
            ),

            const SizedBox(height: 24),

            // ── SECURITY ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'SECURITY',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _SettingsToggleTile(
              icon: Icons.fingerprint,
              iconBgColor: AppColors.primary.withValues(alpha: 0.08),
              iconColor: AppColors.primary,
              title: 'Biometric Login',
              subtitle: 'Use FaceID / Fingerprint',
              value: _biometricLogin,
              onChanged: (v) => setState(() => _biometricLogin = v),
            ),
            _SettingsToggleTile(
              icon: Icons.verified_user_outlined,
              iconBgColor: const Color(0xFFF1F5F9),
              iconColor: AppColors.onSurfaceVariant,
              title: 'Two-Factor Auth (2FA)',
              subtitle: 'Added layer of security',
              value: _twoFactorAuth,
              onChanged: (v) => setState(() => _twoFactorAuth = v),
            ),

            // Change Password (nav item)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsNavTile(
                icon: Icons.vpn_key_outlined,
                iconBgColor: const Color(0xFFF1F5F9),
                iconColor: AppColors.onSurfaceVariant,
                title: 'Change Password',
                onTap: () {},
              ),
            ),

            const SizedBox(height: 24),

            // ── APP PREFERENCES ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'APP PREFERENCES',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsNavTile(
                icon: Icons.language,
                iconBgColor: AppColors.secondary.withValues(alpha: 0.1),
                iconColor: AppColors.secondary,
                title: 'Language',
                subtitle: 'English (US)',
                onTap: () {},
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsNavTile(
                icon: Icons.monetization_on_outlined,
                iconBgColor: AppColors.tertiary.withValues(alpha: 0.1),
                iconColor: AppColors.tertiary,
                title: 'Default Currency',
                subtitle: 'CNY (¥)',
                onTap: () {},
              ),
            ),

            const SizedBox(height: 40),

            // ── App Info Footer ──────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Hamza RMB Mobile',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 2.4.1 (Build 492)',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Check for Updates',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Settings Toggle Tile ───────────────────────────────────────────────────
class _SettingsToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
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
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppColors.secondary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFCBD5E1),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Settings Nav Tile ──────────────────────────────────────────────────────
class _SettingsNavTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsNavTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
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
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
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
    );
  }
}
