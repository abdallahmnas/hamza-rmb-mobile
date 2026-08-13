import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class ConsolidationFlowPage extends StatefulWidget {
  const ConsolidationFlowPage({super.key});

  @override
  State<ConsolidationFlowPage> createState() => _ConsolidationFlowPageState();
}

class _ConsolidationFlowPageState extends State<ConsolidationFlowPage> {
  String _shippingMethod = 'air';
  String _paymentMethod = 'wallet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consolidation Review', style: AppTypography.headlineMd),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Items', '3'),
                    _buildSummaryItem('Total Wt', '7.5kg'),
                    _buildSummaryItem('Total Vol', '0.3 CBM'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Shipping Method
              const SectionHeader(title: 'Shipping Method'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSelectableCard(
                      title: 'Air Freight',
                      subtitle: '5-7 Days',
                      isSelected: _shippingMethod == 'air',
                      onTap: () => setState(() => _shippingMethod = 'air'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSelectableCard(
                      title: 'Sea Freight',
                      subtitle: '45-60 Days',
                      isSelected: _shippingMethod == 'sea',
                      onTap: () => setState(() => _shippingMethod = 'sea'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Payment Method
              const SectionHeader(title: 'Payment Option'),
              const SizedBox(height: 16),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    RadioListTile(
                      value: 'wallet',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                      title: Text('Pay Now (Wallet)', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text('Bal: ¥ 45,250.00', style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                      activeColor: AppColors.secondary,
                    ),
                    const Divider(height: 1),
                    RadioListTile(
                      value: 'delivery',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                      title: Text('Pay on Delivery', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text('Pay when package arrives', style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                      activeColor: AppColors.secondary,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Estimated Cost
              AppCard(
                backgroundColor: AppColors.primary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estimated Cost', style: AppTypography.bodyMd.copyWith(color: const Color(0xFF94A3B8))),
                        const SizedBox(height: 4),
                        Text('¥ 750.00', style: AppTypography.currencyDisplay),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: AppButton.primary(
            text: 'Confirm & Consolidate',
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.headlineMd),
      ],
    );
  }

  Widget _buildSelectableCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          ],
        ),
      ),
    );
  }
}
