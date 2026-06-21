import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import '../services/token_storage.dart';
import 'progress_provider.dart';

class HabitsProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;
  final List<Habit> _habits = [];
  bool _isLoading = false;
  bool _isSyncing = false;

  List<Habit> get habits => List.unmodifiable(_habits);
  List<Habit> get goodHabits =>
      _habits.where((h) => !h.isBadHabit).toList(growable: false);
  List<Habit> get badHabits =>
      _habits.where((h) => h.isBadHabit).toList(growable: false);

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;

  int get completedCount =>
      goodHabits.where((h) => h.isCompletedToday).length;

  int get totalCount => goodHabits.length;

  int get maxStreak => goodHabits.isEmpty
      ? 0
      : goodHabits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

  int get maxBadHabitDaysOnTarget => badHabits.isEmpty
      ? 0
      : badHabits.map((h) => h.daysOnTarget).reduce((a, b) => a > b ? a : b);

  String get progressSummary => '$completedCount/$totalCount habits completed';

  double get progressFraction =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  Future<void> loadFromStorage() async {
    _habits.clear();
    final raw = HiveService.habits.get(HiveService.keyHabits);
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final habit = Habit.fromMap(item);
          _syncTodayState(habit);
          _habits.add(habit);
        }
      }
    }
    notifyListeners();
  }

  Future<void> fetchFromApi() async {
    if (!await TokenStorage.hasToken()) {
      await loadFromStorage();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final raw = await _api.getHabits();
      _habits
        ..clear()
        ..addAll(
          raw.map((item) {
            final habit = Habit.fromApiMap(item);
            _syncTodayState(habit);
            return habit;
          }),
        );
      await _persist();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHabit(Habit habit) async {
    _isSyncing = true;
    notifyListeners();

    try {
      if (habit.isBadHabit) {
        habit.todayLoggedCount = habit.baselineFrequency ?? 0;
        _logFrequencyForToday(habit, habit.todayLoggedCount);
        _recalculateBadHabitStreak(habit);
      }

      if (await TokenStorage.hasToken()) {
        final created = await _api.addHabit(habit.toApiMap());
        final saved = Habit.fromApiMap(created);
        _syncTodayState(saved);
        _habits.add(saved);
      } else {
        _habits.add(habit);
      }

      await _persist();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> toggleCompletion(
    String habitId, {
    ProgressProvider? progressProvider,
  }) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    if (habit.isBadHabit) return;

    _isSyncing = true;
    notifyListeners();

    try {
      if (await TokenStorage.hasToken()) {
        final updated = await _api.markHabitComplete(habitId);
        _habits[index] = Habit.fromApiMap(updated);
      } else {
        final wasCompleted = habit.isCompletedToday;
        habit.isCompletedToday = !wasCompleted;

        if (!wasCompleted) {
          habit.streak += 1;
        } else if (habit.streak > 0) {
          habit.streak -= 1;
        }
      }

      await _persist();

      if (progressProvider != null) {
        await progressProvider.recordDay(
          date: DateTime.now(),
          completedCount: completedCount,
          totalCount: totalCount,
        );
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> updateBadHabitCount(String habitId, double count) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    if (!habit.isBadHabit) return;

    final safeCount = count < 0 ? 0.0 : count;

    _isSyncing = true;
    notifyListeners();

    try {
      if (await TokenStorage.hasToken()) {
        final updated = await _api.breakHabit(
          habitId,
          todayLoggedCount: safeCount,
        );
        _habits[index] = Habit.fromApiMap(updated);
      } else {
        habit.todayLoggedCount = safeCount;
        _logFrequencyForToday(habit, safeCount);
        _recalculateBadHabitStreak(habit);
      }

      await _persist();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  List<double> weeklyReductionData(Habit habit) {
    final now = DateTime.now();
    final baseline = habit.baselineFrequency ?? 0;
    final values = <double>[];

    for (var i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final log = _logForDate(habit, day);
      values.add(log ?? baseline);
    }
    return values;
  }

  double weeklySavedUnits(Habit habit) {
    final baseline = habit.baselineFrequency ?? 0;
    var saved = 0.0;

    for (final log in habit.frequencyLogs) {
      final date = DateTime.parse(log['date'] as String);
      if (!_isWithinLastWeek(date)) continue;
      final count = (log['count'] as num).toDouble();
      if (count < baseline) saved += baseline - count;
    }
    return saved;
  }

  String? motivationalMessageFor(Habit habit) {
    if (!habit.isBadHabit) return null;

    final savedWeek = weeklySavedUnits(habit).round();
    final baseline = habit.baselineFrequency ?? 0;
    final todaySaved = (baseline - habit.todayLoggedCount).clamp(0, baseline);

    if (savedWeek > 0) {
      final label = _unitLabel(habit, savedWeek);
      return "You've saved $savedWeek $label this week!";
    }

    if (todaySaved > 0) {
      final label = _unitLabel(habit, todaySaved.round());
      return '$todaySaved $label less ${_habitShortName(habit)} today!';
    }

    if (habit.isOnTargetToday) {
      return 'Great job staying on target today!';
    }

    return null;
  }

  String _unitLabel(Habit habit, int amount) {
    final unit = habit.frequencyUnit ?? 'units';
    if (unit.contains('cigarette')) {
      return amount == 1 ? 'cigarette' : 'cigarettes';
    }
    if (unit.contains('hour')) return amount == 1 ? 'hour' : 'hours';
    if (unit.contains('drink')) return amount == 1 ? 'drink' : 'drinks';
    if (unit.contains('serving')) return amount == 1 ? 'serving' : 'servings';
    return unit;
  }

  String _habitShortName(Habit habit) {
    switch (habit.name) {
      case 'Screen Time':
        return 'screen time';
      case 'Junk Food':
        return 'junk food';
      default:
        return habit.name.toLowerCase();
    }
  }

  void _syncTodayState(Habit habit) {
    if (!habit.isBadHabit) return;

    final today = DateTime.now();
    final todayLog = _logForDate(habit, today);
    if (todayLog != null) {
      habit.todayLoggedCount = todayLog;
    } else {
      habit.todayLoggedCount = 0;
    }
  }

  void _logFrequencyForToday(Habit habit, double count) {
    final todayKey = _dateKey(DateTime.now());
    final logs = List<Map<String, dynamic>>.from(habit.frequencyLogs);
    final index = logs.indexWhere((log) => log['date'] == todayKey);

    if (index >= 0) {
      logs[index] = {'date': todayKey, 'count': count};
    } else {
      logs.add({'date': todayKey, 'count': count});
    }

    habit.frequencyLogs
      ..clear()
      ..addAll(logs);
  }

  double? _logForDate(Habit habit, DateTime date) {
    final key = _dateKey(date);
    for (final log in habit.frequencyLogs) {
      if (log['date'] == key) {
        return (log['count'] as num).toDouble();
      }
    }
    return null;
  }

  void _recalculateBadHabitStreak(Habit habit) {
    var streak = 0;
    final now = DateTime.now();

    for (var i = 0; i < 365; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      if (_wasOnTarget(habit, day)) {
        streak++;
      } else {
        break;
      }
    }

    habit.daysOnTarget = streak;
  }

  bool _wasOnTarget(Habit habit, DateTime date) {
    final count = _logForDate(habit, date);
    if (count == null) return false;
    return count <= habit.effectiveTarget;
  }

  bool _isWithinLastWeek(DateTime date) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - 6);
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(start);
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _persist() async {
    await HiveService.habits.put(
      HiveService.keyHabits,
      _habits.map((h) => h.toMap()).toList(),
    );
  }

  Future<void> clearAll() async {
    _habits.clear();
    await HiveService.habits.delete(HiveService.keyHabits);
    notifyListeners();
  }
}

extension BadHabitHelpers on Habit {
  bool get isOnTargetToday => todayLoggedCount <= effectiveTarget;

  double get reductionProgress {
    final baseline = baselineFrequency ?? 0;
    if (baseline <= 0) return 1;
    final reduced = (baseline - todayLoggedCount).clamp(0, baseline);
    final goalReduction = baseline - effectiveTarget;
    if (goalReduction <= 0) return todayLoggedCount == 0 ? 1 : 0;
    return (reduced / goalReduction).clamp(0, 1);
  }
}
