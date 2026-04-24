import 'package:supabase_flutter/supabase_flutter.dart';

/// Service handling all authentication operations with Supabase.
class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Get the current logged-in user, or null.
  static User? get currentUser => _client.auth.currentUser;

  /// Get the current user's ID, or null.
  static String? get currentUserId => currentUser?.id;

  /// Whether a user is currently logged in.
  static bool get isLoggedIn => currentUser != null;

  /// Stream of auth state changes.
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  /// Sign up with email, password, and metadata.
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    List<String> sports = const [],
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'avatar_url': null,
        'sports': sports,
      },
    );

    return response;
  }

  /// Sign in with email and password.
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google OAuth.
  static Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.matchpoint.matchpoint://login-callback',
    );
  }

  /// Sign in with Apple.
  static Future<bool> signInWithApple() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'com.matchpoint.matchpoint://login-callback',
    );
  }

  /// Sign out the current user.
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Check if a username is available.
  static Future<bool> isUsernameAvailable(String username) async {
    final result = await _client
        .from('profiles')
        .select('id')
        .eq('username', username)
        .maybeSingle();
    return result == null;
  }

  /// Get the current user's profile data.
  static Future<Map<String, dynamic>?> getCurrentProfile() async {
    if (currentUserId == null) return null;
    return await _client
        .from('profiles')
        .select('*, sport_ratings(*)')
        .eq('id', currentUserId!)
        .maybeSingle();
  }

  /// Update the current user's profile.
  static Future<void> updateProfile(Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    await _client
        .from('profiles')
        .update(data)
        .eq('id', currentUserId!);
  }

  /// Delete the current user's account.
  static Future<void> deleteAccount() async {
    if (currentUserId == null) return;
    // Profile will cascade delete via foreign key
    await _client.from('profiles').delete().eq('id', currentUserId!);
    await signOut();
  }
}
