import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/match_model.dart';
import '../providers/match_provider.dart';
import '../providers/supabase_provider.dart';
import '../widgets/match_card.dart';
import '../widgets/log_result_modal.dart';

/// Matches Screen — 4-tab lifecycle management:
/// Accept (pending) → Log (to_log) → Verify (to_verify) → Disputed
class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  int _activeTab = 0;

  static const _tabs = [
    _TabInfo('Accept', AppTheme.acceptYellow, Icons.handshake_outlined),
    _TabInfo('Log', AppTheme.primaryOrange, Icons.edit_note),
    _TabInfo('Verify', AppTheme.successGreen, Icons.verified_outlined),
    _TabInfo('Disputed', AppTheme.errorRed, Icons.flag_outlined),
  ];

  List<MatchModel> _filterMatches(List<MatchModel> matches) {
    switch (_activeTab) {
      case 0: // Accept
        return matches.where((m) => m.status == MatchStatus.pending).toList();
      case 1: // Log
        return matches
            .where((m) =>
                m.status == MatchStatus.accepted ||
                m.status == MatchStatus.toLog)
            .toList();
      case 2: // Verify
        return matches
            .where((m) => m.status == MatchStatus.toVerify)
            .toList();
      case 3: // Disputed
        return matches
            .where((m) => m.status == MatchStatus.disputed)
            .toList();
      default:
        return matches;
    }
  }

  // ──── Actions ────
  void _handleAccept(MatchModel match) {
    ref.read(matchServiceProvider).acceptChallenge(match.id).then((_) {
      _showSnackBar('Match accepted! Ready to log result.', AppTheme.successGreen);
    }).catchError((e) {
      _showSnackBar('Failed to accept challenge: $e', AppTheme.errorRed);
    });
  }

  void _handleDecline(MatchModel match) {
    ref.read(matchServiceProvider).rejectChallenge(match.id).then((_) {
      _showSnackBar('Match declined.', AppTheme.textSecondary);
    }).catchError((e) {
      _showSnackBar('Failed to decline challenge: $e', AppTheme.errorRed);
    });
  }

  void _handleLogResult(MatchModel match) {
    final currentUserId = ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';
    final isChallenger = match.challengerId == currentUserId;
    final opponentName = isChallenger
        ? (match.opponentUsername ?? 'Opponent')
        : (match.challengerUsername ?? 'Challenger');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogResultModal(
        opponentName: opponentName,
        sport: match.sport,
        onSubmit: (result) {
          final resultForChallenger = isChallenger
              ? result.result
              : (result.result == 'win' ? 'loss' : 'win');
          
          ref.read(matchServiceProvider).logScore(
            matchId: match.id,
            score: result.score,
            resultForChallenger: resultForChallenger,
          ).then((_) {
            _showSnackBar('Result logged! Waiting for opponent to verify.', AppTheme.successGreen);
          }).catchError((e) {
            _showSnackBar('Failed to log result: $e', AppTheme.errorRed);
          });
        },
      ),
    );
  }

  void _handleVerify(MatchModel match) {
    ref.read(matchServiceProvider).verifyMatch(match.id).then((_) {
      _showSnackBar('Match verified! ELO ratings updated. ⚡', AppTheme.successGreen);
    }).catchError((e) {
      _showSnackBar('Failed to verify match: $e', AppTheme.errorRed);
    });
  }

  void _handleDispute(MatchModel match) {
    ref.read(matchServiceProvider).disputeMatch(match.id, 'Score does not match').then((_) {
      _showSnackBar('Match disputed. We\'ll review.', AppTheme.errorRed);
    }).catchError((e) {
      _showSnackBar('Failed to dispute match: $e', AppTheme.errorRed);
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(matchesStreamProvider);
    final currentUserId = ref.watch(supabaseClientProvider).auth.currentUser?.id ?? '';

    return SafeArea(
      child: matchesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryOrange),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error loading matches: $err',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorRed),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (matches) {
          final filtered = _filterMatches(matches);
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text('Your Matches', style: AppTheme.headingLarge),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4-tab status strip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(_tabs.length, (i) {
                    final tab = _tabs[i];
                    final isActive = _activeTab == i;
                    final count = _getTabCount(matches, i);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive ? tab.color : AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive ? tab.color : AppTheme.border,
                              width: isActive ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                tab.icon,
                                size: 18,
                                color: isActive ? Colors.white : AppTheme.textSecondary,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tab.label,
                                style: AppTheme.labelSmall.copyWith(
                                  color: isActive ? Colors.white : AppTheme.textSecondary,
                                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.white.withOpacity(0.3)
                                        : tab.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: AppTheme.caption.copyWith(
                                      color: isActive ? Colors.white : tab.color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 14),

              // Match list
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => MatchCard(
                          match: filtered[i],
                          currentUserId: currentUserId,
                          onAccept: () => _handleAccept(filtered[i]),
                          onDecline: () => _handleDecline(filtered[i]),
                          onLogResult: () => _handleLogResult(filtered[i]),
                          onVerify: () => _handleVerify(filtered[i]),
                          onDispute: () => _handleDispute(filtered[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _getTabCount(List<MatchModel> matches, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return matches.where((m) => m.status == MatchStatus.pending).length;
      case 1:
        return matches
            .where((m) =>
                m.status == MatchStatus.accepted ||
                m.status == MatchStatus.toLog)
            .length;
      case 2:
        return matches.where((m) => m.status == MatchStatus.toVerify).length;
      case 3:
        return matches.where((m) => m.status == MatchStatus.disputed).length;
      default:
        return 0;
    }
  }

  Widget _buildEmptyState() {
    final tab = _tabs[_activeTab];
    final messages = [
      'No pending challenges',
      'No matches to log',
      'No matches to verify',
      'No disputed matches',
    ];
    final subtitles = [
      'Challenge a player from the Home tab!',
      'Accept a challenge first, then log results here.',
      'Log a result first, then your opponent can verify.',
      'All clear! No disputes to handle.',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 48, color: AppTheme.borderInput),
            const SizedBox(height: 16),
            Text(
              messages[_activeTab],
              style: AppTheme.headingSmall.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              subtitles[_activeTab],
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabInfo {
  final String label;
  final Color color;
  final IconData icon;
  const _TabInfo(this.label, this.color, this.icon);
}
