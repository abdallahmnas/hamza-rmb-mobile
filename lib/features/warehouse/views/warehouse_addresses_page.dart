import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/auth/auth_service.dart';
import '../../home/presentation/providers/system_metadata_provider.dart';

class WarehouseAddressesPage extends ConsumerWidget {
  const WarehouseAddressesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataState = ref.watch(systemMetadataProvider);
    final authState = ref.watch(authServiceProvider);
    final customerId = authState.user?.customerId ?? 'HZ-2026-MEMBER';
    final userFullName = authState.user?.fullName.isNotEmpty == true
        ? authState.user!.fullName
        : 'Hamza RMB Client';

    final chinaAddress = metadataState.settings.chinaAirCargoAddressCn;
    final nigeriaAddress = metadataState.settings.nigeriaOfficeAddress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Warehouse Receiving Addresses',
          style: AppTypography.headlineMd.copyWith(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Warehouse Addresses',
                    style: AppTypography.headlineMd.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Use these addresses as your shipping destination when buying from 1688, Taobao, or overseas suppliers.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── China Hub ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WarehouseCard(
                hubName: 'China Receiving Hub (Air / Sea)',
                freightType: 'CHINA CARGO INTAKE',
                iconColor: AppColors.tertiary,
                fields: [
                  _AddressField(
                    label: '收货人 (Recipient Name)',
                    value: '$userFullName ($customerId)',
                  ),
                  const _AddressField(
                    label: '收货人电话 (Phone Number)',
                    value: '+86 138 0013 8000',
                  ),
                  _AddressField(
                    label: '收货人地址 (Chinese Address)',
                    value: chinaAddress,
                  ),
                  const _AddressField(
                    label: '所在地区 (City/Province)',
                    value: 'Yiwu / Guangzhou, Guangdong',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Nigeria Head Office Hub ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WarehouseCard(
                hubName: 'Nigeria Central Hub & Collection',
                freightType: 'DESTINATION WAREHOUSE',
                iconColor: AppColors.primary,
                fields: [
                  _AddressField(
                    label: 'Company Name',
                    value: metadataState.settings.companyName,
                  ),
                  _AddressField(
                    label: 'Full Address',
                    value: nigeriaAddress,
                  ),
                  const _AddressField(
                    label: 'Lagos Airport Pickup Point',
                    value: 'Cargo Village, Muritala Muhammed Int. Airport, Ikeja, Lagos',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Address Field Model ────────────────────────────────────────────────────
class _AddressField {
  final String label;
  final String value;

  const _AddressField({required this.label, required this.value});
}

// ── Warehouse Card ─────────────────────────────────────────────────────────
class _WarehouseCard extends StatelessWidget {
  final String hubName;
  final String freightType;
  final Color iconColor;
  final List<_AddressField> fields;

  const _WarehouseCard({
    required this.hubName,
    required this.freightType,
    required this.iconColor,
    required this.fields,
  });

  void _copyAll(BuildContext context) {
    final buffer = StringBuffer();
    for (final f in fields) {
      buffer.writeln('${f.label}: ${f.value}');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$hubName address copied!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hub header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.home_outlined,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hubName,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      freightType,
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.secondary,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _copyAll(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // Address fields
          ...fields.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${f.label}: ',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: f.value,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onBackground,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
