import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/thread.dart';
import '../data/mock_data.dart';
import 'chat_screen.dart';

/// Messages Screen — list of chat threads with unread indicators.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late List<Thread> _threads;

  @override
  void initState() {
    super.initState();
    _threads = List.from(MockData.threads);
  }

  int get _unreadCount => _threads.where((t) => t.isUnread).length;

  void _openChat(Thread thread) {
    // Mark as read
    setState(() {
      final idx = _threads.indexWhere((t) => t.id == thread.id);
      if (idx != -1 && _threads[idx].isUnread) {
        _threads[idx] = Thread(
          id: thread.id,
          matchId: thread.matchId,
          player1Id: thread.player1Id,
          player2Id: thread.player2Id,
          otherPlayerUsername: thread.otherPlayerUsername,
          otherPlayerAvatarUrl: thread.otherPlayerAvatarUrl,
          lastMessageText: thread.lastMessageText,
          lastMessageTime: thread.lastMessageTime,
          isUnread: false,
          expiresAt: thread.expiresAt,
          createdAt: thread.createdAt,
        );
      }
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(thread: thread),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
            ),
            child: Row(
              children: [
                Text('Messages', style: AppTheme.headingLarge),
                if (_unreadCount > 0) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: AppTheme.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Thread list
          Expanded(
            child: _threads.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: _threads.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 76,
                      color: AppTheme.borderLight,
                    ),
                    itemBuilder: (_, i) => _ThreadTile(
                      thread: _threads[i],
                      onTap: () => _openChat(_threads[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 48, color: AppTheme.borderInput),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              'Chat threads appear when a match is accepted.',
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// A single thread tile in the messages list.
class _ThreadTile extends StatelessWidget {
  final Thread thread;
  final VoidCallback onTap;

  const _ThreadTile({required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Avatar with online dot
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.surface,
                  backgroundImage: thread.otherPlayerAvatarUrl != null
                      ? CachedNetworkImageProvider(thread.otherPlayerAvatarUrl!)
                      : null,
                  child: thread.otherPlayerAvatarUrl == null
                      ? const Icon(Icons.person, size: 26, color: AppTheme.textMuted)
                      : null,
                ),
                // Unread dot
                if (thread.isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // Thread info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          thread.otherPlayerUsername ?? 'Unknown',
                          style: AppTheme.labelMedium.copyWith(
                            fontWeight: thread.isUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        thread.lastMessageTimeAgo,
                        style: AppTheme.caption.copyWith(
                          fontSize: 11,
                          color: thread.isUnread
                              ? AppTheme.primaryOrange
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.lastMessageText ?? 'Start a conversation',
                          style: AppTheme.bodySmall.copyWith(
                            color: thread.isUnread
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontWeight: thread.isUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Expiry indicator
                      if (thread.expiresAt != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          thread.isExpired ? Icons.lock : Icons.timer_outlined,
                          size: 14,
                          color: thread.isExpired
                              ? AppTheme.errorRed
                              : AppTheme.warningYellow,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
