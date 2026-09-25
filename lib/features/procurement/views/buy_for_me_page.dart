import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/services/media_upload_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_bar_logo_title.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';
import '../../home/presentation/providers/system_metadata_provider.dart';
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
  final _notesController = TextEditingController();
  
  final _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  File? _localImageFile;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_onPriceOrQtyChanged);
    _priceController.addListener(_onPriceOrQtyChanged);
  }

  void _onPriceOrQtyChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _variantsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        final file = File(picked.path);
        setState(() {
          _localImageFile = file;
          _isUploadingImage = true;
          _uploadedImageUrl = null;
        });

        try {
          final url = await ref.read(mediaUploadServiceProvider).uploadImage(file);
          if (mounted) {
            setState(() {
              _uploadedImageUrl = url;
              _isUploadingImage = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product image uploaded successfully!'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (uploadError) {
          if (mounted) {
            setState(() {
              _isUploadingImage = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $uploadError'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _localImageFile = null;
      _uploadedImageUrl = null;
      _isUploadingImage = false;
    });
  }

  Future<void> _handleSubmit() async {
    final url = _urlController.text.trim();
    final name = _nameController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final variants = _variantsController.text.trim();
    final description = _notesController.text.trim();

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

    if (_isUploadingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for product image to finish uploading...'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final notesBuffer = StringBuffer();
      if (description.isNotEmpty) {
        notesBuffer.write(description);
      }
      if (variants.isNotEmpty) {
        if (notesBuffer.isNotEmpty) notesBuffer.write(' | Variants: ');
        notesBuffer.write(variants);
      }
      if (price > 0 && notesBuffer.isEmpty) {
        notesBuffer.write('Est Price: ¥$price CNY');
      }
      if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) {
        if (notesBuffer.isNotEmpty) notesBuffer.write('\n');
        notesBuffer.write('[Product Image: $_uploadedImageUrl]');
      }

      final notes = notesBuffer.isNotEmpty ? notesBuffer.toString() : null;

      final success = await ref.read(procurementProvider.notifier).submitRequest(
            productUrl: url,
            specifications: name,
            quantity: quantity,
            notes: notes,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Procurement request submitted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else {
          final err = ref.read(procurementProvider).error ?? 'Failed to submit procurement request';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
            ),
          );
        }
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

  Widget _buildImageAttachmentSection() {
    if (_localImageFile != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isUploadingImage ? AppColors.secondary : const Color(0xFF10B981),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _localImageFile!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Image Attached',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _isUploadingImage
                        ? 'Uploading to cloud server...'
                        : (_uploadedImageUrl != null ? 'Uploaded to cloud ✓' : 'Ready for submission'),
                    style: AppTypography.bodySm.copyWith(
                      color: _isUploadingImage
                          ? AppColors.secondary
                          : const Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_isUploadingImage)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: _removeImage,
              ),
          ],
        ),
      );
    }

    return AppCard(
      backgroundColor: const Color(0xFFF1F5F9), // Slate-100
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            color: Color(0xFF64748B),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload Product Image or Specs',
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            '(Optional photo attachment for sourcing accuracy)',
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('Take Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarLogoTitle(
          title: 'Buy For Me',
          style: AppTypography.headlineMd,
        ),
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

              AppTextField(
                controller: _notesController,
                labelText: 'Description',
                hintText: 'Please confirm stock',
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 16),

              _buildImageAttachmentSection(),

              const SizedBox(height: 20),

              // ── Cost Breakdown Card ──────────────────────────────────────
              _buildCostEstimationCard(
                quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
                priceCny: double.tryParse(_priceController.text.trim()) ?? 0.0,
              ),

              const SizedBox(height: 24),
              AppButton.primary(
                text: _isSubmitting
                    ? 'Submitting Request...'
                    : 'Submit Procurement Request',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handleSubmit,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostEstimationCard({
    required int quantity,
    required double priceCny,
  }) {
    final metaState = ref.watch(systemMetadataProvider);
    final settings = metaState.settings;
    final cnyRate = settings.cnyExchangeRate > 0 ? settings.cnyExchangeRate : 215.0;
    final fixedFee = settings.buyForMeFixedFee > 0 ? settings.buyForMeFixedFee : 1000.0;

    final subtotalCny = priceCny * quantity;
    final subtotalNgn = subtotalCny * cnyRate;
    final grandTotalNgn = subtotalNgn + (subtotalCny > 0 ? fixedFee : 0.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ESTIMATED COST BREAKDOWN',
                style: AppTypography.labelCaps.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '1¥ = ₦${cnyRate.toStringAsFixed(2)}',
                  style: AppTypography.labelCaps.copyWith(
                    color: const Color(0xFF0369A1),
                    fontWeight: FontWeight.w800,
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items Subtotal ($quantity × ¥${priceCny.toStringAsFixed(2)})',
                style: AppTypography.bodySm.copyWith(color: const Color(0xFF64748B)),
              ),
              Text(
                '¥${subtotalCny.toStringAsFixed(2)} (₦${_currencyFormat.format(subtotalNgn)})',
                style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Buy For Me Service Fee (Fixed)',
                style: AppTypography.bodySm.copyWith(color: const Color(0xFF64748B)),
              ),
              Text(
                '₦${_currencyFormat.format(fixedFee)}',
                style: AppTypography.bodySm.copyWith(
                  color: const Color(0xFF0284C7),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Total',
                style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                '₦${_currencyFormat.format(grandTotalNgn)}',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


