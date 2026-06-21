import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../services/hive_service.dart';
import 'progress_provider.dart';

class HabitsProvider extends ChangeNotifier {
  final List<Habit> _habits = [];

  List<Habit> get habits => List.unmodifiable(_habits);

  int get completedCount => _habits.where((h) => h.isCompletedToday).length;

  int get totalCount => _habits.length;

  int get maxStreak => _habits.isEmpty
      ? 0
      : _habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

  String get progressSummary => '$completedCount/$totalCount habits completed';

  double get progressFraction =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  Future<void> loadFromStorage() async {
    _habits.clear();
    final raw = HiveService.habits.get(HiveService.keyHabits);
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          _habits.add(Habit.fromMap(item));
        }
      }
    }
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _persist();
    notifyListeners();
  }

  Future<void> toggleCompletion(
    String habitId, {
    ProgressProvider? progressProvider,
  }) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    final wasCompleted = habit.isCompletedToday;
    habit.isCompletedToday = !wasCompleted;

    if (!wasCompleted) {
      habit.streak += 1;
    } else if (habit.streak > 0) {
      habit.streak -= 1;
    }

    await _persist();

    if (progressProvider != null) {
      await progressProvider.recordDay(
        date: DateTime.now(),
        completedCount: completedCount,
        totalCount: totalCount,
      );
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    await HiveService.habits.put(
      HiveService.keyHabits,
      _habits.map((h) => h.toMap()).toList(),
    );
  }
}
