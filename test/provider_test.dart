import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match_point/providers/supabase_provider.dart';
import 'package:match_point/providers/player_provider.dart';

// Mocks for Supabase Client chain
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class FakePostgrestFilterBuilder extends Fake implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _listValue;
  final Map<String, dynamic>? _singleValue;

  FakePostgrestFilterBuilder(this._listValue, [this._singleValue]);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, Object value) => this;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() {
    return FakePostgrestTransformBuilder<Map<String, dynamic>?>(_singleValue);
  }

  @override
  Future<U> then<U>(
      FutureOr<U> Function(List<Map<String, dynamic>>) onValue, {Function? onError}) {
    return Future.value(_listValue).then(onValue, onError: onError);
  }
}

class FakePostgrestTransformBuilder<T> extends Fake implements PostgrestTransformBuilder<T> {
  final T value;
  FakePostgrestTransformBuilder(this.value);

  @override
  Future<U> then<U>(FutureOr<U> Function(T) onValue, {Function? onError}) {
    return Future.value(value).then(onValue, onError: onError);
  }
}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late MockSupabaseQueryBuilder mockQueryBuilder;

  setUpAll(() {
    registerFallbackValue(const Stream<List<Map<String, dynamic>>>.empty());
  });

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();
    mockQueryBuilder = MockSupabaseQueryBuilder();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
  });

  group('currentPlayerProvider Tests', () {
    test('returns null when no authenticated user', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(mockSupabase),
        ],
      );
      addTearDown(container.dispose);

      final player = await container.read(currentPlayerProvider.future);
      expect(player, isNull);
    });

    test('fetches profile successfully when authenticated', () async {
      when(() => mockUser.id).thenReturn('u1');
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockSupabase.from('profiles')).thenAnswer((_) => mockQueryBuilder);

      final profileData = {
        'id': 'u1',
        'username': 'test_player',
        'sports': ['Tennis'],
        'respect_score': 90,
      };
      final fakeBuilder = FakePostgrestFilterBuilder([], profileData);

      when(() => mockQueryBuilder.select('*, sport_ratings(*)')).thenAnswer((_) => fakeBuilder);

      final container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(mockSupabase),
        ],
      );
      addTearDown(container.dispose);

      final player = await container.read(currentPlayerProvider.future);
      expect(player, isNotNull);
      expect(player!.username, 'test_player');
      expect(player.respectScore, 90);
    });
  });
}
