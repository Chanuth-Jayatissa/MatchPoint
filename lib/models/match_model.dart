/// Match status lifecycle:
/// pending → accepted → to_log → to_verify → verified | disputed
enum MatchStatus {
  pending,
  accepted,
  toLog,
  toVerify,
  verified,
  disputed;

  String get value {
    switch (this) {
      case MatchStatus.pending:
        return 'pending';
      case MatchStatus.accepted:
        return 'accepted';
      case MatchStatus.toLog:
        return 'to_log';
      case MatchStatus.toVerify:
        return 'to_verify';
      case MatchStatus.verified:
        return 'verified';
      case MatchStatus.disputed:
        return 'disputed';
    }
  }

  static MatchStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return MatchStatus.pending;
      case 'accepted':
        return MatchStatus.accepted;
      case 'to_log':
        return MatchStatus.toLog;
      case 'to_verify':
        return MatchStatus.toVerify;
      case 'verified':
        return MatchStatus.verified;
      case 'disputed':
        return MatchStatus.disputed;
      default:
        return MatchStatus.pending;
    }
  }
}

/// A match between two players.
class MatchModel {
  final String id;
  final String challengerId;
  final String opponentId;
  final String? challengerUsername;
  final String? opponentUsername;
  final String? challengerAvatarUrl;
  final String? opponentAvatarUrl;
  final String sport;
  final String? courtId;
  final String? courtName;
  final String? courtLocation;
  final MatchStatus status;
  final bool challengerAccepted;
  final bool opponentAccepted;
  final bool courtChanged;
  final String? score;
  final String? resultForChallenger; // 'win' | 'loss'
  final String? loggedBy;
  final bool verified;
  final bool disputed;
  final String? disputeReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MatchModel({
    required this.id,
    required this.challengerId,
    required this.opponentId,
    this.challengerUsername,
    this.opponentUsername,
    this.challengerAvatarUrl,
    this.opponentAvatarUrl,
    required this.sport,
    this.courtId,
    this.courtName,
    this.courtLocation,
    this.status = MatchStatus.pending,
    this.challengerAccepted = true,
    this.opponentAccepted = false,
    this.courtChanged = false,
    this.score,
    this.resultForChallenger,
    this.loggedBy,
    this.verified = false,
    this.disputed = false,
    this.disputeReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      challengerId: json['challenger_id'] as String,
      opponentId: json['opponent_id'] as String,
      challengerUsername: json['challenger_username'] as String?,
      opponentUsername: json['opponent_username'] as String?,
      challengerAvatarUrl: json['challenger_avatar_url'] as String?,
      opponentAvatarUrl: json['opponent_avatar_url'] as String?,
      sport: json['sport'] as String,
      courtId: json['court_id'] as String?,
      courtName: json['court_name'] as String?,
      courtLocation: json['court_location'] as String?,
      status: MatchStatus.fromString(json['status'] as String? ?? 'pending'),
      challengerAccepted: json['challenger_accepted'] as bool? ?? true,
      opponentAccepted: json['opponent_accepted'] as bool? ?? false,
      courtChanged: json['court_changed'] as bool? ?? false,
      score: json['score'] as String?,
      resultForChallenger: json['result_for_challenger'] as String?,
      loggedBy: json['logged_by'] as String?,
      verified: json['verified'] as bool? ?? false,
      disputed: json['disputed'] as bool? ?? false,
      disputeReason: json['dispute_reason'] as String?,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'challenger_id': challengerId,
        'opponent_id': opponentId,
        'sport': sport,
        'court_id': courtId,
        'status': status.value,
        'challenger_accepted': challengerAccepted,
        'opponent_accepted': opponentAccepted,
        'court_changed': courtChanged,
        'score': score,
        'result_for_challenger': resultForChallenger,
        'logged_by': loggedBy,
        'verified': verified,
        'disputed': disputed,
        'dispute_reason': disputeReason,
      };

  /// Get the display-friendly timestamp.
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${(diff.inDays / 7).floor()} weeks ago';
  }
}
