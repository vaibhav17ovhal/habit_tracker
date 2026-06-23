import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/progress.dart';
import '../services/hive_service.dart';
import '../utils/streak_utils.dart';

class ProgressProvider extends ChangeNotifier {
  final List<DailyProgress> _records = [];
  int _bestStreak = 0;
  int _activeDayStreak = 0;
  double _monthlyCompletionRate = 0;

  List<DailyProgress> get records => List.unmodifiable(_records);
  int get bestStreak => _bestStreak;
  int get activeDayStreak => _activeDayStreak;
  double get monthlyCompletionRate => _monthlyCompletionRate;

  Future<void> loadFromStorage() async {
    _records.clear();
    final raw = HiveService.progress.get(HiveService.keyProgress);
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          _records.add(DailyProgress.fromMap(item));
        }
      }
    }
    notifyListeners();
  }

  Future<void> applyCalendarDays(
    List<Map<String, dynamic>> days, {
    bool replaceExisting = false,
  }) async {
    if (replaceExisting) {
      _records.clear();
    }

    for (final day in days) {
      final dateKey = day['date']?.toString();
      if (dateKey == null || dateKey.isEmpty) continue;

      final parsed = DateTime.tryParse(dateKey);
      if (parsed == null) continue;

      final normalized = DateTime(parsed.year, parsed.month, parsed.day);
      _records.removeWhere(
        (r) =>
            r.date.year == normalized.year &&
            r.date.month == normalized.month &&
            r.date.day == normalized.day,
      );
      _records.add(
        DailyProgress(
          date: normalized,
          completedCount: (day['completedCount'] as num?)?.toInt() ?? 0,
          totalCount: (day['totalCount'] as num?)?.toInt() ?? 0,
        ),
      );
    }

    await _persist();
    notifyListeners();
  }

  Future<void> applySummary(Map<String, dynamic> summary) async {
    _bestStreak = (summary['bestStreak'] as num?)?.toInt() ?? 0;
    _activeDayStreak = (summary['activeDayStreak'] as num?)?.toInt() ?? 0;
    _monthlyCompletionRate =
        (summary['monthlyCompletionRate'] as num?)?.toDouble() ?? 0;
    notifyListeners();
  }

  void recomputeSummaryFromHabits(List<Habit> habits) {
    final goodHabits = habits.where((h) => !h.isBadHabit).toList();
    if (goodHabits.isEmpty) {
      _bestStreak = 0;
      _activeDayStreak = 0;
      _monthlyCompletionRate = 0;
      notifyListeners();
      return;
    }

    _bestStreak = goodHabits
        .map((h) => h.longestStreak)
        .reduce((a, b) => a > b ? a : b);

    final dateCounts = <String, int>{};
    for (final habit in goodHabits) {
      for (final date in habit.completedDates) {
        dateCounts[date] = (dateCounts[date] ?? 0) + 1;
      }
    }

    var cursor = StreakUtils.todayKey;
    if (!dateCounts.containsKey(cursor) || (dateCounts[cursor] ?? 0) <= 0) {
      cursor = StreakUtils.addDays(cursor, -1);
    }

    var active = 0;
    while ((dateCounts[cursor] ?? 0) > 0) {
      active++;
      cursor = StreakUtils.addDays(cursor, -1);
    }
    _activeDayStreak = active;

    final allDates = <String>[];
    for (final habit in goodHabits) {
      allDates.addAll(habit.completedDates);
    }
    _monthlyCompletionRate = StreakUtils.monthlyCompletionRate(
      completedDates: allDates,
      totalGoodHabits: goodHabits.length,
    );

    notifyListeners();
  }

  Future<void> syncFromHabits(List<Habit> habits) async {
    final goodHabits = habits.where((h) => !h.isBadHabit).toList();
    final total = goodHabits.length;
    if (total == 0) return;

    final counts = <String, int>{};
    for (final habit in goodHabits) {
      for (final date in habit.completedDates) {
        counts[date] = (counts[date] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return;

    final days = counts.entries
        .map(
          (entry) => {
            'date': entry.key,
            'completedCount': entry.value,
            'totalCount': total,
          },
        )
        .toList();

    await applyCalendarDays(days);
    recomputeSummaryFromHabits(habits);
  }

  Future<void> recordDay({
    required DateTime date,
    required int completedCount,
    required int totalCount,
  }) async {
    final normalized = DateTime(date.year, date.month, date.day);
    _records.removeWhere(
      (r) =>
          r.date.year == normalized.year &&
          r.date.month == normalized.month &&
          r.date.day == normalized.day,
    );
    _records.add(DailyProgress(
      date: normalized,
      completedCount: completedCount,
      totalCount: totalCount,
    ));
    await _persist();
    notifyListeners();
  }

  List<DailyProgress> weeklyProgress({DateTime? reference}) {
    final now = reference ?? DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) {
      final day = DateTime(start.year, start.month, start.day + index);
      final match = _records.where(
        (r) =>
            r.date.year == day.year &&
            r.date.month == day.month &&
            r.date.day == day.day,
      );
      if (match.isNotEmpty) return match.first;
      return DailyProgress(date: day, completedCount: 0, totalCount: 0);
    });
  }

  Set<int> completedDaysInMonth({DateTime? reference}) {
    final now = reference ?? DateTime.now();
    return _records
        .where(
          (r) =>
              r.date.year == now.year &&
              r.date.month == now.month &&
              r.completedCount > 0,
        )
        .map((r) => r.date.day)
        .toSet();
  }

  double monthlyCompletionRateFromRecords({DateTime? reference}) {
    final now = reference ?? DateTime.now();
    final monthRecords = _records.where(
      (r) => r.date.year == now.year && r.date.month == now.month,
    );
    if (monthRecords.isEmpty) return 0;

    final daysElapsed = now.day;
    var totalCompleted = 0;
    var totalPossible = 0;

    for (final record in monthRecords) {
      if (record.date.day <= daysElapsed) {
        totalCompleted += record.completedCount;
        totalPossible += record.totalCount;
      }
    }

    if (totalPossible <= 0) {
      final totalGood = monthRecords.isNotEmpty
          ? monthRecords.first.totalCount
          : 0;
      if (totalGood <= 0) return 0;
      return totalCompleted / (totalGood * daysElapsed);
    }

    return totalCompleted / totalPossible;
  }

  Future<void> seedSampleWeek({required int totalHabits}) async {
    if (_records.isNotEmpty) return;

    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));

    for (var i = 0; i < 7; i++) {
      final day = DateTime(start.year, start.month, start.day + i);
      if (day.isAfter(now)) continue;

      final isToday = day.year == now.year &&
          day.month == now.month &&
          day.day == now.day;

      _records.add(
        DailyProgress(
          date: day,
          completedCount: isToday ? 0 : (2 + i).clamp(0, totalHabits),
          totalCount: totalHabits,
        ),
      );
    }

    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await HiveService.progress.put(
      HiveService.keyProgress,
      _records.map((r) => r.toMap()).toList(),
    );
  }
}
