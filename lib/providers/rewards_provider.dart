import 'package:flutter/material.dart';

import '../models/reward.dart';
import 'habits_provider.dart';

class RewardsProvider extends ChangeNotifier {
  List<RewardBadge> badgesFor(HabitsProvider habitsProvider) {
    final maxStreak = habitsProvider.maxStreak;
    final completedToday = habitsProvider.completedCount;
    final total = habitsProvider.totalCount;
    final allDoneToday = total > 0 && completedToday == total;

    return [
      RewardBadge(
        id: 'first_habit',
        title: 'First Step',
        description: 'Create your first habit',
        icon: Icons.flag_rounded,
        requiredStreak: 0,
        isUnlocked: total >= 1,
      ),
      RewardBadge(
        id: 'perfect_day',
        title: 'Perfect Day',
        description: 'Complete all habits in one day',
        icon: Icons.star_rounded,
        requiredStreak: 0,
        isUnlocked: allDoneToday,
      ),
      RewardBadge(
        id: 'streak_7',
        title: '7-Day Streak',
        description: 'Maintain a 7-day streak',
        icon: Icons.local_fire_department_rounded,
        requiredStreak: 7,
        isUnlocked: maxStreak >= 7,
      ),
      RewardBadge(
        id: 'streak_14',
        title: '14-Day Streak',
        description: 'Maintain a 14-day streak',
        icon: Icons.whatshot_rounded,
        requiredStreak: 14,
        isUnlocked: maxStreak >= 14,
      ),
      RewardBadge(
        id: 'streak_30',
        title: '30-Day Streak',
        description: 'Maintain a 30-day streak',
        icon: Icons.emoji_events_rounded,
        requiredStreak: 30,
        isUnlocked: maxStreak >= 30,
      ),
      RewardBadge(
        id: 'streak_60',
        title: '60-Day Streak',
        description: 'Maintain a 60-day streak',
        icon: Icons.military_tech_rounded,
        requiredStreak: 60,
        isUnlocked: maxStreak >= 60,
      ),
      RewardBadge(
        id: 'streak_100',
        title: '100-Day Streak',
        description: 'Maintain a 100-day streak',
        icon: Icons.diamond_rounded,
        requiredStreak: 100,
        isUnlocked: maxStreak >= 100,
      ),
    ];
  }

  int unlockedCount(HabitsProvider habitsProvider) =>
      badgesFor(habitsProvider).where((b) => b.isUnlocked).length;
}
