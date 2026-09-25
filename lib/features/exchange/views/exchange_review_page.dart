import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_bar_logo_title.dart';
import '../../../core/services/media_upload_service.dart';
import '../data/models/exchange_request_model.dart';
import '../data/models/saved_account_model.dart';
import '../models/exchange_review_data.dart';
import '../presentation/providers/exchange_provider.dart';
import 'saved_accounts_page.dart';

class ExchangeReviewPage extends ConsumerStatefulWidget {
  final ExchangeReviewData reviewData;

  const ExchangeReviewPage({super.key, required this.reviewData});

  @override
  ConsumerState<ExchangeReviewPage> createState() => _ExchangeReviewPageState();
}

class _ExchangeReviewPageState extends ConsumerState<ExchangeReviewPage> {
  // ── Mode: true = use saved account, false = enter new account ─────────────
  bool _useSavedAccount = true;
  SavedAccountModel? _selectedAccount;

  late String _selectedPlatform;
  late TextEditingController _beneficiaryController;
  late TextEditingController _accountIdController;
  late TextEditingController _labelController;
  bool _saveAccountForFuture = false;

  // Receiving Barcode / QR
  File? _barcodeImage;
  String? _uploadedBarcodeUrl;
  bool _isUploadingBarcode = false;

  // Naira Payment Receipt
  File? _nairaReceiptImage;
  String? _uploadedNairaReceiptUrl;
  bool _isUploadingNairaReceipt = false;

  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.reviewData.savedAccount;
    _selectedPlatform = widget.reviewData.selectedPlatform.isNotEmpty
        ? widget.reviewData.selectedPlatform
        : 'wechat_pay';

    _beneficiaryController = TextEditingController(
      text: widget.reviewData.beneficiaryName,
    );
    _accountIdController = TextEditingController(
      text: widget.reviewData.accountId,
    );
    _labelController = TextEditingController();

