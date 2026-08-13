import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Exchange', style: AppTypography.headlineMd),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Live Rates Card
              AppCard(
                backgroundColor: AppColors.surfaceVariant,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Rate (NGN to CNY)', style: AppTypography.bodySm),
                        const SizedBox(height: 4),
                        Text('1 CNY = 1,450 NGN', style: AppTypography.headlineMd.copyWith(color: AppColors.secondary)),
                      ],
                    ),
                    Icon(Icons.trending_up, color: AppColors.secondary),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Exchange Form
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Convert Amount', style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _amountController,
                      labelText: 'Amount (NGN)',
                      hintText: '0.00',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Text('₦', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(child: Icon(Icons.swap_vert, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 16),
                    AppTextField(
                      labelText: 'You Receive (CNY)',
                      hintText: '0.00',
                      readOnly: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Text('¥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Receiving Account Details
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Receiving Account', style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Platform',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      value: 'alipay',
                      items: const [
                        DropdownMenuItem(value: 'alipay', child: Text('Alipay')),
                        DropdownMenuItem(value: 'wechat', child: Text('WeChat Pay')),
                        DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                      ],
                      onChanged: (val) {},
                    ),
                    const SizedBox(height: 16),
                    const AppTextField(
                      labelText: 'Account Name',
                      hintText: 'Enter name',
                    ),
                    const SizedBox(height: 16),
                    const AppTextField(
                      labelText: 'Account Number',
                      hintText: 'Enter number',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              AppButton.primary(
                text: 'Proceed to Payment',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
