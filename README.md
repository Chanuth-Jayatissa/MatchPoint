# MatchPoint

MatchPoint is a Flutter mobile app for finding nearby players, challenging matches, selecting courts, and managing social sports interactions. The app combines Supabase auth, map-based discovery, player profiles, match flows, messaging, and a social feed into one mobile experience.

## Features

- Supabase authentication with a local dev fallback when credentials are not configured.
- Map-based player discovery using play zones and court markers.
- Player detail sheets, sport filters, and available-now filtering.
- Challenge flow that moves from player selection to court selection.
- Matches, social, messages, and profile screens.
- Custom mobile UI theme, tab navigation, cards, modals, and app assets.

## Tech Stack

- Flutter and Dart
- Supabase Flutter
- Google Maps Flutter and Geolocator
- Flutter Riverpod
- flutter_dotenv
- Custom Android and iOS app assets

## Project Structure

- lib/main.dart - app initialization, Supabase setup, auth gate, and tab shell
- lib/screens - home, matches, social, messages, profile, and auth screens
- lib/widgets - cards, detail sheets, filters, modals, and custom tab bar
- lib/models - player, match, court, post, thread, and play zone models
- lib/services/auth_service.dart - auth service layer
- supabase/migration.sql - database migration

## Getting Started

Install Flutter dependencies:

~~~bash
flutter pub get
~~~

Create a .env file if you want Supabase and Maps integrations enabled:

~~~bash
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GOOGLE_MAPS_API_KEY=your_google_maps_key
~~~

Run the app:

~~~bash
flutter run
~~~

If Supabase or Maps are not configured, the app still opens in development mode with fallback UI/data.

## Status

Active portfolio project. The current version is the main Flutter rewrite; MatchPointOld contains an earlier Expo prototype.
