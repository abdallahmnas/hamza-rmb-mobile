import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class WarehouseAddressesPage extends StatelessWidget {
  const WarehouseAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warehouse Addresses', style: AppTypography.headlineMd),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Use these addresses when shopping on Taobao, 1688, or with suppliers. Ensure you include your Customer ID.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildAddressCard(
              country: 'China (Guangzhou)',
              address:
                  'No. 123 Logistics Park, Baiyun District, Guangzhou, Guangdong Province, China',
              recipient: 'HamzaRMB - HZ-20241001',
              phone: '+86 138 0013 8000',
            ),
            const SizedBox(height: 16),
            _buildAddressCard(
              country: 'UK (London)',
              address:
                  'Unit 4, Heathrow Logistics Hub, London, TW6 2GW, United Kingdom',
              recipient: 'HamzaRMB - HZ-20241001',
              phone: '+44 7911 123456',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required String country,
    required String address,
    required String recipient,
    required String phone,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_city, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                country,
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          _buildDetailRow('Recipient', recipient),
          const SizedBox(height: 12),
          _buildDetailRow('Address', address),
          const SizedBox(height: 12),
          _buildDetailRow('Phone', phone),

          const SizedBox(height: 24),
          AppButton.secondary(text: 'Copy Address Details', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
