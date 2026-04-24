import '../models/player.dart';
import '../models/play_zone.dart';
import '../models/court.dart';
import '../models/match_model.dart';
import '../models/post.dart';
import '../models/thread.dart';

/// Centralized mock data matching the original React Native prototype.
/// This will be replaced by Supabase queries in later phases.
class MockData {
  // ──── Players ────
  static const List<Player> players = [
    Player(
      id: '1',
      username: 'PickleballAce_23',
      avatarUrl:
          'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
      sports: ['Pickleball', 'Badminton'],
      availableNow: true,
      respectScore: 92,
      locationText: 'Downtown Courts',
      lastActive: '2 min ago',
      sportRatings: [
        SportRating(sport: 'Pickleball', rating: 1850, trend: 'up'),
        SportRating(sport: 'Badminton', rating: 1720, trend: 'stable'),
      ],
      recentMatchHistory: [
        RecentMatchResult(
            date: '12/15',
            sport: 'Pickleball',
            opponent: 'CourtCrusher',
            result: 'Win'),
        RecentMatchResult(
            date: '12/12',
            sport: 'Badminton',
            opponent: 'NetNinja',
            result: 'Loss'),
        RecentMatchResult(
            date: '12/08',
            sport: 'Pickleball',
            opponent: 'SmashMaster',
            result: 'Win'),
      ],
    ),
    Player(
      id: '2',
      username: 'BadmintonPro',
      avatarUrl:
          'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
      sports: ['Badminton'],
      availableNow: false,
      respectScore: 88,
      locationText: 'University Gym',
      lastActive: '15 min ago',
      sportRatings: [
        SportRating(sport: 'Badminton', rating: 1650, trend: 'stable'),
      ],
      recentMatchHistory: [
        RecentMatchResult(
            date: '12/14',
            sport: 'Badminton',
            opponent: 'ShuttleKing',
            result: 'Win'),
        RecentMatchResult(
            date: '12/11',
            sport: 'Badminton',
            opponent: 'NetMaster',
            result: 'Win'),
        RecentMatchResult(
            date: '12/09',
            sport: 'Badminton',
            opponent: 'CourtAce',
            result: 'Loss'),
      ],
    ),
    Player(
      id: '3',
      username: 'PingPongKing',
      avatarUrl:
          'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
      sports: ['Table Tennis', 'Pickleball'],
      availableNow: false,
      respectScore: 95,
      locationText: 'Community Center',
      lastActive: '2 hours ago',
      sportRatings: [
        SportRating(sport: 'Table Tennis', rating: 1720, trend: 'up'),
        SportRating(sport: 'Pickleball', rating: 1550, trend: 'stable'),
      ],
      recentMatchHistory: [
        RecentMatchResult(
            date: '12/13',
            sport: 'Table Tennis',
            opponent: 'SpinMaster',
            result: 'Win'),
        RecentMatchResult(
            date: '12/10',
            sport: 'Pickleball',
            opponent: 'PaddleAce',
            result: 'Loss'),
        RecentMatchResult(
            date: '12/07',
            sport: 'Table Tennis',
            opponent: 'LoopKing',
            result: 'Win'),
      ],
    ),
    Player(
      id: '4',
      username: 'CourtCrusher',
      avatarUrl:
          'https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
      sports: ['Pickleball'],
      availableNow: true,
      respectScore: 96,
      locationText: 'Downtown Courts',
      lastActive: 'Just now',
      sportRatings: [
        SportRating(sport: 'Pickleball', rating: 1920, trend: 'up'),
      ],
      recentMatchHistory: [
        RecentMatchResult(
            date: '12/15',
            sport: 'Pickleball',
            opponent: 'PickleballAce_23',
            result: 'Loss'),
        RecentMatchResult(
            date: '12/13',
            sport: 'Pickleball',
            opponent: 'NetCrusher',
            result: 'Win'),
        RecentMatchResult(
            date: '12/11',
            sport: 'Pickleball',
            opponent: 'PaddlePro',
            result: 'Win'),
      ],
    ),
  ];

  // ──── Play Zones ────
  static List<PlayZone> playZones = [
    PlayZone(
      id: '1',
      name: 'Downtown Sports Complex',
      latitude: 40.7128,
      longitude: -74.0060,
      players: [players[0], players[3]],
      isUserZone: true,
    ),
    PlayZone(
      id: '2',
      name: 'University Recreation Center',
      latitude: 40.7589,
      longitude: -73.9851,
      players: [players[1]],
    ),
    PlayZone(
      id: '3',
      name: 'Community Sports Hub',
      latitude: 40.6892,
      longitude: -74.0445,
      players: [players[2]],
    ),
  ];

