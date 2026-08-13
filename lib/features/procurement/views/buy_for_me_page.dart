import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class BuyForMePage extends StatelessWidget {
  const BuyForMePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy For Me', style: AppTypography.headlineMd),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE), // Sky-100
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF0284C7)), // Sky-600
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Submit product links from 1688, Taobao, or any Chinese supplier and we will buy it for you.',
                        style: AppTypography.bodySm.copyWith(color: const Color(0xFF075985)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              const AppTextField(
                labelText: 'Product URL',
                hintText: 'Paste link here (e.g. 1688.com/... )',
              ),
              const SizedBox(height: 16),
              const AppTextField(
                labelText: 'Product Name',
                hintText: 'e.g. Women Summer Dress',
              ),
              const SizedBox(height: 16),
              
              Row(
                children: const [
                  Expanded(
                    child: AppTextField(
                      labelText: 'Quantity',
                      hintText: '1',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      labelText: 'Price (CNY)',
                      hintText: '0.00',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              const AppTextField(
                labelText: 'Variants (Optional)',
                hintText: 'Color, Size, etc.',
              ),
              const SizedBox(height: 16),
              
              AppCard(
                backgroundColor: const Color(0xFFF1F5F9), // Slate-100
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, color: Color(0xFF94A3B8), size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Product Image',
                      style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '(Optional)',
                      style: AppTypography.bodySm.copyWith(color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              AppButton.primary(
                text: 'Submit Procurement Request',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
