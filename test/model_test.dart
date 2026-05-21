import 'package:flutter_test/flutter_test.dart';
import 'package:match_point/models/player.dart';
import 'package:match_point/models/court.dart';
import 'package:match_point/models/match_model.dart';
import 'package:match_point/models/post.dart';
import 'package:match_point/models/thread.dart';

void main() {
  group('Player Model Tests', () {
    test('fromJson parses player correctly with full data', () {
      final json = {
        'id': 'p1',
        'username': 'tennis_ace',
        'avatar_url': 'https://example.com/avatar.jpg',
        'sports': ['Tennis', 'Squash'],
        'latitude': 40.7128,
        'longitude': -74.0060,
        'location_text': 'New York, NY',
        'available_now': true,
        'respect_score': 95,
        'hide_from_map': false,
        'sport_ratings': [
          {'sport': 'Tennis', 'rating': 1500, 'trend': 'up'}
        ]
      };

      final player = Player.fromJson(json);

      expect(player.id, 'p1');
      expect(player.username, 'tennis_ace');
      expect(player.avatarUrl, 'https://example.com/avatar.jpg');
      expect(player.sports, containsAll(['Tennis', 'Squash']));
      expect(player.latitude, 40.7128);
      expect(player.longitude, -74.0060);
      expect(player.locationText, 'New York, NY');
      expect(player.availableNow, isTrue);
      expect(player.respectScore, 95);
      expect(player.sportRatings.length, 1);
      expect(player.sportRatings[0].sport, 'Tennis');
      expect(player.sportRatings[0].rating, 1500);
      expect(player.sportRatings[0].trend, 'up');
    });

    test('toJson serializes correctly', () {
      const player = Player(
        id: 'p1',
        username: 'tennis_ace',
        avatarUrl: 'https://example.com/avatar.jpg',
        sports: ['Tennis'],
        latitude: 40.7128,
        longitude: -74.0060,
        locationText: 'New York, NY',
        availableNow: true,
        respectScore: 95,
        hideFromMap: false,
      );

      final json = player.toJson();

      expect(json['id'], 'p1');
      expect(json['username'], 'tennis_ace');
      expect(json['avatar_url'], 'https://example.com/avatar.jpg');
      expect(json['sports'], ['Tennis']);
      expect(json['latitude'], 40.7128);
      expect(json['longitude'], -74.0060);
      expect(json['location_text'], 'New York, NY');
      expect(json['available_now'], isTrue);
      expect(json['respect_score'], 95);
      expect(json['hide_from_map'], isFalse);
    });
  });

  group('Court Model Tests', () {
    test('fromJson parses court correctly', () {
      final json = {
        'id': 'c1',
        'name': 'Central Tennis Court',
        'sports': ['Tennis'],
        'location_name': 'Central Park',
        'image_url': 'https://example.com/court.jpg',
        'latitude': 40.7829,
        'longitude': -73.9654,
        'zone_id': 'z1'
      };

      final court = Court.fromJson(json);

      expect(court.id, 'c1');
      expect(court.name, 'Central Tennis Court');
      expect(court.sports, ['Tennis']);
      expect(court.locationName, 'Central Park');
      expect(court.imageUrl, 'https://example.com/court.jpg');
      expect(court.latitude, 40.7829);
      expect(court.longitude, -73.9654);
      expect(court.zoneId, 'z1');
    });
  });

  group('MatchModel Tests', () {
    test('fromJson parses match correctly', () {
      final json = {
        'id': 'm1',
        'challenger_id': 'p1',
        'opponent_id': 'p2',
        'challenger_username': 'player_one',
        'opponent_username': 'player_two',
        'sport': 'Squash',
        'status': 'accepted',
        'challenger_accepted': true,
        'opponent_accepted': true,
        'created_at': '2026-05-21T18:00:00.000Z',
        'updated_at': '2026-05-21T18:05:00.000Z'
      };

      final match = MatchModel.fromJson(json);

      expect(match.id, 'm1');
      expect(match.challengerId, 'p1');
      expect(match.opponentId, 'p2');
      expect(match.sport, 'Squash');
      expect(match.status, MatchStatus.accepted);
      expect(match.challengerAccepted, isTrue);
      expect(match.opponentAccepted, isTrue);
    });
  });

  group('Post Model Tests', () {
    test('fromJson parses post correctly', () {
      final json = {
        'id': 'post1',
        'author_id': 'p1',
        'author_username': 'tennis_ace',
        'sport': 'Tennis',
        'content': 'Need a hitting partner today!',
        'likes_count': 5,
        'created_at': '2026-05-21T18:00:00.000Z'
      };

      final post = Post.fromJson(json);

      expect(post.id, 'post1');
      expect(post.authorId, 'p1');
      expect(post.sport, 'Tennis');
      expect(post.content, 'Need a hitting partner today!');
      expect(post.likesCount, 5);
    });
  });

  group('Thread and Message Model Tests', () {
    test('fromJson parses thread correctly', () {
      final json = {
        'id': 't1',
        'match_id': 'm1',
        'player1_id': 'p1',
        'player2_id': 'p2',
        'other_player_username': 'player_two',
        'created_at': '2026-05-21T18:00:00.000Z'
      };

      final thread = Thread.fromJson(json);

      expect(thread.id, 't1');
      expect(thread.matchId, 'm1');
      expect(thread.player1Id, 'p1');
      expect(thread.player2Id, 'p2');
      expect(thread.otherPlayerUsername, 'player_two');
    });

    test('fromJson parses message correctly', () {
      final json = {
        'id': 'msg1',
        'thread_id': 't1',
        'sender_id': 'p1',
        'content': 'Let’s play at 5 PM!',
        'created_at': '2026-05-21T18:05:00.000Z'
      };

      final msg = Message.fromJson(json);

      expect(msg.id, 'msg1');
      expect(msg.threadId, 't1');
      expect(msg.senderId, 'p1');
      expect(msg.content, 'Let’s play at 5 PM!');
    });
  });
}
