import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  int _selectedTab = 0;
  final _tabs = ['Open (3)', 'Pending', 'Resolved'];

  final List<_TicketItem> _allTickets = [
    const _TicketItem(
      id: 'TIC-9921',
      category: 'Shipping',
      categoryColor: Color(0xFFF59E0B),
      priority: 'Open',
      priorityColor: Color(0xFFF59E0B),
      priorityIcon: Icons.flag,
      title: 'Delayed Shipment REQ-8412',
      description:
          'The shipment was supposed to arrive last Tuesday but tracking hasn\'t updated since i...',
      updatedAgo: '2h ago',
    ),
    const _TicketItem(
      id: 'TIC-9844',
      category: 'Payment',
      categoryColor: Color(0xFFEF4444),
      priority: 'Urgent',
      priorityColor: Color(0xFFEF4444),
      priorityIcon: Icons.error_outline,
      title: 'Wallet Top-up Failed',
      description:
          'Tried to fund my wallet via wire transfer yesterday but the balance is still showing...',
      updatedAgo: '5h ago',
    ),
    const _TicketItem(
      id: 'TIC-9750',
      category: 'Account',
      categoryColor: Color(0xFF0D9488),
      priority: 'Open',
      priorityColor: Color(0xFFF59E0B),
      priorityIcon: Icons.flag,
      title: 'Update Company Address',
      description:
          'We recently moved warehouses and need to update our primary delivery address for all...',
      updatedAgo: '1d ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        title: Row(
          children: [
            Container(
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
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'My Tickets',
              style: AppTypography.headlineMd.copyWith(fontSize: 18),
            ),
          ],
        ),
        actions: [
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
      body: Column(
        children: [
          // ── Search Bar ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.search,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search tickets...',
                        hintStyle: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppTypography.bodySm,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Tabs ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTab == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTab = index),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      children: [
                        Text(
                          _tabs[index],
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.onBackground
                                : AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 2,
                          width: 40,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          const SizedBox(height: 12),

          // ── Ticket List ─────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _allTickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ticket = _allTickets[index];
                return _TicketCard(
                  item: ticket,
                  onTap: () => context.push('/ticket-details'),
                );
              },
            ),
          ),
        ],
      ),

      // ── FAB: New Ticket ──────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/new-ticket'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          'New Ticket',
          style: AppTypography.bodySm.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Ticket Data Model ──────────────────────────────────────────────────────
class _TicketItem {
  final String id;
  final String category;
  final Color categoryColor;
  final String priority;
  final Color priorityColor;
  final IconData priorityIcon;
  final String title;
  final String description;
  final String updatedAgo;

  const _TicketItem({
    required this.id,
    required this.category,
    required this.categoryColor,
    required this.priority,
    required this.priorityColor,
    required this.priorityIcon,
    required this.title,
    required this.description,
    required this.updatedAgo,
  });
}

// ── Ticket Card ────────────────────────────────────────────────────────────
class _TicketCard extends StatelessWidget {
  final _TicketItem item;
  final VoidCallback onTap;

  const _TicketCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
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
            // Top row: ID + Category badge + Priority
            Row(
              children: [
                Text(
                  item.id,
                  style: AppTypography.labelCaps.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: item.categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.category,
                    style: AppTypography.bodySm.copyWith(
                      color: item.categoryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.priorityIcon,
                      size: 14,
                      color: item.priorityColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.priority,
                      style: AppTypography.bodySm.copyWith(
                        color: item.priorityColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              item.title,
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 6),

            // Description
            Text(
              item.description,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 14),

            // Bottom row: Updated time + View Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Updated ${item.updatedAgo}',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Details',
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppColors.onBackground,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
