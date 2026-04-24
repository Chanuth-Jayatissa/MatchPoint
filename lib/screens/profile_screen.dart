import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';
import '../utils/sport_utils.dart';
import '../services/auth_service.dart';
import '../config/supabase_config.dart';
import '../widgets/settings_modal.dart';

/// Profile Screen — user profile with avatar, stats, ratings, match history, settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock current user profile (will be replaced with real auth data)
  Player _currentUser = const Player(
    id: 'current_user',
    username: 'YourUsername',
    avatarUrl:
        'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
    sports: ['Pickleball', 'Badminton', 'Table Tennis'],
    availableNow: true,
    respectScore: 87,
    locationText: 'Downtown Sports Complex',
    lastActive: 'Just now',
    sportRatings: [
      SportRating(sport: 'Pickleball', rating: 1680, trend: 'up'),
      SportRating(sport: 'Badminton', rating: 1520, trend: 'stable'),
      SportRating(sport: 'Table Tennis', rating: 1430, trend: 'down'),
    ],
    recentMatchHistory: [
      RecentMatchResult(
          date: '12/15', sport: 'Pickleball', opponent: 'PickleballAce_23', result: 'Win'),
      RecentMatchResult(
          date: '12/14', sport: 'Badminton', opponent: 'BadmintonPro', result: 'Loss'),
      RecentMatchResult(
          date: '12/12', sport: 'Table Tennis', opponent: 'PingPongKing', result: 'Win'),
      RecentMatchResult(
          date: '12/10', sport: 'Pickleball', opponent: 'CourtCrusher', result: 'Win'),
      RecentMatchResult(
          date: '12/08', sport: 'Badminton', opponent: 'NetNinja', result: 'Loss'),
    ],
  );

  bool _notificationsEnabled = true;
  bool _gpsEnabled = true;
  bool _hideFromMap = false;

  int get _totalMatches => _currentUser.recentMatchHistory.length;
  int get _wins => _currentUser.recentMatchHistory.where((m) => m.result == 'Win').length;
  int get _winRate => _totalMatches > 0 ? ((_wins / _totalMatches) * 100).round() : 0;

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsModal(
        availableNow: _currentUser.availableNow,
        notificationsEnabled: _notificationsEnabled,
        gpsEnabled: _gpsEnabled,
        hideFromMap: _hideFromMap,
        onAvailableChanged: (val) {
          setState(() {
            _currentUser = Player(
              id: _currentUser.id,
              username: _currentUser.username,
              avatarUrl: _currentUser.avatarUrl,
              sports: _currentUser.sports,
              availableNow: val,
              respectScore: _currentUser.respectScore,
              locationText: _currentUser.locationText,
              lastActive: _currentUser.lastActive,
              sportRatings: _currentUser.sportRatings,
              recentMatchHistory: _currentUser.recentMatchHistory,
            );
          });
        },
        onNotificationsChanged: (val) => setState(() => _notificationsEnabled = val),
        onGpsChanged: (val) => setState(() => _gpsEnabled = val),
        onHideFromMapChanged: (val) => setState(() => _hideFromMap = val),
        onSignOut: () async {
          if (SupabaseConfig.isConfigured) {
            await AuthService.signOut();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedRatings = List<SportRating>.from(_currentUser.sportRatings)
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Profile', style: AppTheme.headingLarge),
                  GestureDetector(
                    onTap: _showSettings,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(Icons.settings_outlined, size: 22, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Profile Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar + availability badge
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppTheme.surface,
                        backgroundImage: _currentUser.avatarUrl != null
                            ? CachedNetworkImageProvider(_currentUser.avatarUrl!)
                            : null,
                        child: _currentUser.avatarUrl == null
                            ? const Icon(Icons.person, size: 48, color: AppTheme.textMuted)
                            : null,
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _currentUser.availableNow
                                  ? AppTheme.successGreen
                                  : AppTheme.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Username
                  Text(_currentUser.username, style: AppTheme.headingMedium),
                  const SizedBox(height: 4),

                  // Location
                  if (_currentUser.locationText != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _currentUser.locationText!,
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),

                  const SizedBox(height: 6),

                  // Sport chips
                  Wrap(
                    spacing: 6,
                    children: _currentUser.sports.map((sport) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

                  const SizedBox(height: 18),

                  // Stats row
                  Row(
                    children: [
                      _StatItem(
                        label: 'Matches',
                        value: '$_totalMatches',
                        color: AppTheme.primaryBlue,
                      ),
                      _StatDivider(),
                      _StatItem(
                        label: 'Win Rate',
                        value: '$_winRate%',
                        color: AppTheme.successGreen,
                      ),
                      _StatDivider(),
                      _StatItem(
                        label: 'Respect',
                        value: '${_currentUser.respectScore}',
                        color: AppTheme.warningYellow,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sport Ratings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sport Ratings', style: AppTheme.headingSmall),
                  const SizedBox(height: 12),
                  ...sortedRatings.map((rating) => _RatingCard(rating: rating)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recent Match History Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Matches', style: AppTheme.headingSmall),
                      Text(
                        '$_wins W - ${_totalMatches - _wins} L',
                        style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._currentUser.recentMatchHistory.map(
                    (match) => _MatchHistoryTile(match: match),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppTheme.border,
    );
  }
}

class _RatingCard extends StatelessWidget {
  final SportRating rating;
  const _RatingCard({required this.rating});

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
    final trendText = rating.trend == 'up'
        ? 'Rising'
        : rating.trend == 'down'
            ? 'Falling'
            : 'Stable';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sport emoji circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              SportUtils.getEmoji(rating.sport),
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 14),

          // Sport name + trend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rating.sport, style: AppTheme.labelMedium),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(trendIcon, size: 14, color: trendColor),
                    const SizedBox(width: 4),
                    Text(
                      trendText,
                      style: AppTheme.caption.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Rating number
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${rating.rating}',
                style: AppTheme.headingMedium.copyWith(fontSize: 22),
              ),
              Text('ELO', style: AppTheme.caption.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchHistoryTile extends StatelessWidget {
  final RecentMatchResult match;
  const _MatchHistoryTile({required this.match});

  @override
  Widget build(BuildContext context) {
    final isWin = match.result == 'Win';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          // Result indicator
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: isWin ? AppTheme.successGreen : AppTheme.errorRed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // Sport emoji
          Text(SportUtils.getEmoji(match.sport), style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),

          // Opponent + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'vs ${match.opponent}',
                  style: AppTheme.labelMedium.copyWith(fontSize: 13),
                ),
                Text(
                  '${match.sport} • ${match.date}',
                  style: AppTheme.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          // Result badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isWin ? AppTheme.successGreen : AppTheme.errorRed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              match.result,
              style: AppTheme.labelMedium.copyWith(
                color: isWin ? AppTheme.successGreen : AppTheme.errorRed,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
