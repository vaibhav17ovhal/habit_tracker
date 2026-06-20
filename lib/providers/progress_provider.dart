import 'package:flutter/material.dart';

import '../models/progress.dart';
import '../services/hive_service.dart';

class ProgressProvider extends ChangeNotifier {
  final List<DailyProgress> _records = [];

  List<DailyProgress> get records => List.unmodifiable(_records);

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

  double monthlyCompletionRate({DateTime? reference}) {
    final now = reference ?? DateTime.now();
    final monthRecords = _records.where(
      (r) => r.date.year == now.year && r.date.month == now.month,
    );
    if (monthRecords.isEmpty) return 0;
    final total = monthRecords.fold<double>(
      0,
      (sum, r) => sum + r.completionRate,
    );
    return total / monthRecords.length;
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
