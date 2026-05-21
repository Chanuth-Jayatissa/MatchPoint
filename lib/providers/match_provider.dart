import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match_model.dart';
import 'supabase_provider.dart';

final matchesStreamProvider = StreamProvider<List<MatchModel>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return Stream.value([]);

  final controller = StreamController<List<MatchModel>>();

  Future<void> fetchMatches() async {
    try {
      final response = await supabase
          .from('matches')
          .select('''
            *,
            challenger:profiles!challenger_id(username, avatar_url),
            opponent:profiles!opponent_id(username, avatar_url)
          ''')
          .or('challenger_id.eq.${user.id},opponent_id.eq.${user.id}')
          .order('created_at', ascending: false);

      final matches = (response as List).map((json) {
        final challenger = json['challenger'] as Map<String, dynamic>?;
        final opponent = json['opponent'] as Map<String, dynamic>?;
        
        final map = Map<String, dynamic>.from(json);
        map['challenger_username'] = challenger?['username'];
        map['challenger_avatar_url'] = challenger?['avatar_url'];
        map['opponent_username'] = opponent?['username'];
        map['opponent_avatar_url'] = opponent?['avatar_url'];
        
        return MatchModel.fromJson(map);
      }).toList();

      if (!controller.isClosed) {
        controller.add(matches);
      }
    } catch (e, s) {
      if (!controller.isClosed) {
        controller.addError(e, s);
      }
    }
  }

  fetchMatches();

  // Listen to realtime changes on matches table
  final channel = supabase.channel('public:matches');
  channel.onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'matches',
    callback: (payload) {
      fetchMatches();
    },
  ).subscribe();

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
});

class MatchService {
  final SupabaseClient _supabase;
  MatchService(this._supabase);

  Future<void> createChallenge({
    required String opponentId,
    required String sport,
    required String courtId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('matches').insert({
      'challenger_id': user.id,
      'opponent_id': opponentId,
      'sport': sport,
      'court_id': courtId,
      'status': 'pending',
      'challenger_accepted': true,
      'opponent_accepted': false,
    });
  }

  Future<void> acceptChallenge(String matchId) async {
    await _supabase.from('matches').update({
      'opponent_accepted': true,
      'status': 'accepted',
    }).eq('id', matchId);
  }

  Future<void> rejectChallenge(String matchId) async {
    await _supabase.from('matches').update({
      'status': 'disputed', // custom or rejected state
    }).eq('id', matchId);
  }

  Future<void> logScore({
    required String matchId,
    required String score,
    required String resultForChallenger,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('matches').update({
      'score': score,
      'result_for_challenger': resultForChallenger,
      'status': 'to_verify',
      'logged_by': user.id,
    }).eq('id', matchId);
  }

  Future<void> verifyMatch(String matchId) async {
    await _supabase.from('matches').update({
      'verified': true,
      'status': 'verified',
    }).eq('id', matchId);
  }

  Future<void> disputeMatch(String matchId, String reason) async {
    await _supabase.from('matches').update({
      'disputed': true,
      'dispute_reason': reason,
      'status': 'disputed',
    }).eq('id', matchId);
  }
}

final matchServiceProvider = Provider<MatchService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return MatchService(supabase);
});
