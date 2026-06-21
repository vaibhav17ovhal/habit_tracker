import 'package:flutter/material.dart';

import '../models/reward.dart';
import 'habits_provider.dart';

class RewardsProvider extends ChangeNotifier {
  List<RewardBadge> badgesFor(HabitsProvider habitsProvider) {
    final maxStreak = habitsProvider.maxStreak;

    return [
      RewardBadge(
        id: 'streak_7',
        title: '7-Day Streak',
        description: 'Complete habits for 7 days straight',
        emoji: '🔥',
        requiredStreak: 7,
        isUnlocked: maxStreak >= 7,
      ),
      RewardBadge(
        id: 'streak_30',
        title: '30-Day Streak',
        description: 'Complete habits for 30 days straight',
        emoji: '🏆',
        requiredStreak: 30,
        isUnlocked: maxStreak >= 30,
      ),
      RewardBadge(
        id: 'streak_100',
        title: '100-Day Streak',
        description: 'Complete habits for 100 days straight',
        emoji: '🌟',
        requiredStreak: 100,
        isUnlocked: maxStreak >= 100,
      ),
    ];
  }

  int unlockedCount(HabitsProvider habitsProvider) =>
      badgesFor(habitsProvider).where((b) => b.isUnlocked).length;
}
