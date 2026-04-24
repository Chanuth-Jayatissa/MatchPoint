/// A social feed post.
class Post {
  final String id;
  final String authorId;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final String sport;
  final String content;
  final String? imageUrl;
  final String tag; // 'highlight', 'question', 'general'
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.authorId,
    this.authorUsername,
    this.authorAvatarUrl,
    required this.sport,
    required this.content,
    this.imageUrl,
    this.tag = 'general',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      authorUsername: json['author_username'] as String?,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      sport: json['sport'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      tag: json['tag'] as String? ?? 'general',
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'author_id': authorId,
        'sport': sport,
        'content': content,
        'image_url': imageUrl,
        'tag': tag,
      };

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${(diff.inDays / 7).floor()} weeks ago';
  }

  Post copyWith({bool? isLiked, int? likesCount}) {
    return Post(
      id: id,
      authorId: authorId,
      authorUsername: authorUsername,
      authorAvatarUrl: authorAvatarUrl,
      sport: sport,
      content: content,
      imageUrl: imageUrl,
      tag: tag,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }
}

/// A comment on a post.
class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String? authorUsername;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    this.authorUsername,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      authorUsername: json['author_username'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}
