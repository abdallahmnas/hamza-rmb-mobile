import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account', style: AppTypography.headlineMd),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Header
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'H',
                          style: AppTypography.headlineMd.copyWith(color: AppColors.onPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hamza', style: AppTypography.headlineMd),
                          Text('hello@example.com', style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Menu Items
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'Warehouse Addresses',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.headset_mic_outlined,
                title: 'Support Tickets',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {},
              ),
              
              const SizedBox(height: 24),
              
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Log Out',
                textColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () {},
                showChevron: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    bool showChevron = true,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // Slate-100
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.onBackground),
        ),
        title: Text(
          title,
          style: AppTypography.bodyLg.copyWith(
            fontWeight: FontWeight.w500,
            color: textColor ?? AppColors.onBackground,
          ),
        ),
        trailing: showChevron ? const Icon(Icons.chevron_right) : null,
      ),
    );
  }
}
