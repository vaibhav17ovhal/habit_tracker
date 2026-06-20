import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../custom_widgets/custom_colors.dart';
import '../services/hive_service.dart';
import 'progress_provider.dart';

class HabitsProvider extends ChangeNotifier {
  final List<Habit> _habits = [];

  List<Habit> get habits => List.unmodifiable(_habits);

  int get completedCount => _habits.where((h) => h.isCompletedToday).length;

  int get totalCount => _habits.length;

  int get maxStreak =>
      _habits.isEmpty ? 0 : _habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

  String get progressSummary => '$completedCount/$totalCount habits completed';

  double get progressFraction =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  static List<Habit> get defaultHabits => [
        Habit(
          id: '1',
          name: 'Meditate',
          iconPath: 'assets/habit_icon/Meditation-bro.svg',
          color: MyColors.primaryBlue,
          streak: 12,
          isCompletedToday: true,
          reminderTime: '07:00',
        ),
        Habit(
          id: '2',
          name: 'Run',
          iconPath: 'assets/habit_icon/Cross country race-pana.svg',
          color: const Color(0xFF10B981),
          streak: 7,
          isCompletedToday: true,
          reminderTime: '06:30',
        ),
        Habit(
          id: '3',
          name: 'Read',
          iconPath: 'assets/habit_icon/Book lover-amico.svg',
          color: const Color(0xFF8B5CF6),
          streak: 21,
          isCompletedToday: false,
          reminderTime: '21:00',
        ),
        Habit(
          id: '4',
          name: 'Stop Smoking',
          iconPath: 'assets/break_habit_icon/stop_smoking_icon.svg',
          color: const Color(0xFFEF4444),
          streak: 30,
          isCompletedToday: true,
        ),
        Habit(
          id: '5',
          name: 'Limit Junk Food',
          iconPath: 'assets/break_habit_icon/limit_junk_food_icon.svg',
          color: const Color(0xFFF97316),
          streak: 5,
          isCompletedToday: false,
        ),
        Habit(
          id: '6',
          name: 'Limit Screen Time',
          iconPath: 'assets/habit_icon/Insomnia-amico.svg',
          color: const Color(0xFF6366F1),
          streak: 3,
          isCompletedToday: false,
          reminderTime: '22:00',
        ),
      ];

  Future<void> loadFromStorage() async {
    _habits.clear();
    final raw = HiveService.habits.get(HiveService.keyHabits);
    if (raw is List && raw.isNotEmpty) {
      for (final item in raw) {
        if (item is Map) {
          _habits.add(Habit.fromMap(item));
        }
      }
    } else {
      _habits.addAll(defaultHabits);
      await _persist();
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