  // ──── Courts ────
  static const List<Court> courts = [
    Court(
      id: '1',
      name: 'Downtown Pickleball Court #1',
      sports: ['Pickleball'],
      locationName: 'Downtown Sports Complex',
      imageUrl:
          'https://images.pexels.com/photos/209977/pexels-photo-209977.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop',
      latitude: 40.7128,
      longitude: -74.0060,
    ),
    Court(
      id: '2',
      name: 'University Badminton Hall',
      sports: ['Badminton'],
      locationName: 'University Recreation Center',
      imageUrl:
          'https://images.pexels.com/photos/1263348/pexels-photo-1263348.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop',
      latitude: 40.7589,
      longitude: -73.9851,
    ),
    Court(
      id: '3',
      name: 'Community Ping Pong Room',
      sports: ['Table Tennis'],
      locationName: 'Community Sports Hub',
      imageUrl:
          'https://images.pexels.com/photos/274422/pexels-photo-274422.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop',
      latitude: 40.6892,
      longitude: -74.0445,
    ),
    Court(
      id: '4',
      name: 'Elite Pickleball Academy Court A',
      sports: ['Pickleball'],
      locationName: 'Downtown Sports Complex',
      imageUrl:
          'https://images.pexels.com/photos/1263349/pexels-photo-1263349.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop',
      latitude: 40.7130,
      longitude: -74.0058,
    ),
    Court(
      id: '5',
      name: 'Recreation Center Multi-Court',
      sports: ['Badminton', 'Table Tennis'],
      locationName: 'University Recreation Center',
      imageUrl:
          'https://images.pexels.com/photos/863988/pexels-photo-863988.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop',
      latitude: 40.7591,
      longitude: -73.9849,
    ),
  ];

