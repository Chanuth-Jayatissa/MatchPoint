import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';
import 'supabase_provider.dart';

final postsStreamProvider = StreamProvider<List<Post>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  final controller = StreamController<List<Post>>();

  Future<void> fetchPosts() async {
    try {
      final response = await supabase
          .from('posts')
          .select('''
            *,
            author:profiles!author_id(username, avatar_url),
            post_likes(user_id)
          ''')
          .order('created_at', ascending: false);

      final posts = (response as List).map((json) {
        final author = json['author'] as Map<String, dynamic>?;
        final likes = json['post_likes'] as List? ?? [];
        
        final map = Map<String, dynamic>.from(json);
        map['author_username'] = author?['username'];
        map['author_avatar_url'] = author?['avatar_url'];
        map['likes_count'] = likes.length;
        map['is_liked'] = likes.any((like) => like['user_id'] == user?.id);

        return Post.fromJson(map);
      }).toList();

      if (!controller.isClosed) {
        controller.add(posts);
      }
    } catch (e, s) {
      if (!controller.isClosed) {
        controller.addError(e, s);
      }
    }
  }

  fetchPosts();

  final channel = supabase.channel('public:posts');
  channel.onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'posts',
    callback: (payload) {
      fetchPosts();
    },
  ).subscribe();

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
});

class PostService {
  final SupabaseClient _supabase;
  PostService(this._supabase);

  Future<void> createPost({
    required String sport,
    required String content,
    String? imageUrl,
    required String tag,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('posts').insert({
      'author_id': user.id,
      'sport': sport,
      'content': content,
      'image_url': imageUrl,
      'tag': tag,
    });
  }

  Future<void> toggleLike(String postId, bool currentlyLiked) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    if (currentlyLiked) {
      await _supabase
          .from('post_likes')
          .delete()
          .match({'user_id': user.id, 'post_id': postId});
    } else {
      await _supabase.from('post_likes').insert({
        'user_id': user.id,
        'post_id': postId,
      });
    }
  }

  Future<void> addComment(String postId, String content) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('post_comments').insert({
      'post_id': postId,
      'author_id': user.id,
      'content': content,
    });
  }
}

final postServiceProvider = Provider<PostService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return PostService(supabase);
});
