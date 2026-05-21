import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import 'supabase_provider.dart';

final currentPlayerProvider = FutureProvider<Player?>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  final response = await supabase
      .from('profiles')
      .select('*, sport_ratings(*)')
      .eq('id', user.id)
      .maybeSingle();

  if (response == null) return null;
  return Player.fromJson(response);
});

final allPlayersProvider = FutureProvider<List<Player>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase
      .from('profiles')
      .select('*, sport_ratings(*)');
      
  return (response as List).map((json) => Player.fromJson(json)).toList();
});
