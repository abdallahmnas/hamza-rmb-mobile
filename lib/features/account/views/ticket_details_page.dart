import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';
import '../data/models/ticket_model.dart';
import '../presentation/providers/support_provider.dart';

class TicketDetailsPage extends ConsumerStatefulWidget {
  final TicketModel? ticket;

  const TicketDetailsPage({super.key, this.ticket});

  @override
  ConsumerState<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends ConsumerState<TicketDetailsPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<_ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.ticket != null) {
      _initMessages(widget.ticket!);
    } else {
      _messages = [
        const _ChatMessage(
          text: 'Hello, our support and logistics desk is reviewing your enquiry.',
          isUser: false,
          time: 'Support',
          hasImage: false,
        ),
      ];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tId = widget.ticket?.id;
      if (tId != null && tId.isNotEmpty) {
        ref.read(supportProvider.notifier).fetchTicketDetails(tId).then((fetched) {
          if (mounted && fetched != null) {
            setState(() {
              _initMessages(fetched);
            });
          }
        });
      }
    });
  }

  void _initMessages(TicketModel t) {
    final list = <_ChatMessage>[];

    if (t.messages.isNotEmpty) {
      for (final m in t.messages) {
        final timeStr = DateFormat('hh:mm a').format(m.timestamp);
        list.add(_ChatMessage(
          text: m.message,
          isUser: m.sender.toLowerCase() != 'support' &&
              m.sender.toLowerCase() != 'admin',
          time: timeStr,
          hasImage: false,
        ));
      }
    } else if (t.description.isNotEmpty) {
      list.add(_ChatMessage(
        text: t.description,
        isUser: true,
        time: DateFormat('hh:mm a').format(t.createdAt),
        hasImage: false,
      ));
      list.add(const _ChatMessage(
        text: 'Thank you for reaching out. A support specialist has been assigned to your ticket.',
        isUser: false,
        time: 'Just now',
        hasImage: false,
      ));
    } else {
      list.add(const _ChatMessage(
        text: 'Hello, our clearance and logistics desk is reviewing your enquiry.',
        isUser: false,
        time: 'Support',
        hasImage: false,
      ));
    }

    _messages = list;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final tId = widget.ticket?.id ?? '';
    _messageController.clear();

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        time: DateFormat('hh:mm a').format(DateTime.now()),
        hasImage: false,
      ));
      _isSending = true;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      if (tId.isNotEmpty) {
        final success = await ref
            .read(supportProvider.notifier)
            .replyTicket(id: tId, message: text);
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send reply. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (_) {
      // Ignored for UX smoothness
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportState = ref.watch(supportProvider);
    final currentTicket = supportState.tickets.firstWhere(
      (t) => t.id == widget.ticket?.id,
      orElse: () =>
          widget.ticket ??
          TicketModel(
            id: 'TIC-SUPPORT',
            subject: 'Support Enquiry',
            description: '',
            createdAt: DateTime.now(),
          ),
    );

    final ticketId = currentTicket.id.isNotEmpty
        ? currentTicket.id.toUpperCase()
        : 'TIC-SUPPORT';
    final status = currentTicket.status.toUpperCase();
    final subject = currentTicket.subject.isNotEmpty
        ? currentTicket.subject
        : 'Support Enquiry';
    final category = currentTicket.category.toUpperCase();
    final priority = currentTicket.priority.toUpperCase();

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
              'Ticket Details',
              style: AppTypography.headlineMd.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Ticket Info Banner ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
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
                  // Ticket ID + Status
                  Row(
                    children: [
                      Text(
                        ticketId,
                        style: AppTypography.labelCaps.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: status == 'OPEN' || status == 'IN PROGRESS'
                              ? AppColors.success
                              : AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: AppTypography.bodySm.copyWith(
                          color: status == 'OPEN' || status == 'IN PROGRESS'
                              ? AppColors.success
                              : AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Linked item / Subject
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.headset_mic_outlined,
                          color: AppColors.secondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject,
                              style: AppTypography.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Priority: $priority',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
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

          const SizedBox(height: 8),

          // ── Chat Messages ──────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(message: msg);
              },
            ),
          ),

          // ── Message Input ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Attachment picker coming soon.'),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.attach_file,
                      color: AppColors.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        style: AppTypography.bodyMd,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat Message Model ─────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  final bool hasImage;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    required this.hasImage,
  });
}

// ── Chat Bubble ────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.support_agent,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Image attachment (if any)
                      if (message.hasImage) ...[
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 32,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Clearance Document',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Text bubble
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primary
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: AppTypography.bodySm.copyWith(
                            color: isUser
                                ? Colors.white
                                : AppColors.onBackground,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Timestamp
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: isUser ? 0 : 36,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  message.time,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
