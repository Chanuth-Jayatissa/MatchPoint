import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/court.dart';
import '../models/play_zone.dart';
import '../models/player.dart';
import 'supabase_provider.dart';

final courtsProvider = FutureProvider<List<Court>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase.from('courts').select('*');
  return (response as List).map((json) => Court.fromJson(json)).toList();
});

final playZonesProvider = FutureProvider<List<PlayZone>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  final response = await supabase
      .from('play_zones')
      .select('*, player_zones(player_id, is_home_zone, profiles(*, sport_ratings(*)))');

  return (response as List).map((json) {
    final list = json['player_zones'] as List? ?? [];
    final players = list.map((pz) {
      final profile = pz['profiles'] as Map<String, dynamic>;
      return Player.fromJson(profile);
    }).toList();

    final isUserZone = list.any((pz) => pz['player_id'] == user?.id && pz['is_home_zone'] == true);

    return PlayZone.fromJson(json).copyWith(
      players: players,
      isUserZone: isUserZone,
    );
  }).toList();
});
