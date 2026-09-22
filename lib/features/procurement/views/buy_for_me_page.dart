import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';
import '../presentation/providers/procurement_provider.dart';

class BuyForMePage extends ConsumerStatefulWidget {
  const BuyForMePage({super.key});

  @override
  ConsumerState<BuyForMePage> createState() => _BuyForMePageState();
}

class _BuyForMePageState extends ConsumerState<BuyForMePage> {
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _variantsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _variantsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final url = _urlController.text.trim();
    final name = _nameController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final variants = _variantsController.text.trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a product URL (1688, Taobao, etc.)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the product name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(procurementProvider.notifier).submitRequest(
            productUrl: url,
            specifications: name,
            quantity: quantity,
            notes: variants.isNotEmpty
                ? '$variants (Est Price: $price CNY)'
                : 'Est Price: $price CNY',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Procurement request submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

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
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF0284C7),
                    ), // Sky-600
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Submit product links from 1688, Taobao, or any Chinese supplier and we will purchase and ship it for you.',
                        style: AppTypography.bodySm
                            .copyWith(color: const Color(0xFF075985)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppTextField(
                controller: _urlController,
                labelText: 'Product URL',
                hintText: 'Paste link here (e.g. 1688.com/... )',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                labelText: 'Product Name',
                hintText: 'e.g. Women Summer Dress',
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _quantityController,
                      labelText: 'Quantity',
                      hintText: '1',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _priceController,
                      labelText: 'Estimated Price (¥ CNY)',
                      hintText: '0.00',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _variantsController,
                labelText: 'Variants / Specifications (Optional)',
                hintText: 'Color, Size, Specification notes...',
              ),
              const SizedBox(height: 16),

              AppCard(
                backgroundColor: const Color(0xFFF1F5F9), // Slate-100
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      color: Color(0xFF94A3B8),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Product Image or Specs',
                      style: AppTypography.bodyMd
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '(Optional attachment for sourcing)',
                      style: AppTypography.bodySm
                          .copyWith(color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              AppButton.primary(
                text: _isSubmitting
                    ? 'Submitting Request...'
                    : 'Submit Procurement Request',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

