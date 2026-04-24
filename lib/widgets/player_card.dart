import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';
import '../utils/sport_utils.dart';

/// Mini player card shown in the zone drawer grid.
class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;

  const PlayerCard({
    super.key,
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final availability = SportUtils.getAvailabilityStatus(
      availableNow: player.availableNow,
      lastActive: player.lastActive,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with availability dot
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.surface,
                  backgroundImage: player.avatarUrl != null
                      ? CachedNetworkImageProvider(player.avatarUrl!)
                      : null,
                  child: player.avatarUrl == null
                      ? const Icon(Icons.person, size: 28, color: AppTheme.textMuted)
                      : null,
                ),
                if (player.availableNow)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Username
            Text(
              player.username,
              style: AppTheme.labelMedium.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // Sport emojis
            Text(
              player.sports.map((s) => SportUtils.getEmoji(s)).join(' '),
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 4),

            // Availability text
            Text(
              availability.text,
              style: AppTheme.caption.copyWith(
                color: availability.color,
                fontSize: 10,
                fontWeight: player.availableNow ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
