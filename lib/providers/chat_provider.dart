import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/thread.dart';
import 'supabase_provider.dart';

final chatThreadsStreamProvider = StreamProvider<List<Thread>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return Stream.value([]);

  final controller = StreamController<List<Thread>>();

  Future<void> fetchThreads() async {
    try {
      final response = await supabase
          .from('chat_threads')
          .select('''
            *,
            player1:profiles!player1_id(username, avatar_url),
            player2:profiles!player2_id(username, avatar_url)
          ''')
          .or('player1_id.eq.${user.id},player2_id.eq.${user.id}')
          .order('last_message_time', ascending: false);

      final threads = (response as List).map((json) {
        final player1 = json['player1'] as Map<String, dynamic>?;
        final player2 = json['player2'] as Map<String, dynamic>?;
        
        final map = Map<String, dynamic>.from(json);
        final isPlayer1 = json['player1_id'] == user.id;
        
        final otherPlayer = isPlayer1 ? player2 : player1;
        map['other_player_username'] = otherPlayer?['username'];
        map['other_player_avatar_url'] = otherPlayer?['avatar_url'];
        
        map['is_unread'] = false; // can link to thread_reads table
        
        return Thread.fromJson(map);
      }).toList();

      if (!controller.isClosed) {
        controller.add(threads);
      }
    } catch (e, s) {
      if (!controller.isClosed) {
        controller.addError(e, s);
      }
    }
  }

  fetchThreads();

  final channel = supabase.channel('public:chat_threads');
  channel.onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'chat_threads',
    callback: (payload) {
      fetchThreads();
    },
  ).subscribe();

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
});

final messagesStreamProvider = StreamProvider.family<List<Message>, String>((ref, threadId) {
  final supabase = ref.watch(supabaseClientProvider);
  final controller = StreamController<List<Message>>();

  Future<void> fetchMessages() async {
    try {
      final response = await supabase
          .from('messages')
          .select('*')
          .eq('thread_id', threadId)
          .order('created_at', ascending: true);

      final messages = (response as List).map((json) => Message.fromJson(json)).toList();

      if (!controller.isClosed) {
        controller.add(messages);
      }
    } catch (e, s) {
      if (!controller.isClosed) {
        controller.addError(e, s);
      }
    }
  }

  fetchMessages();

  final channel = supabase.channel('public:messages:$threadId');
  channel.onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'messages',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'thread_id',
      value: threadId,
    ),
    callback: (payload) {
      fetchMessages();
    },
  ).subscribe();

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
});

class ChatService {
  final SupabaseClient _supabase;
  ChatService(this._supabase);

  Future<void> sendMessage({
    required String threadId,
    required String content,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('messages').insert({
      'thread_id': threadId,
      'sender_id': user.id,
      'content': content,
    });

    // Update last_message_text & last_message_time on thread
    await _supabase.from('chat_threads').update({
      'last_message_text': content,
      'last_message_time': DateTime.now().toIso8601String(),
    }).eq('id', threadId);
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ChatService(supabase);
});
