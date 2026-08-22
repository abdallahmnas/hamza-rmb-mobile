import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class WarehouseAddressesPage extends StatelessWidget {
  const WarehouseAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leadingWidth: 48,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  'H',
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Hamza RMB',
          style: AppTypography.headlineMd.copyWith(fontSize: 16),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.onBackground,
              size: 24,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {},
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.person_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
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
                    'Use these addresses as your shipping destination when buying from overseas suppliers.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Guangzhou Hub ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WarehouseCard(
                hubName: 'Guangzhou Hub',
                freightType: 'AIR FREIGHT',
                iconColor: AppColors.tertiary,
                fields: const [
                  _AddressField(
                    label: '收货人名字',
                    value: 'Hamza Logistics (HZ-20241001)',
                  ),
                  _AddressField(
                    label: '收货人号码',
                    value: '+86 138 0013 8000',
                  ),
                  _AddressField(
                    label: '收货人地址',
                    value:
                        'No. 128, Airport Expressway, Baiyun District, Guangzhou City, Guangdong Province',
                  ),
                  _AddressField(
                    label: '邮政编码',
                    value: '510400',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── London Hub ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WarehouseCard(
                hubName: 'London Hub',
                freightType: 'AIR FREIGHT',
                iconColor: AppColors.tertiary,
                fields: const [
                  _AddressField(
                    label: 'Recipient Name',
                    value: 'Hamza Logistics (HZ-20241001)',
                  ),
                  _AddressField(
                    label: 'Full Address',
                    value:
                        'Unit 4, Heathrow Logistics Park, Bedfont Road, Hounslow, London',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Houston Hub ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WarehouseCard(
                hubName: 'Houston Hub',
                freightType: 'AIR FREIGHT',
                iconColor: AppColors.tertiary,
                fields: const [
                  _AddressField(
                    label: 'Recipient Name',
                    value: 'Hamza Logistics (HZ-20241001)',
                  ),
                  _AddressField(
                    label: 'Full Address',
                    value:
                        '4500 South Wayside Drive, Suite 100, Houston, TX 77087',
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
