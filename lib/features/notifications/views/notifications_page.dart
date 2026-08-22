import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _selectedTab = 0;
  final _tabs = ['All', 'Shipments', 'Payments', 'System'];

  final List<_NotificationItem> _allNotifications = [
    _NotificationItem(
      icon: Icons.local_shipping_outlined,
      iconColor: AppColors.secondary,
      title: 'Shipment Arrived',
      message: 'Your package HMZ-8892 has arrived at the Guangzhou warehouse.',
      time: '2 min ago',
      isRead: false,
      category: 'Shipments',
    ),
    _NotificationItem(
      icon: Icons.account_balance_wallet_outlined,
      iconColor: AppColors.success,
      title: 'Wallet Funded',
      message: 'NGN 250,000.00 has been credited to your wallet successfully.',
      time: '1h ago',
      isRead: false,
      category: 'Payments',
    ),
    _NotificationItem(
      icon: Icons.inventory_2_outlined,
      iconColor: AppColors.tertiary,
      title: 'Consolidation Ready',
      message:
          'Your 3 packages are ready for consolidation. Review and confirm.',
      time: '3h ago',
      isRead: true,
      category: 'Shipments',
    ),
    _NotificationItem(
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.error,
      title: 'Customs Clearance Required',
      message:
          'Additional documents needed for shipment REQ-8412. Please upload.',
      time: '5h ago',
      isRead: true,
      category: 'Shipments',
    ),
    _NotificationItem(
      icon: Icons.currency_exchange,
      iconColor: AppColors.secondary,
      title: 'Exchange Completed',
      message: 'Your exchange of NGN 500,000 → ¥2,450 has been completed.',
      time: '1d ago',
      isRead: true,
      category: 'Payments',
    ),
    _NotificationItem(
      icon: Icons.system_update_outlined,
      iconColor: AppColors.primary,
      title: 'App Update Available',
      message:
          'Version 2.5.0 is now available with new features and improvements.',
      time: '2d ago',
      isRead: true,
      category: 'System',
    ),
    _NotificationItem(
      icon: Icons.verified_outlined,
      iconColor: AppColors.success,
      title: 'KYC Approved',
      message: 'Your identity verification has been approved. Full access unlocked.',
      time: '3d ago',
      isRead: true,
      category: 'System',
    ),
  ];

  List<_NotificationItem> get _filteredNotifications {
    if (_selectedTab == 0) return _allNotifications;
    final category = _tabs[_selectedTab];
    return _allNotifications.where((n) => n.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _allNotifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.onBackground,
          ),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.headlineMd.copyWith(fontSize: 18),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (final n in _allNotifications) {
                    n.isRead = true;
                  }
                });
              },
              child: Text(
                'Mark all read',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Tabs ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTab == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        _tabs[index],
                        style: AppTypography.bodySm.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // ── Notification List ───────────────────────────────────
          Expanded(
            child: _filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No notifications',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredNotifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _filteredNotifications[index];
                      return _NotificationCard(
                        item: item,
                        onTap: () {
                          setState(() => item.isRead = true);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Notification Data Model ────────────────────────────────────────────────
class _NotificationItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;
  bool isRead;
  final String category;

  _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.category,
  });
}

// ── Notification Card ──────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.surface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: item.isRead
              ? null
              : Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                color: item.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight:
                                item.isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.time,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
