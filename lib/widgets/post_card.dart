import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/post.dart';
import '../utils/sport_utils.dart';

/// Social feed post card — author info, content, image, likes, comments, tag badge.
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tagInfo = SportUtils.getTagInfo(post.tag);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.surface,
                        backgroundImage: post.authorAvatarUrl != null
                            ? CachedNetworkImageProvider(post.authorAvatarUrl!)
                            : null,
                        child: post.authorAvatarUrl == null
                            ? const Icon(Icons.person, size: 20, color: AppTheme.textMuted)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorUsername ?? 'Unknown',
                              style: AppTheme.labelMedium,
                            ),
                            Row(
                              children: [
                                Text(
                                  '${SportUtils.getEmoji(post.sport)} ${post.sport}',
                                  style: AppTheme.caption.copyWith(fontSize: 11),
                                ),
                                const SizedBox(width: 6),
                                Text('•', style: AppTheme.caption),
                                const SizedBox(width: 6),
                                Text(
                                  post.timeAgo,
                                  style: AppTheme.caption.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Tag badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: tagInfo.bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tagInfo.icon, size: 12, color: tagInfo.iconColor),
                            const SizedBox(width: 4),
                            Text(
                              post.tag[0].toUpperCase() + post.tag.substring(1),
                              style: AppTheme.caption.copyWith(
                                fontSize: 10,
                                color: tagInfo.iconColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Content
                  Text(
                    post.content,
                    style: AppTheme.bodyMedium.copyWith(
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            // Image
            if (post.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 200,
                    color: AppTheme.surface,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: AppTheme.surface,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 32, color: AppTheme.textMuted),
                    ),
                  ),
                ),
              ),
            ],

            // Actions bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  // Like button
                  _ActionButton(
                    icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '${post.likesCount}',
                    color: post.isLiked ? AppTheme.errorRed : AppTheme.textSecondary,
                    onTap: onLike,
                  ),
                  const SizedBox(width: 16),
                  // Comment button
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '${post.commentsCount}',
                    color: AppTheme.textSecondary,
                    onTap: onComment,
                  ),
                  const Spacer(),
                  // Share
                  _ActionButton(
                    icon: Icons.share_outlined,
                    label: '',
                    color: AppTheme.textSecondary,
                    onTap: () {},
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTheme.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
