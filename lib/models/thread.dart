/// A chat message thread between two players (created on match acceptance).
class Thread {
  final String id;
  final String matchId;
  final String player1Id;
  final String player2Id;
  final String? otherPlayerUsername;
  final String? otherPlayerAvatarUrl;
  final String? lastMessageText;
  final DateTime? lastMessageTime;
  final bool isUnread;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const Thread({
    required this.id,
    required this.matchId,
    required this.player1Id,
    required this.player2Id,
    this.otherPlayerUsername,
    this.otherPlayerAvatarUrl,
    this.lastMessageText,
    this.lastMessageTime,
    this.isUnread = false,
    this.expiresAt,
    required this.createdAt,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'] as String,
      matchId: json['match_id'] as String,
      player1Id: json['player1_id'] as String,
      player2Id: json['player2_id'] as String,
      otherPlayerUsername: json['other_player_username'] as String?,
      otherPlayerAvatarUrl: json['other_player_avatar_url'] as String?,
      lastMessageText: json['last_message_text'] as String?,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'] as String)
          : null,
      isUnread: json['is_unread'] as bool? ?? false,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Whether this thread has expired (24h after match verification).
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  String get lastMessageTimeAgo {
    if (lastMessageTime == null) return '';
    final diff = DateTime.now().difference(lastMessageTime!);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${(diff.inDays / 7).floor()} weeks ago';
  }
}

/// A single chat message.
class Message {
  final String id;
  final String threadId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      threadId: json['thread_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'thread_id': threadId,
        'sender_id': senderId,
        'content': content,
      };

  /// Whether this message was sent by the given user.
  bool isFromUser(String userId) => senderId == userId;

  String get formattedTime {
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }
}
