import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/media_upload_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/auth/auth_service.dart';
import '../../home/presentation/providers/system_metadata_provider.dart';
import '../presentation/providers/wallet_provider.dart';

class FundWalletPage extends ConsumerStatefulWidget {
  const FundWalletPage({super.key});

  @override
  ConsumerState<FundWalletPage> createState() => _FundWalletPageState();
}

class _FundWalletPageState extends ConsumerState<FundWalletPage> {
  final _amountController = TextEditingController(text: '100000');
  String _paymentMethod = 'bank_transfer';
  late String _reference;

  File? _localReceiptFile;
  String? _uploadedReceiptUrl;
  bool _isUploadingReceipt = false;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'en_US');

  final List<double> _quickAmounts = [
    20000,
    50000,
    100000,
    250000,
    500000,
    1000000,
  ];

  @override
  void initState() {
    super.initState();
    // Generate unique payment reference
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final randomSuffix = ts.length > 6 ? ts.substring(ts.length - 6) : ts;
    _reference = 'PAY-$randomSuffix';

    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String toastMessage) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(toastMessage),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickReceipt(ImageSource source) async {
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
          _localReceiptFile = file;
          _isUploadingReceipt = true;
          _uploadedReceiptUrl = null;
        });

        try {
          final url =
              await ref.read(mediaUploadServiceProvider).uploadImage(file);
          if (mounted) {
            setState(() {
              _uploadedReceiptUrl = url;
              _isUploadingReceipt = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment receipt uploaded successfully!'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isUploadingReceipt = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload receipt: $e'),
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
            content: Text('Image selection error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeReceipt() {
    setState(() {
      _localReceiptFile = null;
      _uploadedReceiptUrl = null;
      _isUploadingReceipt = false;
    });
  }

  Future<void> _handleSubmit() async {
    final rawAmount = double.tryParse(
          _amountController.text.replaceAll(',', '').trim(),
        ) ??
        0.0;

    if (rawAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid top-up amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_isUploadingReceipt) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for receipt upload to complete...'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref.read(walletProvider.notifier).topup(
          amount: rawAmount,
          paymentMethod: _paymentMethod,
          reference: _reference,
          imageUrl: _uploadedReceiptUrl,
        );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      _showSuccessDialog(rawAmount, _reference);
    } else {
      final error =
          ref.read(walletProvider).error ?? 'Failed to submit funding request';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog(double amount, String refCode) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 42,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Funding Request Submitted!',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your wallet top-up request of ₦${_currencyFormat.format(amount)} has been recorded. Your balance will update automatically upon bank confirmation.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'REFERENCE:',
                    style: AppTypography.labelCaps.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    refCode,
                    style: AppTypography.bodyMd.copyWith(
                      color: const Color(0xFF38BDF8),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop(); // Return to wallet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Back to Wallet',
                  style: AppTypography.bodyMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metaState = ref.watch(systemMetadataProvider);
    final settings = metaState.settings;
    final wallet = ref.watch(walletProvider).wallet;
    final user = ref.watch(authServiceProvider).user;

    final bankName = settings.ngnEscrowBankName;
    final accountNo = settings.ngnEscrowAccountNo;
    final accountName = settings.ngnEscrowAccountName;

    final parsedAmount = double.tryParse(
          _amountController.text.replaceAll(',', '').trim(),
        ) ??
        0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Fund Wallet',
          style: AppTypography.headlineMd.copyWith(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Current Balance & Summary Card ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT WALLET BALANCE',
                        style: AppTypography.labelCaps.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₦${_currencyFormat.format(wallet.balance)}',
                        style: AppTypography.headlineMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: Color(0xFF38BDF8),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ESCROW SECURED',
                          style: AppTypography.labelCaps.copyWith(
                            color: const Color(0xFF38BDF8),
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── 1. Enter Top-up Amount ──────────────────────────────────────
            _buildSectionTitle('1. Enter Funding Amount', Icons.payments_outlined),
            const SizedBox(height: 10),

            AppTextField(
              controller: _amountController,
              labelText: 'Top-up Amount (NGN)',
              hintText: 'e.g. 100,000',
              prefixIcon: const Icon(Icons.currency_exchange_rounded, size: 20),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            // Quick chip selectors
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickAmounts.map((amt) {
                  final isSelected = parsedAmount == amt;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        '₦${_currencyFormat.format(amt)}',
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _amountController.text = amt.toStringAsFixed(0);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ── 2. Payment Method ───────────────────────────────────────────
            _buildSectionTitle('2. Payment Method', Icons.account_balance_outlined),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildPaymentMethodCard(
                    id: 'bank_transfer',
                    title: 'Bank Transfer',
                    subtitle: 'Direct Escrow Account',
                    icon: Icons.account_balance_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPaymentMethodCard(
                    id: 'card',
                    title: 'Debit Card',
                    subtitle: 'Instant Online Pay',
                    icon: Icons.credit_card_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── 3. Dedicated Escrow Account Details ─────────────────────────
            _buildSectionTitle(
                '3. Transfer to Escrow Account', Icons.verified_outlined),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildAccountDetailRow(
                    label: 'BANK NAME',
                    value: bankName,
                    isCopyable: false,
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildAccountDetailRow(
                    label: 'ACCOUNT NUMBER',
                    value: accountNo,
                    isCopyable: true,
                    highlight: true,
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildAccountDetailRow(
                    label: 'ACCOUNT NAME',
                    value: accountName,
                    isCopyable: false,
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildAccountDetailRow(
                    label: 'PAYMENT REFERENCE',
                    value: _reference,
                    isCopyable: true,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final allText =
                            'Bank: $bankName\nAccount Number: $accountNo\nAccount Name: $accountName\nReference: $_reference\nUser: ${user?.fullName ?? ""}';
                        _copyToClipboard(
                            allText, 'All escrow account details copied!');
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy All Bank Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 4. Proof of Payment Upload ──────────────────────────────────
            _buildSectionTitle(
                '4. Upload Payment Screenshot (Optional)', Icons.receipt_long_outlined),
            const SizedBox(height: 10),

            _buildReceiptUploadCard(),

            const SizedBox(height: 30),

            // ── 5. Submit Button ────────────────────────────────────────────
            AppButton.primary(
              text: _isSubmitting
                  ? 'Submitting Funding Request...'
                  : 'Confirm & Submit (₦${_currencyFormat.format(parsedAmount)})',
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _handleSubmit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
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
                  icon,
                  color: isSelected
                      ? AppColors.secondary
                      : const Color(0xFF64748B),
                  size: 22,
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.secondary,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.bodySm.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetailRow({
    required String label,
    required String value,
    required bool isCopyable,
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelCaps.copyWith(
                color: const Color(0xFF94A3B8),
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: highlight ? 16 : 13.5,
                color: highlight ? AppColors.secondary : const Color(0xFF0F172A),
                letterSpacing: highlight ? 1.0 : 0,
              ),
            ),
          ],
        ),
        if (isCopyable)
          GestureDetector(
            onTap: () => _copyToClipboard(value, '$value copied!'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.copy_rounded,
                      color: Color(0xFF2563EB), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Copy',
                    style: AppTypography.labelCaps.copyWith(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReceiptUploadCard() {
    if (_localReceiptFile != null || _uploadedReceiptUrl != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _localReceiptFile != null
                  ? Image.file(
                      _localReceiptFile!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: _uploadedReceiptUrl!,
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
                    'Receipt Attached',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isUploadingReceipt
                        ? 'Uploading to cloud server...'
                        : 'Uploaded & ready for verification',
                    style: AppTypography.bodySm.copyWith(
                      color: _isUploadingReceipt
                          ? AppColors.secondary
                          : const Color(0xFF16A34A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_isUploadingReceipt)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: _removeReceipt,
              ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            color: Color(0xFF94A3B8),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload bank transfer receipt / screenshot',
            style: AppTypography.bodySm.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickReceipt(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('Take Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _pickReceipt(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 6),
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
