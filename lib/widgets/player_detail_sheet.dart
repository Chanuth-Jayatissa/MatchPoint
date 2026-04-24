import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';
import '../utils/sport_utils.dart';

/// Full player profile bottom sheet — shows ratings, respect score,
/// recent match history, and challenge/follow buttons.
class PlayerDetailSheet extends StatelessWidget {
  final Player player;
  final VoidCallback onChallenge;
  final VoidCallback onClose;

  const PlayerDetailSheet({
    super.key,
    required this.player,
    required this.onChallenge,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Sort ratings by highest
    final sortedRatings = List<SportRating>.from(player.sportRatings)
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderInput,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Avatar + Info + Close
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.surface,
                        backgroundImage: player.avatarUrl != null
                            ? CachedNetworkImageProvider(player.avatarUrl!)
                            : null,
                        child: player.avatarUrl == null
                            ? const Icon(Icons.person, size: 36, color: AppTheme.textMuted)
                            : null,
                      ),
                      const SizedBox(width: 16),

                      // Name + Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(player.username, style: AppTheme.headingSmall),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: player.availableNow
                                        ? AppTheme.successGreen
                                        : AppTheme.textMuted,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  player.availableNow
                                      ? 'Available Now'
                                      : 'Last active ${player.lastActive ?? "recently"}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: player.availableNow
                                        ? AppTheme.successGreen
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Sport tags
                            Wrap(
                              spacing: 6,
                              children: player.sports.map((sport) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${SportUtils.getEmoji(sport)} $sport',
                                    style: AppTheme.caption.copyWith(fontSize: 11),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      // Close button
                      GestureDetector(
                        onTap: onClose,
                        child: const Icon(Icons.close, color: AppTheme.textSecondary, size: 24),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Respect Score
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.yellowLightBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Respect Score', style: AppTheme.caption.copyWith(color: AppTheme.darkAmber)),
                            Text(
                              '${player.respectScore}/100',
                              style: AppTheme.headingSmall.copyWith(
                                color: AppTheme.darkAmber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sport Ratings
                  if (sortedRatings.isNotEmpty) ...[
                    Text('Sport Ratings', style: AppTheme.labelLarge),
                    const SizedBox(height: 10),
                    ...sortedRatings.map((rating) => _RatingRow(rating: rating)),
                    const SizedBox(height: 20),
                  ],

                  // Recent Match History
                  if (player.recentMatchHistory.isNotEmpty) ...[
                    Text('Recent Matches', style: AppTheme.labelLarge),
                    const SizedBox(height: 10),
                    ...player.recentMatchHistory.map((match) => _MatchHistoryRow(match: match)),
                    const SizedBox(height: 20),
                  ],

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: onChallenge,
                            icon: const Icon(Icons.flash_on, size: 20),
                            label: const Text('Challenge'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.person_add_alt_1, size: 20),
                            label: const Text('Follow'),
                          ),
                        ),
                      ),
                    ],
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

class _RatingRow extends StatelessWidget {
  final SportRating rating;
  const _RatingRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final trendIcon = rating.trend == 'up'
        ? Icons.trending_up
        : rating.trend == 'down'
            ? Icons.trending_down
            : Icons.trending_flat;
    final trendColor = rating.trend == 'up'
        ? AppTheme.successGreen
        : rating.trend == 'down'
            ? AppTheme.errorRed
            : AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(SportUtils.getEmoji(rating.sport), style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(rating.sport, style: AppTheme.labelMedium),
          ),
          Text(
            '${rating.rating}',
            style: AppTheme.headingSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Icon(trendIcon, size: 18, color: trendColor),
        ],
      ),
    );
  }
}

class _MatchHistoryRow extends StatelessWidget {
  final RecentMatchResult match;
  const _MatchHistoryRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final isWin = match.result == 'Win';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(match.date, style: AppTheme.caption),
          const SizedBox(width: 10),
          Text(SportUtils.getEmoji(match.sport), style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'vs ${match.opponent}',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: (isWin ? AppTheme.successGreen : AppTheme.errorRed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              match.result,
              style: AppTheme.caption.copyWith(
                color: isWin ? AppTheme.successGreen : AppTheme.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