  // ──── Mock Matches ────
  static List<MatchModel> matches = [
    MatchModel(
      id: '1',
      challengerId: '1',
      opponentId: 'current_user',
      challengerUsername: 'PickleballAce_23',
      opponentUsername: 'You',
      challengerAvatarUrl: players[0].avatarUrl,
      sport: 'Pickleball',
      courtId: '1',
      courtName: 'Downtown Pickleball Court #1',
      courtLocation: 'Downtown Sports Complex',
      status: MatchStatus.pending,
      challengerAccepted: true,
      opponentAccepted: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    MatchModel(
      id: '4',
      challengerId: 'current_user',
      opponentId: '3',
      challengerUsername: 'You',
      opponentUsername: 'PingPongKing',
      opponentAvatarUrl: players[2].avatarUrl,
      sport: 'Table Tennis',
      courtId: '3',
      courtName: 'Community Ping Pong Room',
      courtLocation: 'Community Sports Hub',
      status: MatchStatus.toLog,
      challengerAccepted: true,
      opponentAccepted: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MatchModel(
      id: '5',
      challengerId: 'current_user',
      opponentId: '2',
      challengerUsername: 'You',
      opponentUsername: 'NetNinja',
      opponentAvatarUrl: players[1].avatarUrl,
      sport: 'Badminton',
      courtId: '5',
      courtName: 'Recreation Center Multi-Court',
      courtLocation: 'University Recreation Center',
      status: MatchStatus.toVerify,
      challengerAccepted: true,
      opponentAccepted: true,
      score: '21-17, 19-21, 21-15',
      resultForChallenger: 'win',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MatchModel(
      id: '6',
      challengerId: 'current_user',
      opponentId: '2',
      challengerUsername: 'You',
      opponentUsername: 'SmashMaster',
      opponentAvatarUrl: players[1].avatarUrl,
      sport: 'Pickleball',
      courtId: '1',
      courtName: 'Downtown Pickleball Court #1',
      courtLocation: 'Downtown Sports Complex',
      status: MatchStatus.disputed,
      challengerAccepted: true,
      opponentAccepted: true,
      score: '11-9, 8-11, 11-7',
      resultForChallenger: 'win',
      disputed: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // ──── Mock Posts ────
  static List<Post> posts = [
    Post(
      id: '1',
      authorId: '1',
      authorUsername: 'PickleballAce_23',
      authorAvatarUrl: players[0].avatarUrl,
      sport: 'Pickleball',
      content:
          'Just hit my first perfect serve ace! Been working on my technique for months. The key is really in the wrist snap and follow-through. Anyone else struggling with serves?',
      imageUrl:
          'https://images.pexels.com/photos/209977/pexels-photo-209977.jpeg?auto=compress&cs=tinysrgb&w=400&h=300&fit=crop',
      tag: 'highlight',
      likesCount: 24,
      commentsCount: 8,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Post(
      id: '2',
      authorId: '2',
      authorUsername: 'BadmintonPro',
      authorAvatarUrl: players[1].avatarUrl,
      sport: 'Badminton',
      content:
          'Quick question - what\'s the best way to improve footwork for better court coverage? I feel like I\'m always a step behind my opponents.',
      tag: 'question',
      likesCount: 12,
      commentsCount: 15,
      isLiked: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Post(
      id: '3',
      authorId: '3',
      authorUsername: 'PingPongKing',
      authorAvatarUrl: players[2].avatarUrl,
      sport: 'Table Tennis',
      content:
          'Finally mastered the perfect backhand loop! It took weeks of practice but the consistency is paying off in matches. Practice makes perfect!',
      tag: 'highlight',
      likesCount: 31,
      commentsCount: 6,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // ──── Mock Threads ────
  static List<Thread> threads = [
    Thread(
      id: '1',
      matchId: '1',
      player1Id: '1',
      player2Id: 'current_user',
      otherPlayerUsername: 'PickleballAce_23',
      otherPlayerAvatarUrl: players[0].avatarUrl,
      lastMessageText: 'Great match! Looking forward to the rematch.',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
      isUnread: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Thread(
      id: '2',
      matchId: '2',
      player1Id: '2',
      player2Id: 'current_user',
      otherPlayerUsername: 'BadmintonPro',
      otherPlayerAvatarUrl: players[1].avatarUrl,
      lastMessageText: 'Thanks for the tips on footwork!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      isUnread: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Thread(
      id: '3',
      matchId: '3',
      player1Id: '3',
      player2Id: 'current_user',
      otherPlayerUsername: 'PingPongKing',
      otherPlayerAvatarUrl: players[2].avatarUrl,
      lastMessageText: 'Let\'s play again soon!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      isUnread: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static List<Message> getMessagesForThread(String threadId) {
    switch (threadId) {
      case '1':
        return [
          Message(id: '1', threadId: '1', senderId: '1', content: 'Hey! Ready for our match?', createdAt: DateTime(2024, 12, 15, 10, 30)),
          Message(id: '2', threadId: '1', senderId: 'current_user', content: 'Absolutely! See you at Downtown Pickleball Court #1', createdAt: DateTime(2024, 12, 15, 10, 32)),
          Message(id: '3', threadId: '1', senderId: '1', content: 'Perfect, I\'ll be there 15 minutes early to warm up', createdAt: DateTime(2024, 12, 15, 10, 35)),
          Message(id: '4', threadId: '1', senderId: 'current_user', content: 'Sounds good! Bring your A-game 😄', createdAt: DateTime(2024, 12, 15, 10, 36)),
          Message(id: '5', threadId: '1', senderId: '1', content: 'Great match! Looking forward to the rematch.', createdAt: DateTime(2024, 12, 15, 14, 15)),
        ];
      case '2':
        return [
          Message(id: '1', threadId: '2', senderId: '2', content: 'Hi! I saw your post about footwork tips', createdAt: DateTime(2024, 12, 15, 9, 15)),
          Message(id: '2', threadId: '2', senderId: 'current_user', content: 'Sure! The key is to stay on your toes and use small, quick steps', createdAt: DateTime(2024, 12, 15, 9, 20)),
          Message(id: '3', threadId: '2', senderId: 'current_user', content: 'Also, practice the split step timing', createdAt: DateTime(2024, 12, 15, 9, 21)),
          Message(id: '4', threadId: '2', senderId: '2', content: 'Thanks for the tips on footwork!', createdAt: DateTime(2024, 12, 15, 9, 45)),
        ];
      case '3':
        return [
          Message(id: '1', threadId: '3', senderId: 'current_user', content: 'GG! That backhand loop was incredible', createdAt: DateTime(2024, 12, 13, 15, 30)),
          Message(id: '2', threadId: '3', senderId: '3', content: 'Thanks! You really pushed me to play better', createdAt: DateTime(2024, 12, 13, 15, 32)),
          Message(id: '3', threadId: '3', senderId: '3', content: 'Let\'s play again soon!', createdAt: DateTime(2024, 12, 13, 15, 35)),
        ];
      default:
        return [];
    }
  }
}
