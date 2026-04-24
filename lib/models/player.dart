/// Represents a player/user in the MatchPoint system.
class Player {
  final String id;
  final String username;
  final String? avatarUrl;
  final List<String> sports;
  final double? latitude;
  final double? longitude;
  final String? locationText;
  final bool availableNow;
  final int respectScore;
  final String? lastActive;
  final bool hideFromMap;
  final List<SportRating> sportRatings;
  final List<RecentMatchResult> recentMatchHistory;

  const Player({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.sports = const [],
    this.latitude,
    this.longitude,
    this.locationText,
    this.availableNow = false,
    this.respectScore = 50,
    this.lastActive,
    this.hideFromMap = false,
    this.sportRatings = const [],
    this.recentMatchHistory = const [],
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      sports: List<String>.from(json['sports'] ?? []),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationText: json['location_text'] as String?,
      availableNow: json['available_now'] as bool? ?? false,
      respectScore: json['respect_score'] as int? ?? 50,
      lastActive: json['last_active'] as String?,
      hideFromMap: json['hide_from_map'] as bool? ?? false,
      sportRatings: (json['sport_ratings'] as List<dynamic>?)
              ?.map((e) => SportRating.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentMatchHistory: [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'avatar_url': avatarUrl,
        'sports': sports,
        'latitude': latitude,
        'longitude': longitude,
        'location_text': locationText,
        'available_now': availableNow,
        'respect_score': respectScore,
        'hide_from_map': hideFromMap,
      };
}

/// Per-sport ELO rating for a player.
class SportRating {
  final String sport;
  final int rating;
  final String trend; // 'up', 'down', 'stable'

  const SportRating({
    required this.sport,
    this.rating = 1200,
    this.trend = 'stable',
  });

  factory SportRating.fromJson(Map<String, dynamic> json) {
    return SportRating(
      sport: json['sport'] as String,
      rating: json['rating'] as int? ?? 1200,
      trend: json['trend'] as String? ?? 'stable',
    );
  }

  Map<String, dynamic> toJson() => {
        'sport': sport,
        'rating': rating,
        'trend': trend,
      };
}

/// A single match result shown in a player's history.
class RecentMatchResult {
  final String date;
  final String sport;
  final String opponent;
  final String result; // 'Win' or 'Loss'

  const RecentMatchResult({
    required this.date,
    required this.sport,
    required this.opponent,
    required this.result,
  });

  factory RecentMatchResult.fromJson(Map<String, dynamic> json) {
    return RecentMatchResult(
      date: json['date'] as String,
      sport: json['sport'] as String,
      opponent: json['opponent'] as String,
      result: json['result'] as String,
    );
  }
}
