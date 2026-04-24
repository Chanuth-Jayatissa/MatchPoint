import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/match_model.dart';
import '../data/mock_data.dart';
import '../widgets/match_card.dart';
import '../widgets/log_result_modal.dart';

/// Matches Screen — 4-tab lifecycle management:
/// Accept (pending) → Log (to_log) → Verify (to_verify) → Disputed
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  int _activeTab = 0;
  late List<MatchModel> _matches;

  static const _tabs = [
    _TabInfo('Accept', AppTheme.acceptYellow, Icons.handshake_outlined),
    _TabInfo('Log', AppTheme.primaryOrange, Icons.edit_note),
    _TabInfo('Verify', AppTheme.successGreen, Icons.verified_outlined),
    _TabInfo('Disputed', AppTheme.errorRed, Icons.flag_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _matches = List.from(MockData.matches);
  }

  List<MatchModel> get _filteredMatches {
    switch (_activeTab) {
      case 0: // Accept
        return _matches.where((m) => m.status == MatchStatus.pending).toList();
      case 1: // Log
        return _matches
            .where((m) =>
                m.status == MatchStatus.accepted ||
                m.status == MatchStatus.toLog)
            .toList();
      case 2: // Verify
        return _matches
            .where((m) => m.status == MatchStatus.toVerify)
            .toList();
      case 3: // Disputed
        return _matches
            .where((m) => m.status == MatchStatus.disputed)
            .toList();
      default:
        return _matches;
    }
  }

  // ──── Actions ────
  void _handleAccept(MatchModel match) {
    setState(() {
      final idx = _matches.indexWhere((m) => m.id == match.id);
      if (idx != -1) {
        _matches[idx] = MatchModel(
          id: match.id,
          challengerId: match.challengerId,
          opponentId: match.opponentId,
          challengerUsername: match.challengerUsername,
          opponentUsername: match.opponentUsername,
          challengerAvatarUrl: match.challengerAvatarUrl,
          opponentAvatarUrl: match.opponentAvatarUrl,
          sport: match.sport,
          courtId: match.courtId,
          courtName: match.courtName,
          courtLocation: match.courtLocation,
          status: MatchStatus.toLog,
          challengerAccepted: true,
          opponentAccepted: true,
          createdAt: match.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    });
    _showSnackBar('Match accepted! Ready to log result.', AppTheme.successGreen);
  }

  void _handleDecline(MatchModel match) {
    setState(() {
      _matches.removeWhere((m) => m.id == match.id);
    });
    _showSnackBar('Match declined.', AppTheme.textSecondary);
  }

  void _handleLogResult(MatchModel match) {
    final isChallenger = match.challengerId == 'current_user';
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
          setState(() {
            final idx = _matches.indexWhere((m) => m.id == match.id);
            if (idx != -1) {
              _matches[idx] = MatchModel(
                id: match.id,
                challengerId: match.challengerId,
                opponentId: match.opponentId,
                challengerUsername: match.challengerUsername,
                opponentUsername: match.opponentUsername,
                challengerAvatarUrl: match.challengerAvatarUrl,
                opponentAvatarUrl: match.opponentAvatarUrl,
                sport: match.sport,
                courtId: match.courtId,
                courtName: match.courtName,
                courtLocation: match.courtLocation,
                status: MatchStatus.toVerify,
                challengerAccepted: true,
                opponentAccepted: true,
                score: result.score,
                resultForChallenger: isChallenger ? result.result : (result.result == 'win' ? 'loss' : 'win'),
                loggedBy: 'current_user',
                createdAt: match.createdAt,
                updatedAt: DateTime.now(),
              );
            }
          });
          _showSnackBar('Result logged! Waiting for opponent to verify.', AppTheme.successGreen);
        },
      ),
    );
  }

  void _handleVerify(MatchModel match) {
    setState(() {
      final idx = _matches.indexWhere((m) => m.id == match.id);
      if (idx != -1) {
        _matches[idx] = MatchModel(
          id: match.id,
          challengerId: match.challengerId,
          opponentId: match.opponentId,
          challengerUsername: match.challengerUsername,
          opponentUsername: match.opponentUsername,
          challengerAvatarUrl: match.challengerAvatarUrl,
          opponentAvatarUrl: match.opponentAvatarUrl,
          sport: match.sport,
          courtId: match.courtId,
          courtName: match.courtName,
          courtLocation: match.courtLocation,
          status: MatchStatus.verified,
          challengerAccepted: true,
          opponentAccepted: true,
          score: match.score,
          resultForChallenger: match.resultForChallenger,
          loggedBy: match.loggedBy,
          verified: true,
          createdAt: match.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    });
    _showSnackBar('Match verified! ELO ratings updated. ⚡', AppTheme.successGreen);
  }

  void _handleDispute(MatchModel match) {
    setState(() {
      final idx = _matches.indexWhere((m) => m.id == match.id);
      if (idx != -1) {
        _matches[idx] = MatchModel(
          id: match.id,
          challengerId: match.challengerId,
          opponentId: match.opponentId,
          challengerUsername: match.challengerUsername,
          opponentUsername: match.opponentUsername,
          challengerAvatarUrl: match.challengerAvatarUrl,
          opponentAvatarUrl: match.opponentAvatarUrl,
          sport: match.sport,
          courtId: match.courtId,
          courtName: match.courtName,
          courtLocation: match.courtLocation,
          status: MatchStatus.disputed,
          challengerAccepted: true,
          opponentAccepted: true,
          score: match.score,
          resultForChallenger: match.resultForChallenger,
          loggedBy: match.loggedBy,
          disputed: true,
          disputeReason: 'Score does not match',
          createdAt: match.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    });
    _showSnackBar('Match disputed. We\'ll review.', AppTheme.errorRed);
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
    final filtered = _filteredMatches;
    return SafeArea(
      child: Column(
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
                final count = _getTabCount(i);
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
                      onAccept: () => _handleAccept(filtered[i]),
                      onDecline: () => _handleDecline(filtered[i]),
                      onLogResult: () => _handleLogResult(filtered[i]),
                      onVerify: () => _handleVerify(filtered[i]),
                      onDispute: () => _handleDispute(filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  int _getTabCount(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _matches.where((m) => m.status == MatchStatus.pending).length;
      case 1:
        return _matches
            .where((m) =>
                m.status == MatchStatus.accepted ||
                m.status == MatchStatus.toLog)
            .length;
      case 2:
        return _matches.where((m) => m.status == MatchStatus.toVerify).length;
      case 3:
        return _matches.where((m) => m.status == MatchStatus.disputed).length;
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
