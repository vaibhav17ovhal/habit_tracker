import 'package:flutter/material.dart';

import '../models/leaderboard_entry.dart';
import 'gamification_provider.dart';
import 'habits_provider.dart';
import 'progress_provider.dart';
import 'rewards_provider.dart';
import 'user_provider.dart';

class LeaderboardProvider extends ChangeNotifier {
  static const _mockPlayers = [
    ('Ava Chen', '🔥', 920),
    ('Ryan Patel', '⚡', 845),
    ('Sophia Lee', '🌟', 790),
    ('Marcus Kim', '💪', 710),
    ('Emma Wilson', '🎯', 660),
    ('Noah Davis', '🏆', 620),
    ('Lily Brown', '✨', 580),
    ('Ethan Moore', '🚀', 540),
  ];

  List<LeaderboardEntry> buildLeaderboard({
    required UserProvider user,
    required HabitsProvider habits,
    required ProgressProvider progress,
    required RewardsProvider rewards,
    required GamificationProvider gamification,
  }) {
    final stats = gamification.statsFor(
      habits: habits,
      progress: progress,
      rewards: rewards,
    );

    final entries = <LeaderboardEntry>[
      for (final player in _mockPlayers)
        LeaderboardEntry(
          rank: 0,
          name: player.$1,
          score: player.$3,
          avatarEmoji: player.$2,
        ),
      LeaderboardEntry(
        rank: 0,
        name: user.displayName,
        score: stats.xp,
        avatarEmoji: '🦸',
        isCurrentUser: true,
      ),
    ]..sort((a, b) => b.score.compareTo(a.score));

    return [
      for (var i = 0; i < entries.length; i++)
        entries[i].copyWith(rank: i + 1),
    ];
  }

  LeaderboardEntry? currentUserEntry(List<LeaderboardEntry> board) {
    for (final entry in board) {
      if (entry.isCurrentUser) return entry;
    }
    return null;
  }
}