    _uploadedBarcodeUrl = widget.reviewData.imageUrl;
    _nairaReceiptImage = widget.reviewData.receiptImage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exchangeProvider.notifier).fetchSavedAccounts(isUserInitiated: true);
    });
  }

  @override
  void dispose() {
    _beneficiaryController.dispose();
    _accountIdController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _applyAccount(SavedAccountModel account) {
    setState(() {
      _selectedAccount = account;
      _selectedPlatform = account.platform;
      _beneficiaryController.text = account.accountName;
      _accountIdController.text = account.accountNumber;
      _uploadedBarcodeUrl = account.barcodeUrl;
      _barcodeImage = null;
      _useSavedAccount = true;
    });
  }

  Future<void> _pickBarcodeImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked != null) {
        final file = File(picked.path);
        setState(() {
          _barcodeImage = file;
          _isUploadingBarcode = true;
          _uploadedBarcodeUrl = null;
        });

        try {
          final url =
              await ref.read(mediaUploadServiceProvider).uploadImage(file);
          if (mounted) {
            setState(() {
              _uploadedBarcodeUrl = url;
              _isUploadingBarcode = false;
            });
          }
        } catch (_) {
          if (mounted) {
            setState(() => _isUploadingBarcode = false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingBarcode = false);
      }
    }
  }

  Future<void> _pickNairaReceiptImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked != null) {
        final file = File(picked.path);
        setState(() {
          _nairaReceiptImage = file;
          _isUploadingNairaReceipt = true;
          _uploadedNairaReceiptUrl = null;
        });

        try {
          final url =
              await ref.read(mediaUploadServiceProvider).uploadImage(file);
          if (mounted) {
            setState(() {
              _uploadedNairaReceiptUrl = url;
              _isUploadingNairaReceipt = false;
            });
          }
        } catch (_) {
          if (mounted) {
            setState(() => _isUploadingNairaReceipt = false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingNairaReceipt = false);
      }
    }
  }

  void _showImageSourcePicker({required bool isBarcode}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBarcode
                    ? 'Upload Receiving Barcode / QR Code'
                    : 'Upload Naira Transfer Receipt',
                style: AppTypography.headlineMd.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (isBarcode) {
                    _pickBarcodeImage(ImageSource.gallery);
                  } else {
                    _pickNairaReceiptImage(ImageSource.gallery);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.primary),
                title: const Text('Take Photo with Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (isBarcode) {
                    _pickBarcodeImage(ImageSource.camera);
                  } else {
                    _pickNairaReceiptImage(ImageSource.camera);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitExchange() async {
    final accountId = _useSavedAccount && _selectedAccount != null
        ? _selectedAccount!.accountNumber
        : _accountIdController.text.trim();

    final accountName = _useSavedAccount && _selectedAccount != null
        ? _selectedAccount!.accountName
        : _beneficiaryController.text.trim();

    final platform = _useSavedAccount && _selectedAccount != null
        ? _selectedAccount!.platform
        : _selectedPlatform;

    if (accountName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or select a beneficiary account name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (accountId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or select beneficiary account ID/number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Barcode URL
    String barcodeUrl = _useSavedAccount && _selectedAccount != null
        ? _selectedAccount!.barcodeUrl
        : (_uploadedBarcodeUrl ?? '');

    if (barcodeUrl.isEmpty && _barcodeImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide or upload receiving barcode/QR code'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Naira Receipt
    if (_uploadedNairaReceiptUrl == null && _nairaReceiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload Naira payment transfer receipt'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Upload barcode if needed
      if (barcodeUrl.isEmpty && _barcodeImage != null) {
        barcodeUrl = await ref
            .read(mediaUploadServiceProvider)
            .uploadImage(_barcodeImage!);
        _uploadedBarcodeUrl = barcodeUrl;
      }

      // Upload Naira receipt if needed
      String nairaReceiptUrl = _uploadedNairaReceiptUrl ?? '';
      if (nairaReceiptUrl.isEmpty && _nairaReceiptImage != null) {
        nairaReceiptUrl = await ref
            .read(mediaUploadServiceProvider)
            .uploadImage(_nairaReceiptImage!);
        _uploadedNairaReceiptUrl = nairaReceiptUrl;
      }

      final sendCleaned =
          widget.reviewData.sendAmount.replaceAll(',', '').trim();
      final amountNaira = double.tryParse(sendCleaned) ?? 0.0;

      final result = await ref
          .read(exchangeProvider.notifier)
          .createExchangeRequest(
            amountNaira: amountNaira,
            rmbDestType: platform,
            rmbDestAccount: accountId,
            rmbDestName: accountName,
            rmbDestQrCode: barcodeUrl,
            receivingBarcodeUrl: barcodeUrl,
            nairaReceiptUrl: nairaReceiptUrl,
            saveAccount: !_useSavedAccount && _saveAccountForFuture,
          );

      if (result == null) {
        final err = ref.read(exchangeProvider).error;
        throw Exception(err ?? 'Failed to submit exchange request');
      }

      // If user checked save account and entered new, save it explicitly as well
      if (!_useSavedAccount && _saveAccountForFuture) {
        try {
          await ref.read(exchangeProvider.notifier).createSavedAccount(
                platform: platform,
                accountNumber: accountId,
                accountName: accountName,
                label: _labelController.text.trim().isNotEmpty
                    ? _labelController.text.trim()
                    : accountName,
                barcodeUrl: barcodeUrl,
                isDefault: false,
              );
        } catch (_) {}
      }

      if (mounted) {
        _showSuccessDialog(result);
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

  void _showSuccessDialog(ExchangeRequestModel request) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF16A34A),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Exchange Request Placed!',
                style: AppTypography.headlineMd.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your payment receipt has been submitted for verification. Escrow will credit your RMB receiving account shortly.',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _ReceiptRow(
                      label: 'Request ID',
                      value: request.id.length > 12
                          ? '${request.id.substring(0, 12)}...'
                          : request.id,
                    ),
                    const Divider(height: 14),
                    _ReceiptRow(
                      label: 'Amount Paid',
                      value: '₦${NumberFormat('#,##0.00').format(request.amountNaira)}',
                    ),
                    const Divider(height: 14),
                    _ReceiptRow(
                      label: 'You Will Receive',
                      value: '¥${request.amountRmb.toStringAsFixed(2)} RMB',
                      isBold: true,
                    ),
                    const Divider(height: 14),
                    _ReceiptRow(
                      label: 'Receiving Account',
                      value: '${request.rmbDestName} (${request.rmbDestAccount})',
                    ),
                    const Divider(height: 14),
                    _ReceiptRow(
                      label: 'Status',
                      value: request.status.replaceAll('_', ' ').toUpperCase(),
                      valueColor: const Color(0xFF16A34A),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/exchange');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back to Exchange'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exchangeState = ref.watch(exchangeProvider);
    final savedAccounts = exchangeState.savedAccounts;

    final allAccounts = [
      ?_selectedAccount,
      ...savedAccounts,
    ];

    final uniqueAccounts = <String, SavedAccountModel>{
      for (final acc in allAccounts) acc.uniqueKey: acc,
    }.values.toList();

    // Auto-select first default account if none selected yet
    if (_selectedAccount == null && uniqueAccounts.isNotEmpty) {
      final defaultAcc = uniqueAccounts.firstWhere(
        (a) => a.isDefault,
        orElse: () => uniqueAccounts.first,
      );
      _selectedAccount = defaultAcc;
      _selectedPlatform = defaultAcc.platform;
      _beneficiaryController.text = defaultAcc.accountName;
      _accountIdController.text = defaultAcc.accountNumber;
      _uploadedBarcodeUrl = defaultAcc.barcodeUrl;
    }

    final sendCleaned = widget.reviewData.sendAmount.replaceAll(',', '').trim();
    final amountNaira = double.tryParse(sendCleaned) ?? 0.0;
    final totalNaira = amountNaira + 5000.0; // 5000 platform fee from sample

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.onBackground),
          onPressed: () => context.pop(),
        ),
        title: AppBarLogoTitle(
          title: 'Exchange Review & Payment',
          style: AppTypography.headlineMd.copyWith(fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/exchange-saved-accounts'),
            icon: const Icon(Icons.bookmarks_outlined, size: 18),
            label: const Text('Saved Accounts'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Conversion Summary Card ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CONVERSION DETAILS',
                          style: AppTypography.labelCaps.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1.1,
                            fontSize: 11,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.reviewData.exchangeRate,
                            style: AppTypography.labelCaps.copyWith(
                              color: const Color(0xFF10B981),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You Pay (NGN)',
                                style: AppTypography.bodySm.copyWith(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₦${widget.reviewData.sendAmount}',
                                style: AppTypography.headlineMd.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white38,
                          size: 22,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'You Receive (RMB)',
                                style: AppTypography.bodySm.copyWith(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '¥${widget.reviewData.receiveAmount}',
                                style: AppTypography.headlineMd.copyWith(
                                  color: const Color(0xFF38BDF8),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── RMB Receiving Destination ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RMB Receiving Account',
                        style: AppTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (savedAccounts.isNotEmpty)
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Saved Account'),
                              selected: _useSavedAccount,
                              selectedColor: AppColors.primary.withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: _useSavedAccount
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                              onSelected: (val) {
                                if (val) setState(() => _useSavedAccount = true);
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('+ New'),
                              selected: !_useSavedAccount,
                              selectedColor: AppColors.primary.withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: !_useSavedAccount
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                              onSelected: (val) {
                                if (val) setState(() => _useSavedAccount = false);
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Case 1: Use Saved Account
                  if (_useSavedAccount && savedAccounts.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Select from Saved Accounts',
                                style: AppTypography.bodySm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () async {
                                  final selected =
                                      await Navigator.push<SavedAccountModel>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SavedAccountsPage(
                                          selectMode: true),
                                    ),
                                  );
                                  if (selected != null) {
                                    _applyAccount(selected);
                                  }
                                },
                                child: Text(
                                  'Manage All',
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Dropdown selector
                          DropdownButtonFormField<String>(
                            key: ValueKey<String>(
                              _selectedAccount?.uniqueKey ?? 'none',
                            ),
                            initialValue: _selectedAccount?.uniqueKey ??
                                (uniqueAccounts.isNotEmpty
                                    ? uniqueAccounts.first.uniqueKey
                                    : null),
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0)),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                            ),
                            items: uniqueAccounts.map((acc) {
                              return DropdownMenuItem<String>(
                                value: acc.uniqueKey,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: acc.platform.toLowerCase() ==
                                                'wechat_pay'
                                            ? const Color(0xFF07C160)
                                                .withValues(alpha: 0.15)
                                            : const Color(0xFF1677FF)
                                                .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        acc.platform.toLowerCase() ==
                                                'wechat_pay'
                                            ? 'WeChat'
                                            : 'Alipay',
                                        style: TextStyle(
                                          color: acc.platform.toLowerCase() ==
                                                  'wechat_pay'
                                              ? const Color(0xFF07C160)
                                              : const Color(0xFF1677FF),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${acc.label.isNotEmpty ? acc.label : acc.accountName} (${acc.accountNumber})',
                                        style: AppTypography.bodySm.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (selectedKey) {
                              if (selectedKey != null) {
                                final match = uniqueAccounts.firstWhere(
                                  (a) => a.uniqueKey == selectedKey,
                                );
                                _applyAccount(match);
                              }
                            },
                          ),

                          if (_selectedAccount != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  if (_selectedAccount!.barcodeUrl.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _selectedAccount!.barcodeUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.qr_code, size: 40),
                                      ),
                                    )
                                  else
                                    const Icon(Icons.qr_code, size: 40),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedAccount!.accountName,
                                          style: AppTypography.bodyMd.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${_selectedAccount!.accountNumber}',
                                          style: AppTypography.bodySm.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.check_circle,
                                      color: Color(0xFF10B981)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    // Case 2: Enter New RMB Account
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Platform selector
                          Text(
                            'Destination Platform',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _PlatformChoice(
                                  label: 'WeChat Pay',
                                  icon: Icons.chat_bubble_outline,
                                  isSelected: _selectedPlatform == 'wechat_pay',
                                  onTap: () => setState(
                                      () => _selectedPlatform = 'wechat_pay'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _PlatformChoice(
                                  label: 'Alipay',
                                  icon: Icons.payment_outlined,
                                  isSelected: _selectedPlatform == 'alipay',
                                  onTap: () => setState(
                                      () => _selectedPlatform = 'alipay'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Beneficiary Name
                          Text(
                            'Beneficiary Account Name',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _beneficiaryController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Hamza RMB',
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Account ID
                          Text(
                            _selectedPlatform == 'wechat_pay'
                                ? 'WeChat ID / Phone Number'
                                : 'Alipay ID / Phone Number',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _accountIdController,
                            decoration: InputDecoration(
                              hintText: 'e.g. 9011223344',
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Receiving Barcode / QR Upload
                          Text(
                            'Receiving Barcode / QR Code',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_barcodeImage != null ||
                              (_uploadedBarcodeUrl != null &&
                                  _uploadedBarcodeUrl!.isNotEmpty))
                            Stack(
                              children: [
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: _barcodeImage != null
                                        ? Image.file(_barcodeImage!,
                                            fit: BoxFit.contain)
                                        : Image.network(_uploadedBarcodeUrl!,
                                            fit: BoxFit.contain),
                                  ),
                                ),
                                if (_isUploadingBarcode)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: AppColors.error),
                                    onPressed: () {
                                      setState(() {
                                        _barcodeImage = null;
                                        _uploadedBarcodeUrl = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _showImageSourcePicker(isBarcode: true),
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('Upload QR Code / Barcode'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          const SizedBox(height: 14),

                          // Save account checkbox
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _saveAccountForFuture,
                            activeColor: AppColors.primary,
                            title: Text(
                              'Save this account for future exchanges',
                              style: AppTypography.bodySm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onChanged: (val) => setState(
                                () => _saveAccountForFuture = val ?? false),
                          ),
                          if (_saveAccountForFuture) ...[
                            const SizedBox(height: 6),
                            TextField(
                              controller: _labelController,
                              decoration: InputDecoration(
                                hintText: 'Label for saved account (e.g. hamzarmb)',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Escrow Bank Transfer Details ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Escrow Bank Account',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Transfer the Naira equivalent to our secure escrow account below and attach the payment receipt.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const _EscrowDetailRow(
                          label: 'Bank Name',
                          value: 'GTBank',
                        ),
                        const Divider(height: 16),
                        const _EscrowDetailRow(
                          label: 'Account Number',
                          value: '0123456789',
                          canCopy: true,
                        ),
                        const Divider(height: 16),
                        const _EscrowDetailRow(
                          label: 'Account Name',
                          value: 'Hamza RMB Trading Escrow Ltd',
                        ),
                        const Divider(height: 16),
                        _EscrowDetailRow(
                          label: 'Total Naira to Transfer',
                          value: '₦${NumberFormat('#,##0.00').format(totalNaira)}',
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Proof of Payment (Naira Receipt) ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Proof of Payment (Naira Receipt)',
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upload your bank payment confirmation or transfer screenshot.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_nairaReceiptImage != null ||
                      (_uploadedNairaReceiptUrl != null &&
                          _uploadedNairaReceiptUrl!.isNotEmpty))
                    Stack(
                      children: [
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _nairaReceiptImage != null
                                ? Image.file(_nairaReceiptImage!,
                                    fit: BoxFit.cover)
                                : Image.network(_uploadedNairaReceiptUrl!,
                                    fit: BoxFit.cover),
                          ),
                        ),
                        if (_isUploadingNairaReceipt)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon:
                                const Icon(Icons.cancel, color: AppColors.error),
                            onPressed: () {
                              setState(() {
                                _nairaReceiptImage = null;
                                _uploadedNairaReceiptUrl = null;
                              });
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    InkWell(
                      onTap: () => _showImageSourcePicker(isBarcode: false),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2E8F0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                color: Color(0xFF64748B),
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap to upload transfer receipt',
                              style: AppTypography.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '(JPG, PNG, PDF receipts supported)',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Submit Button ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitExchange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Submit Exchange Request',
                              style: AppTypography.bodyLg.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlatformChoice({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EscrowDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool canCopy;
  final bool isHighlight;

  const _EscrowDetailRow({
    required this.label,
    required this.value,
    this.canCopy = false,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: AppTypography.bodySm.copyWith(
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                color: isHighlight ? AppColors.primary : AppColors.onBackground,
                fontSize: isHighlight ? 14 : 12,
              ),
            ),
            if (canCopy) ...[
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Icon(
                  Icons.copy,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySm.copyWith(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.onBackground,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
