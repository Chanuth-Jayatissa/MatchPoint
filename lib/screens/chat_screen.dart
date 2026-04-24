import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/thread.dart';
import '../data/mock_data.dart';

/// Full chat view — message bubbles, text input, expiry warning, report/block.
class ChatScreen extends StatefulWidget {
  final Thread thread;

  const ChatScreen({super.key, required this.thread});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late List<Message> _messages;
  static const _currentUserId = 'current_user';

  @override
  void initState() {
    super.initState();
    _messages = MockData.getMessagesForThread(widget.thread.id);
    // Scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        threadId: widget.thread.id,
        senderId: _currentUserId,
        content: text,
        createdAt: DateTime.now(),
      ));
    });
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _showReportBlockSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderInput,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Options', style: AppTheme.headingSmall),
              const SizedBox(height: 16),
              _OptionTile(
                icon: Icons.flag_outlined,
                label: 'Report User',
                color: AppTheme.warningYellow,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Report submitted. We\'ll review it.',
                          style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
                      backgroundColor: AppTheme.warningYellow,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
              _OptionTile(
                icon: Icons.block,
                label: 'Block User',
                color: AppTheme.errorRed,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User blocked.',
                          style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
                      backgroundColor: AppTheme.errorRed,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.surface,
              backgroundImage: widget.thread.otherPlayerAvatarUrl != null
                  ? NetworkImage(widget.thread.otherPlayerAvatarUrl!)
                  : null,
              child: widget.thread.otherPlayerAvatarUrl == null
                  ? const Icon(Icons.person, size: 18, color: AppTheme.textMuted)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.thread.otherPlayerUsername ?? 'Chat',
                style: AppTheme.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            onPressed: _showReportBlockSheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: Column(
        children: [
          // Expiry warning banner
          if (widget.thread.expiresAt != null) _buildExpiryBanner(),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 40, color: AppTheme.borderInput),
                        const SizedBox(height: 12),
                        Text('Say hello! 👋', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isMe = msg.isFromUser(_currentUserId);
                      final showAvatar = !isMe &&
                          (i == 0 || _messages[i - 1].senderId != msg.senderId);

                      return _MessageBubble(
                        message: msg,
                        isMe: isMe,
                        showAvatar: showAvatar,
                        otherAvatarUrl: widget.thread.otherPlayerAvatarUrl,
                      );
                    },
                  ),
          ),

          // Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildExpiryBanner() {
    final expired = widget.thread.isExpired;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: expired
          ? AppTheme.errorRed.withOpacity(0.1)
          : AppTheme.yellowLightBg,
      child: Row(
        children: [
          Icon(
            expired ? Icons.lock : Icons.timer_outlined,
            size: 16,
            color: expired ? AppTheme.errorRed : AppTheme.darkAmber,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              expired
                  ? 'This chat has expired.'
                  : 'Chat expires 24h after match verification',
              style: AppTheme.bodySmall.copyWith(
                color: expired ? AppTheme.errorRed : AppTheme.darkAmber,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final expired = widget.thread.isExpired;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !expired,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: expired ? 'Chat expired' : 'Type a message...',
                  border: InputBorder.none,
                  hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: expired ? null : _sendMessage,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: expired ? AppTheme.borderInput : AppTheme.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                size: 20,
                color: expired ? AppTheme.textMuted : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showAvatar;
  final String? otherAvatarUrl;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    this.otherAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for other user
          if (!isMe)
            SizedBox(
              width: 32,
              child: showAvatar
                  ? CircleAvatar(
                      radius: 14,
                      backgroundColor: AppTheme.surface,
                      backgroundImage: otherAvatarUrl != null
                          ? NetworkImage(otherAvatarUrl!)
                          : null,
                      child: otherAvatarUrl == null
                          ? const Icon(Icons.person, size: 14, color: AppTheme.textMuted)
                          : null,
                    )
                  : null,
            ),

          const SizedBox(width: 6),

          // Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primaryBlue : AppTheme.surfaceLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.content,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isMe ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.formattedTime,
                    style: AppTheme.caption.copyWith(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withOpacity(0.7)
                          : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: AppTheme.labelMedium.copyWith(color: color)),
      onTap: onTap,
    );
  }
}
