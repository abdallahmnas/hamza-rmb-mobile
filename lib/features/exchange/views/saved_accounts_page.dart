import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/media_upload_service.dart';
import '../data/models/saved_account_model.dart';
import '../presentation/providers/exchange_provider.dart';

class SavedAccountsPage extends ConsumerStatefulWidget {
  final bool selectMode;

  const SavedAccountsPage({super.key, this.selectMode = false});

  @override
  ConsumerState<SavedAccountsPage> createState() => _SavedAccountsPageState();
}

class _SavedAccountsPageState extends ConsumerState<SavedAccountsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(exchangeProvider.notifier).fetchSavedAccounts(isUserInitiated: true);
    });
  }

  void _openAddAccountSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddAccountBottomSheet(),
    );
  }

  void _showQrDialog(SavedAccountModel account) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    account.label.isNotEmpty ? account.label : 'RMB Account QR',
                    style: AppTypography.headlineMd.copyWith(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: account.barcodeUrl.isNotEmpty
                    ? Image.network(
                        account.barcodeUrl,
                        height: 240,
                        width: 240,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox(
                          height: 180,
                          child: Center(
                            child: Icon(Icons.broken_image,
                                size: 48, color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 180,
                        child: Center(
                          child: Text('No QR Code available'),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                '${account.accountName} (${account.accountNumber})',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
                textAlign: TextAlign.center,
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
    final accounts = exchangeState.savedAccounts;
    final isLoading = exchangeState.isLoadingAccounts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.selectMode ? 'Select Saved Account' : 'Saved RMB Accounts',
          style: AppTypography.headlineMd.copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Add Account',
            onPressed: _openAddAccountSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(exchangeProvider.notifier)
            .fetchSavedAccounts(isUserInitiated: true),
        child: isLoading && accounts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : accounts.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Saved RMB Accounts',
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineMd.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Save your WeChat Pay or Alipay account details and receiving QR barcodes for seamless, 1-tap RMB exchanges.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _openAddAccountSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Add RMB Account'),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final acc = accounts[index];
                      final isSelected =
                          exchangeState.selectedSavedAccount?.id == acc.id;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        color: AppColors.surface,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            ref
                                .read(exchangeProvider.notifier)
                                .selectSavedAccount(acc);
                            if (widget.selectMode) {
                              context.pop(acc);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: acc.platform.toLowerCase() ==
                                                'wechat_pay'
                                            ? const Color(0xFF07C160)
                                                .withValues(alpha: 0.12)
                                            : const Color(0xFF1677FF)
                                                .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        acc.platform.toLowerCase() ==
                                                'wechat_pay'
                                            ? 'WeChat Pay'
                                            : 'Alipay',
                                        style:
                                            AppTypography.labelCaps.copyWith(
                                          color: acc.platform.toLowerCase() ==
                                                  'wechat_pay'
                                              ? const Color(0xFF07C160)
                                              : const Color(0xFF1677FF),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (acc.isDefault)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'DEFAULT',
                                          style: AppTypography.labelCaps
                                              .copyWith(
                                            color: AppColors.primary,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                    if (acc.barcodeUrl.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.qr_code_2,
                                          color: AppColors.primary,
                                          size: 26,
                                        ),
                                        tooltip: 'View QR Barcode',
                                        onPressed: () => _showQrDialog(acc),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  acc.label.isNotEmpty
                                      ? acc.label
                                      : acc.accountName,
                                  style: AppTypography.bodyLg.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Account Name: ',
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      acc.accountName,
                                      style: AppTypography.bodySm.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      'Account No / ID: ',
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      acc.accountNumber,
                                      style: AppTypography.bodySm.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: acc.accountNumber));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Account number copied!'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.copy,
                                        size: 14,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAccountSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
    );
  }
}

class _AddAccountBottomSheet extends ConsumerStatefulWidget {
  const _AddAccountBottomSheet();

  @override
  ConsumerState<_AddAccountBottomSheet> createState() =>
      _AddAccountBottomSheetState();
}

class _AddAccountBottomSheetState
    extends ConsumerState<_AddAccountBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String _platform = 'wechat_pay';
  final _accountNumberCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();
  bool _isDefault = false;
  File? _barcodeImage;
  String? _uploadedBarcodeUrl;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _accountNumberCtrl.dispose();
    _accountNameCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBarcode(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked != null) {
        final file = File(picked.path);
        setState(() {
          _barcodeImage = file;
          _isUploadingImage = true;
          _uploadedBarcodeUrl = null;
        });

        try {
          final url =
              await ref.read(mediaUploadServiceProvider).uploadImage(file);
          if (mounted) {
            setState(() {
              _uploadedBarcodeUrl = url;
              _isUploadingImage = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isUploadingImage = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Note: $e. Submission will upload on save.'),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_uploadedBarcodeUrl == null && _barcodeImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload receiving barcode or QR code image'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String barcodeUrl = _uploadedBarcodeUrl ?? '';
      if (barcodeUrl.isEmpty && _barcodeImage != null) {
        barcodeUrl = await ref
            .read(mediaUploadServiceProvider)
            .uploadImage(_barcodeImage!);
      }

      final created =
          await ref.read(exchangeProvider.notifier).createSavedAccount(
                platform: _platform,
                accountNumber: _accountNumberCtrl.text.trim(),
                accountName: _accountNameCtrl.text.trim(),
                label: _labelCtrl.text.trim().isNotEmpty
                    ? _labelCtrl.text.trim()
                    : _accountNameCtrl.text.trim(),
                barcodeUrl: barcodeUrl,
                isDefault: _isDefault,
              );

      if (created != null && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('RMB Account saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        final err = ref.read(exchangeProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Failed to save account'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Saved RMB Account',
                    style: AppTypography.headlineMd.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Platform Selector
              Text(
                'Platform',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _PlatformOption(
                      label: 'WeChat Pay',
                      icon: Icons.chat_bubble_outline,
                      isSelected: _platform == 'wechat_pay',
                      onTap: () => setState(() => _platform = 'wechat_pay'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PlatformOption(
                      label: 'Alipay',
                      icon: Icons.payment_outlined,
                      isSelected: _platform == 'alipay',
                      onTap: () => setState(() => _platform = 'alipay'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Label
              Text(
                'Account Label (e.g. hamzarmb)',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _labelCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. hamzarmb / Main Supplier',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter a label'
                    : null,
              ),
              const SizedBox(height: 14),

              // Beneficiary / Account Name
              Text(
                'Account Name (Beneficiary Name)',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _accountNameCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. Hamza RMB',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter account name'
                    : null,
              ),
              const SizedBox(height: 14),

              // Account Number / Phone ID
              Text(
                'Account Number / Phone / ID',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _accountNumberCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. 9011223344',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter account number'
                    : null,
              ),
              const SizedBox(height: 16),

              // Barcode / QR Code
              Text(
                'Receiving Barcode / QR Code',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              if (_barcodeImage != null)
                Stack(
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_barcodeImage!, fit: BoxFit.contain),
                      ),
                    ),
                    if (_isUploadingImage)
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
                      top: 6,
                      right: 6,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: AppColors.error),
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickBarcode(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickBarcode(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Camera'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Default Switch
              SwitchListTile(
                value: _isDefault,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text(
                  'Set as default receiving account',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                      : Text(
                          'Save RMB Account',
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
      ),
    );
  }
}

class _PlatformOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlatformOption({
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
              ? AppColors.primary.withValues(alpha: 0.08)
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
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
