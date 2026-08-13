import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/section_header.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class LocalDeliveryPage extends StatelessWidget {
  const LocalDeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Delivery', style: AppTypography.headlineMd),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Arrange dispatch for packages that have arrived at the destination hub.',
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              
              const SectionHeader(title: 'Select Package'),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Available Packages',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'pkg1', child: Text('HZ-982347 (12.5 kg)')),
                  DropdownMenuItem(value: 'pkg2', child: Text('HZ-982348 (5.0 kg)')),
                ],
                onChanged: (val) {},
              ),
              
              const SizedBox(height: 24),
              
              const SectionHeader(title: 'Delivery Address'),
              const SizedBox(height: 16),
              
              const AppTextField(
                labelText: 'Street Address',
                hintText: '123 Main St',
              ),
              const SizedBox(height: 16),
              const AppTextField(
                labelText: 'City / State',
                hintText: 'Lagos, LA',
              ),
              const SizedBox(height: 16),
              const AppTextField(
                labelText: 'Contact Phone',
                hintText: '+234 ...',
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 24),
              
              const SectionHeader(title: 'Delivery Speed'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildSpeedCard(
                      title: 'Standard',
                      subtitle: '2-3 Days',
                      price: '₦ 2,500',
                      isSelected: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSpeedCard(
                      title: 'Express',
                      subtitle: 'Same Day',
                      price: '₦ 5,000',
                      isSelected: false,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              AppButton.primary(
                text: 'Schedule Delivery',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedCard({
    required String title,
    required String subtitle,
    required String price,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0FDF4) : AppColors.surface, // Emerald-50 light
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.secondary : const Color(0xFFE2E8F0),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.secondary : const Color(0xFF94A3B8),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(price, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.secondary)),
        ],
      ),
    );
  }
}
