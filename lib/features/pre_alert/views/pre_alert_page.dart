import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../home/presentation/providers/system_metadata_provider.dart';
import '../../shipments/presentation/providers/shipments_provider.dart';

class PreAlertPage extends ConsumerStatefulWidget {
  const PreAlertPage({super.key});

  @override
  ConsumerState<PreAlertPage> createState() => _PreAlertPageState();
}

class _PreAlertPageState extends ConsumerState<PreAlertPage> {
  // Required fields
  String? _selectedWarehouse;
  final _originCountryController = TextEditingController();
  String _selectedPaymentOption = 'pay_before_dispatch';
  final _estimatedItemsController = TextEditingController(text: '12');

  // Optional fields
  final _trackingController = TextEditingController();
  final _supplierNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final List<String> _photos = [];

  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  final Map<String, String> _paymentOptions = {
    'pay_before_dispatch': 'Pay Before Dispatch',
    'pay_on_delivery': 'Pay On Delivery',
    'pay_with_wallet': 'Pay With Wallet Balance',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(systemMetadataProvider.notifier).refreshAll();
    });
  }

  @override
  void dispose() {
    _originCountryController.dispose();
    _estimatedItemsController.dispose();
    _trackingController.dispose();
    _supplierNameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _photos.add(picked.name);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selection error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _incrementItems() {
    final current = int.tryParse(_estimatedItemsController.text) ?? 1;
    setState(() {
      _estimatedItemsController.text = (current + 1).toString();
    });
  }

  void _decrementItems() {
    final current = int.tryParse(_estimatedItemsController.text) ?? 1;
    if (current > 1) {
      setState(() {
        _estimatedItemsController.text = (current - 1).toString();
      });
    }
  }

  Future<void> _handleSubmit() async {
    final originCountry = _originCountryController.text.trim().isNotEmpty
        ? _originCountryController.text.trim()
        : (_selectedWarehouse ?? '');
    final paymentOption = _selectedPaymentOption;
    final estimatedItems =
        int.tryParse(_estimatedItemsController.text.trim()) ?? 0;

    if (originCountry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a warehouse'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (estimatedItems <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter estimated items count (at least 1)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final tracking = _trackingController.text.trim();
      final supplier = _supplierNameController.text.trim();
      final description = _descriptionController.text.trim();
      final notes = _notesController.text.trim();

      final success = await ref.read(shipmentsProvider.notifier).submitPreAlert(
            originCountry: originCountry,
            paymentOption: paymentOption,
            estimatedItems: estimatedItems,
            chineseTrackingNo: tracking.isNotEmpty ? tracking : null,
            supplierName: supplier.isNotEmpty ? supplier : null,
            description: description.isNotEmpty ? description : null,
            notes: notes.isNotEmpty ? notes : null,
            photos: _photos.isNotEmpty ? _photos : null,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pre-alert submitted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else {
          final err = ref.read(shipmentsProvider).error ??
              'Failed to submit pre-alert';
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).user;
    final customerId = user?.customerId ?? '';
    final facilities = ref.watch(facilitiesProvider);
    final warehouseOptions = facilities.isNotEmpty
        ? facilities.map((f) => '${f.name} (${f.location})').toList()
        : [
            'Guangzhou Primary Hub (Guangzhou, China)',
            'Lagos Central Distribution Hub (Lagos, Nigeria)',
            'Abuja Express Station (Abuja, Nigeria)',
          ];

    if (_selectedWarehouse == null || !warehouseOptions.contains(_selectedWarehouse)) {
      _selectedWarehouse = warehouseOptions.first;
      _originCountryController.text = _selectedWarehouse!;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.onBackground,
          ),
        ),
        title: Text(
          'Pre-Alert Cargo',
          style: AppTypography.headlineMd.copyWith(fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/pre-alert-history'),
            icon: const Icon(Icons.history_rounded, size: 18),
            label: Text(
              'History',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Customer Banner ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.badge_outlined,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CUSTOMER ID',
                        style: AppTypography.labelCaps.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customerId.isNotEmpty ? customerId : 'Not Assigned',
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Text(
                      'READY',
                      style: AppTypography.labelCaps.copyWith(
                        color: const Color(0xFF16A34A),
                        fontWeight: FontWeight.w800,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── 1. Warehouse (Required) ───────────────────────────────
            _buildSectionHeader(
              '1. Warehouse *',
              Icons.warehouse_outlined,
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedWarehouse,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: warehouseOptions
                      .map(
                        (wh) => DropdownMenuItem(
                          value: wh,
                          child: Text(
                            wh,
                            style: AppTypography.bodyMd.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedWarehouse = val;
                        _originCountryController.text = val;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ── 2. Payment Option & Estimated Items (Required) ─────────
            _buildSectionHeader(
              '2. Payment Option & Quantity *',
              Icons.payments_outlined,
            ),
            const SizedBox(height: 10),

            // Payment Option Selector
            Column(
              children: _paymentOptions.entries.map((entry) {
                final isSelected = _selectedPaymentOption == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () =>
                        setState(() => _selectedPaymentOption = entry.key),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF0FDF4)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.secondary
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? AppColors.secondary
                                : const Color(0xFF94A3B8),
                            size: 19,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            entry.value,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.onBackground
                                  : AppColors.onSurfaceVariant,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Estimated Items
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Items *',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total parcel count arriving China hub',
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _decrementItems,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.primary,
                        iconSize: 24,
                      ),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _estimatedItemsController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _incrementItems,
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                        iconSize: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 3. Shipment Information (Optional Fields) ──────────────
            _buildSectionHeader(
              '3. Shipment Details (Optional)',
              Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 10),

            AppTextField(
              controller: _trackingController,
              labelText: 'Chinese Tracking Number',
              hintText: 'e.g. 11224 or SF10928374',
              prefixIcon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
            ),
            const SizedBox(height: 12),

            AppTextField(
              controller: _supplierNameController,
              labelText: 'Supplier / Store Name',
              hintText: 'e.g. Mister Shop, 1688 Factory',
              prefixIcon: const Icon(Icons.storefront_outlined, size: 20),
            ),
            const SizedBox(height: 12),

            AppTextField(
              controller: _descriptionController,
              labelText: 'Package Description',
              hintText: 'e.g. Testing, Clothing, Electronics',
              prefixIcon: const Icon(Icons.description_outlined, size: 20),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            AppTextField(
              controller: _notesController,
              labelText: 'Special Notes / Instructions',
              hintText: 'e.g. Highly sensitive, Fragile glass items',
              prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // ── 4. Photos / Documents (Optional) ──────────────────────
            _buildSectionHeader(
              '4. Photos / Invoices (Optional)',
              Icons.photo_library_outlined,
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_photos.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_photos.length, (index) {
                        final photoName = _photos[index];
                        return Chip(
                          avatar: const Icon(
                            Icons.image_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            photoName,
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removePhoto(index),
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: const Text('Take Photo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.gallery),
                        icon:
                            const Icon(Icons.photo_library_outlined, size: 16),
                        label: const Text('From Gallery'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Submit Button ────────────────────────────────────────
            AppButton.primary(
              text: _isSubmitting
                  ? 'Submitting Pre-alert...'
                  : 'Submit Pre-alert',
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _handleSubmit,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: AppColors.onBackground,
          ),
        ),
      ],
    );
  }
}
