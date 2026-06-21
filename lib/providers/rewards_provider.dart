import 'package:flutter/material.dart';

import 'package:Demo/models/reward.dart';
import 'package:Demo/providers/habits_provider.dart';

class RewardsProvider extends ChangeNotifier {
  List<RewardBadge> goodHabitBadgesFor(HabitsProvider habitsProvider) {
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

  List<RewardBadge> badHabitBadgesFor(HabitsProvider habitsProvider) {
    final days = habitsProvider.maxBadHabitDaysOnTarget;

    return [
      RewardBadge(
        id: 'bad_1_day',
        title: '1 Day On Target',
        description: 'Stay at or below your goal for one day',
        emoji: '🚭',
        requiredStreak: 1,
        isUnlocked: days >= 1,
      ),
      RewardBadge(
        id: 'bad_1_week',
        title: '1 Week On Target',
        description: 'Seven consecutive days meeting your goal',
        emoji: '🌟',
        requiredStreak: 7,
        isUnlocked: days >= 7,
      ),
      RewardBadge(
        id: 'bad_1_month',
        title: '1 Month On Target',
        description: 'Thirty consecutive days meeting your goal',
        emoji: '🏆',
        requiredStreak: 30,
        isUnlocked: days >= 30,
      ),
    ];
  }

  List<RewardBadge> badgesFor(HabitsProvider habitsProvider) => [
        ...goodHabitBadgesFor(habitsProvider),
        ...badHabitBadgesFor(habitsProvider),
      ];

  int unlockedCount(HabitsProvider habitsProvider) =>
      badgesFor(habitsProvider).where((b) => b.isUnlocked).length;
}
