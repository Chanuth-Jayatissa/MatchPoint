import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/match_model.dart';
import '../utils/sport_utils.dart';

/// A single match card showing opponent info, sport, court, time, and action buttons.
class MatchCard extends StatelessWidget {
  final MatchModel match;
  final String currentUserId;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onLogResult;
  final VoidCallback? onVerify;
  final VoidCallback? onDispute;

  const MatchCard({
    super.key,
    required this.match,
    this.currentUserId = 'current_user',
    this.onAccept,
    this.onDecline,
    this.onLogResult,
    this.onVerify,
    this.onDispute,
  });

  bool get _isChallenger => match.challengerId == currentUserId;
  String get _opponentName =>
      _isChallenger ? (match.opponentUsername ?? 'Opponent') : (match.challengerUsername ?? 'Challenger');
  String? get _opponentAvatar =>
      _isChallenger ? match.opponentAvatarUrl : match.challengerAvatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: opponent + time
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.surface,
                  backgroundImage: _opponentAvatar != null
                      ? CachedNetworkImageProvider(_opponentAvatar!)
                      : null,
                  child: _opponentAvatar == null
                      ? const Icon(Icons.person, size: 22, color: AppTheme.textMuted)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_opponentName, style: AppTheme.labelMedium),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            SportUtils.getEmoji(match.sport),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            match.sport,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(match.timeAgo, style: AppTheme.caption),
              ],
            ),

            const SizedBox(height: 12),

            // Court info
            if (match.courtName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.courtName!,
                            style: AppTheme.labelMedium.copyWith(fontSize: 13),
                          ),
                          if (match.courtLocation != null)
                            Text(
                              match.courtLocation!,
                              style: AppTheme.caption.copyWith(fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Score (for log/verify/dispute stages)
            if (match.score != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.scoreboard_outlined, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text('Score: ', style: AppTheme.caption),
                    Text(
                      match.score!,
                      style: AppTheme.labelMedium.copyWith(fontSize: 13),
                    ),
                    const Spacer(),
                    if (match.resultForChallenger != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getResultColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getResultText(),
                          style: AppTheme.caption.copyWith(
                            color: _getResultColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // Dispute reason
            if (match.disputed && match.disputeReason != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, size: 16, color: AppTheme.errorRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        match.disputeReason ?? 'Disputed by opponent',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.errorRed),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Action buttons
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Color _getResultColor() {
    final result = _isChallenger
        ? match.resultForChallenger
        : (match.resultForChallenger == 'win' ? 'loss' : 'win');
    return result == 'win' ? AppTheme.successGreen : AppTheme.errorRed;
  }

  String _getResultText() {
    final result = _isChallenger
        ? match.resultForChallenger
        : (match.resultForChallenger == 'win' ? 'loss' : 'win');
    return result == 'win' ? 'Win' : 'Loss';
  }

  Widget _buildActions() {
    switch (match.status) {
      case MatchStatus.pending:
        // Only the opponent (non-challenger) gets accept/decline
        if (!_isChallenger) {
          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: AppTheme.labelMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: onDecline,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const _StatusChip(
            text: 'Waiting for opponent...',
            color: AppTheme.acceptYellow,
            icon: Icons.hourglass_empty,
          );
        }

      case MatchStatus.accepted:
      case MatchStatus.toLog:
        return SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton.icon(
            onPressed: onLogResult,
            icon: const Icon(Icons.edit_note, size: 20),
            label: const Text('Log Result'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );

      case MatchStatus.toVerify:
        // Only the non-logger can verify
        if (match.loggedBy != currentUserId) {
          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: onVerify,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Verify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: onDispute,
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    label: const Text('Dispute'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side: const BorderSide(color: AppTheme.errorRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const _StatusChip(
            text: 'Waiting for opponent to verify...',
            color: AppTheme.successGreen,
            icon: Icons.hourglass_empty,
          );
        }

      case MatchStatus.verified:
        return const _StatusChip(
          text: 'Match verified ✓',
          color: AppTheme.successGreen,
          icon: Icons.check_circle,
        );

      case MatchStatus.disputed:
        return const _StatusChip(
          text: 'Match disputed',
          color: AppTheme.errorRed,
          icon: Icons.warning_amber,
        );
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const _StatusChip({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.labelMedium.copyWith(color: color, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
