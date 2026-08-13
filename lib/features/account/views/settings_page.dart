import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
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
  bool _twoFactorAuth = false;
  bool _biometricLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.headlineMd),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'Notifications'),
              const SizedBox(height: 16),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Push Notifications',
                      subtitle: 'Real-time alerts for shipments',
                      value: _pushNotifications,
                      onChanged: (val) => setState(() => _pushNotifications = val),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      title: 'Email Alerts',
                      subtitle: 'Financial transactions & receipts',
                      value: _emailAlerts,
                      onChanged: (val) => setState(() => _emailAlerts = val),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              const SectionHeader(title: 'Security'),
              const SizedBox(height: 16),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Two-Factor Authentication',
                      subtitle: 'Extra security for your account',
                      value: _twoFactorAuth,
                      onChanged: (val) => setState(() => _twoFactorAuth = val),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      title: 'Biometric Login',
                      subtitle: 'Face ID / Fingerprint access',
                      value: _biometricLogin,
                      onChanged: (val) => setState(() => _biometricLogin = val),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: Text('Change Password', style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.secondary,
    );
  }
}
