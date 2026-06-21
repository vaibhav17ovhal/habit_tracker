import 'package:flutter/material.dart';

import 'habits_provider.dart';
import 'progress_provider.dart';
import 'rewards_provider.dart';

class GamificationStats {
  final int xp;
  final int level;
  final int xpIntoLevel;
  final int xpNeededForLevel;
  final double levelProgress;
  final int totalCompletions;
  final int maxStreak;
  final int badgesUnlocked;
  final int activeDaysThisMonth;

  const GamificationStats({
    required this.xp,
    required this.level,
    required this.xpIntoLevel,
    required this.xpNeededForLevel,
    required this.levelProgress,
    required this.totalCompletions,
    required this.maxStreak,
    required this.badgesUnlocked,
    required this.activeDaysThisMonth,
  });
}

class GamificationProvider extends ChangeNotifier {
  static const _xpPerCompletion = 10;
  static const _xpPerStreakDay = 15;
  static const _xpPerBadge = 100;
  static const _xpPerActiveDay = 8;
  static const _xpPerLevel = 150;

  GamificationStats statsFor({
    required HabitsProvider habits,
    required ProgressProvider progress,
    required RewardsProvider rewards,
  }) {
    final totalCompletions = progress.records.fold<int>(
      0,
      (sum, record) => sum + record.completedCount,
    );
    final maxStreak = habits.maxStreak;
    final badgesUnlocked = rewards.unlockedCount(habits);
    final now = DateTime.now();
    final activeDaysThisMonth = progress.records
        .where(
          (r) =>
              r.date.year == now.year &&
              r.date.month == now.month &&
              r.completedCount > 0,
        )
        .length;

    final xp = totalCompletions * _xpPerCompletion +
        maxStreak * _xpPerStreakDay +
        badgesUnlocked * _xpPerBadge +
        activeDaysThisMonth * _xpPerActiveDay;

    final level = (xp / _xpPerLevel).floor() + 1;
    final xpIntoLevel = xp - ((level - 1) * _xpPerLevel);
    final xpNeededForLevel = _xpPerLevel;
    final levelProgress =
        (xpIntoLevel / xpNeededForLevel).clamp(0.0, 1.0);

    return GamificationStats(
      xp: xp,
      level: level,
      xpIntoLevel: xpIntoLevel,
      xpNeededForLevel: xpNeededForLevel,
      levelProgress: levelProgress,
      totalCompletions: totalCompletions,
      maxStreak: maxStreak,
      badgesUnlocked: badgesUnlocked,
      activeDaysThisMonth: activeDaysThisMonth,
    );
  }
}
