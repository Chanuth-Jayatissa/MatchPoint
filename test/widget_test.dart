import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:match_point/main.dart';
import 'package:match_point/providers/supabase_provider.dart';
import 'package:match_point/providers/court_provider.dart';
import 'package:match_point/providers/match_provider.dart';
import 'package:match_point/providers/post_provider.dart';
import 'package:match_point/providers/chat_provider.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    dotenv.testLoad(fileInput: '');

    final mockSupabase = MockSupabaseClient();
    final mockAuth = MockGoTrueClient();
    final mockUser = MockUser();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(mockSupabase),
          courtsProvider.overrideWith((ref) async => []),
          playZonesProvider.overrideWith((ref) async => []),
          matchesStreamProvider.overrideWith((ref) => Stream.value([])),
          postsStreamProvider.overrideWith((ref) => Stream.value([])),
          chatThreadsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MatchPointApp(),
      ),
    );

    expect(find.text('Find Players Nearby'), findsOneWidget);
  });
}
