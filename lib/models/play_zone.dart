import 'player.dart';

/// A geographic cluster of players on the map.
class PlayZone {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final List<Player> players;
  final bool isUserZone;

  const PlayZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.players = const [],
    this.isUserZone = false,
  });

  factory PlayZone.fromJson(Map<String, dynamic> json) {
    return PlayZone(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isUserZone: json['is_user_zone'] as bool? ?? false,
    );
  }

  PlayZone copyWith({List<Player>? players, bool? isUserZone}) {
    return PlayZone(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      players: players ?? this.players,
      isUserZone: isUserZone ?? this.isUserZone,
    );
  }
}
