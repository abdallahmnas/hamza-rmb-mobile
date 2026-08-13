import 'package:flutter/material.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class PendingItemsPage extends StatefulWidget {
  const PendingItemsPage({super.key});

  @override
  State<PendingItemsPage> createState() => _PendingItemsPageState();
}

class _PendingItemsPageState extends State<PendingItemsPage> {
  final List<int> _selectedIndexes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consolidate Items', style: AppTypography.headlineMd),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select items in the warehouse to pack together.',
                      style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: 5,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndexes.contains(index);
                  
                  return AppCard(
                    backgroundColor: isSelected ? AppColors.surfaceVariant : AppColors.surface,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIndexes.remove(index);
                        } else {
                          _selectedIndexes.add(index);
                        }
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedIndexes.add(index);
                              } else {
                                _selectedIndexes.remove(index);
                              }
                            });
                          },
                          activeColor: AppColors.secondary,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'PKG-100${index}',
                                    style: AppTypography.labelCaps.copyWith(color: AppColors.secondary),
                                  ),
                                  const AppStatusBadge(
                                    text: 'AT HUB',
                                    status: AppBadgeStatus.warning,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Supplier Package ${index + 1}',
                                style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Weight: 2.5kg • Vol: 0.1CBM',
                                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: AppButton.primary(
            text: 'Pack ${_selectedIndexes.length} Items',
            onPressed: _selectedIndexes.isNotEmpty ? () {} : null,
          ),
        ),
      ),
    );
  }
}
