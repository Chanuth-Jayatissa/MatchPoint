import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration — reads from .env file.
/// Uses the new Supabase API key system (publishable + secret keys).
class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';

  /// Publishable key (sb_publishable_...) — safe for client-side use.
  /// Replaces the legacy 'anon' key. Respects Row Level Security.
  static String get publishableKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Returns true if Supabase credentials are configured (not placeholders).
  static bool get isConfigured =>
      url.isNotEmpty &&
      url != 'YOUR_URL_HERE' &&
      publishableKey.isNotEmpty &&
      publishableKey != 'YOUR_KEY_HERE';

  /// Returns true if Google Maps API key is configured.
  static bool get isMapsConfigured =>
      googleMapsApiKey.isNotEmpty &&
      googleMapsApiKey != 'YOUR_KEY_HERE';
}
