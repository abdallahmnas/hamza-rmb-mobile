import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        'Hamza',
                        style: AppTypography.headlineMd,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      'ID: HZ-2024',
                      style: AppTypography.labelCaps.copyWith(color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Wallet Glance
              AppCard(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Balance',
                          style: AppTypography.bodyMd.copyWith(color: const Color(0xFF94A3B8)),
                        ),
                        Icon(Icons.visibility_outlined, color: const Color(0xFF94A3B8), size: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¥ 45,250.00',
                      style: AppTypography.currencyDisplay,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiary,
                        foregroundColor: AppColors.onBackground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: Text(
                        'Fund Wallet',
                        style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Quick Actions
              const SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _QuickActionItem(
                    icon: Icons.local_shipping_outlined,
                    label: 'Track',
                    onTap: () {},
                  ),
                  _QuickActionItem(
                    icon: Icons.currency_exchange_outlined,
                    label: 'Exchange',
                    onTap: () {},
                  ),
                  _QuickActionItem(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Buy For Me',
                    onTap: () {},
                  ),
                  _QuickActionItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Consolidate',
                    onTap: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Active Summary Cards
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warehouse_outlined, color: AppColors.secondary),
                          const SizedBox(height: 12),
                          Text(
                            '12',
                            style: AppTypography.headlineMd,
                          ),
                          Text(
                            'At Warehouse',
                            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.flight_takeoff_outlined, color: AppColors.secondary),
                          const SizedBox(height: 12),
                          Text(
                            '3',
                            style: AppTypography.headlineMd,
                          ),
                          Text(
                            'In Transit',
                            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Recent Activity
              SectionHeader(
                title: 'Recent Activity',
                actionText: 'View All',
                onActionPressed: () {},
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.inventory_2_outlined, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shipment Dispatched',
                            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Tracking: HZ-982347',
                            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '2h ago',
                      style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
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
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.secondary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
