import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/streak_utils.dart';

enum HabitFrequency { daily, weekly, monthly }

enum HabitType { good, bad }

enum BadHabitGoalType { quit, reduce }

extension HabitFrequencyLabel on HabitFrequency {
  String get label {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
    }
  }
}

class Habit {
  final String id;
  final String name;
  final String iconPath;
  final Color color;
  final HabitType type;
  final HabitFrequency frequency;
  final String? reminderTime;
  final DateTime? startDate;
  final DateTime? endDate;
  int streak;
  int longestStreak;
  bool isCompletedToday;
  final List<String> completedDates;
  final List<String> brokenDates;

  // Bad habit fields
  final double? baselineFrequency;
  final double? targetFrequency;
  final BadHabitGoalType? goalType;
  final String? frequencyUnit;
  final String? replacementAction;
  final String? triggerNotes;
  double todayLoggedCount;
  final List<Map<String, dynamic>> frequencyLogs;
  int daysOnTarget;

  Habit({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.color,
    this.type = HabitType.good,
    this.frequency = HabitFrequency.daily,
    this.reminderTime,
    this.startDate,
    this.endDate,
    this.streak = 0,
    this.longestStreak = 0,
    this.isCompletedToday = false,
    List<String>? completedDates,
    List<String>? brokenDates,
    this.baselineFrequency,
    this.targetFrequency,
    this.goalType,
    this.frequencyUnit,
    this.replacementAction,
    this.triggerNotes,
    this.todayLoggedCount = 0,
    List<Map<String, dynamic>>? frequencyLogs,
    this.daysOnTarget = 0,
  })  : frequencyLogs = frequencyLogs ?? <Map<String, dynamic>>[],
        completedDates = completedDates ?? <String>[],
        brokenDates = brokenDates ?? <String>[];

  bool get isBadHabit => type == HabitType.bad;

  double get effectiveTarget =>
      goalType == BadHabitGoalType.quit ? 0 : (targetFrequency ?? 0);

  Habit copyWith({
    String? id,
    String? name,
    String? iconPath,
    Color? color,
    HabitType? type,
    HabitFrequency? frequency,
    String? reminderTime,
    DateTime? startDate,
    DateTime? endDate,
    int? streak,
    int? longestStreak,
    bool? isCompletedToday,
    List<String>? completedDates,
    List<String>? brokenDates,
    double? baselineFrequency,
    double? targetFrequency,
    BadHabitGoalType? goalType,
    String? frequencyUnit,
    String? replacementAction,
    String? triggerNotes,
    double? todayLoggedCount,
    List<Map<String, dynamic>>? frequencyLogs,
    int? daysOnTarget,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      color: color ?? this.color,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      completedDates: completedDates ?? List<String>.from(this.completedDates),
      brokenDates: brokenDates ?? List<String>.from(this.brokenDates),
      baselineFrequency: baselineFrequency ?? this.baselineFrequency,
      targetFrequency: targetFrequency ?? this.targetFrequency,
      goalType: goalType ?? this.goalType,
      frequencyUnit: frequencyUnit ?? this.frequencyUnit,
      replacementAction: replacementAction ?? this.replacementAction,
      triggerNotes: triggerNotes ?? this.triggerNotes,
      todayLoggedCount: todayLoggedCount ?? this.todayLoggedCount,
      frequencyLogs: frequencyLogs ?? this.frequencyLogs,
      daysOnTarget: daysOnTarget ?? this.daysOnTarget,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconPath': iconPath,
        'color': color.toARGB32(),
        'type': type.index,
        'frequency': frequency.index,
        'reminderTime': reminderTime,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'streak': streak,
        'longestStreak': longestStreak,
        'isCompletedToday': isCompletedToday,
        'completedDates': completedDates,
        'brokenDates': brokenDates,
        'baselineFrequency': baselineFrequency,
        'targetFrequency': targetFrequency,
        'goalType': goalType?.index,
        'frequencyUnit': frequencyUnit,
        'replacementAction': replacementAction,
        'triggerNotes': triggerNotes,
        'todayLoggedCount': todayLoggedCount,
        'frequencyLogs': frequencyLogs,
        'daysOnTarget': daysOnTarget,
      };

  factory Habit.fromMap(Map<dynamic, dynamic> map) {
    final habit = Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      iconPath: map['iconPath'] as String,
      color: Color(map['color'] as int),
      type: HabitType.values[map['type'] as int? ?? 0],
      frequency: HabitFrequency.values[map['frequency'] as int? ?? 0],
      reminderTime: map['reminderTime'] as String?,
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'] as String)
          : null,
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      streak: map['streak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      isCompletedToday: map['isCompletedToday'] as bool? ?? false,
      completedDates: (map['completedDates'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      brokenDates: (map['brokenDates'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      baselineFrequency: (map['baselineFrequency'] as num?)?.toDouble(),
      targetFrequency: (map['targetFrequency'] as num?)?.toDouble(),
      goalType: map['goalType'] != null
          ? BadHabitGoalType.values[map['goalType'] as int]
          : null,
      frequencyUnit: map['frequencyUnit'] as String?,
      replacementAction: map['replacementAction'] as String?,
      triggerNotes: map['triggerNotes'] as String?,
      todayLoggedCount: (map['todayLoggedCount'] as num?)?.toDouble() ?? 0,
      frequencyLogs: (map['frequencyLogs'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          <Map<String, dynamic>>[],
      daysOnTarget: map['daysOnTarget'] as int? ?? 0,
    );

    if (!habit.isBadHabit) {
      habit.refreshStreakFields();
    }

    return habit;
  }

  Map<String, dynamic> toApiMap() {
    final meta = {
      'iconPath': iconPath,
      'color': color.toARGB32(),
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (baselineFrequency != null) 'baselineFrequency': baselineFrequency,
      if (targetFrequency != null) 'targetFrequency': targetFrequency,
      if (goalType != null) 'goalType': goalType!.name,
      if (frequencyUnit != null) 'frequencyUnit': frequencyUnit,
      if (replacementAction != null) 'replacementAction': replacementAction,
      if (triggerNotes != null) 'triggerNotes': triggerNotes,
      'todayLoggedCount': todayLoggedCount,
      'frequencyLogs': frequencyLogs,
      'daysOnTarget': daysOnTarget,
    };

    final reminders = <String>[
      if (reminderTime != null && reminderTime!.isNotEmpty) reminderTime!,
      'meta:${jsonEncode(meta)}',
    ];

    return {
      'title': name,
      'type': isBadHabit ? 'bad' : 'good',
      'frequency': _apiFrequency,
      'reminders': reminders,
    };
  }

  String get _apiFrequency {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'daily';
      case HabitFrequency.weekly:
        return 'weekly';
      case HabitFrequency.monthly:
        return 'custom';
    }
  }

  factory Habit.fromApiMap(Map<String, dynamic> map) {
    HabitType parseType(dynamic value) {
      if (value == 'bad') return HabitType.bad;
      return HabitType.good;
    }

    HabitFrequency parseFrequency(dynamic value) {
      final name = value?.toString() ?? 'daily';
      switch (name) {
        case 'weekly':
          return HabitFrequency.weekly;
        case 'custom':
        case 'monthly':
          return HabitFrequency.monthly;
        default:
          return HabitFrequency.daily;
      }
    }

    BadHabitGoalType? parseGoalType(dynamic value) {
      if (value == null) return null;
      final name = value.toString();
      return BadHabitGoalType.values.firstWhere(
        (g) => g.name == name,
        orElse: () => BadHabitGoalType.quit,
      );
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    final reminders = map['reminders'] as List? ?? [];
    Map<String, dynamic> meta = {};
    String? reminderTime;

    for (final item in reminders) {
      final text = item.toString();
      if (text.startsWith('meta:')) {
        try {
          meta = Map<String, dynamic>.from(
            jsonDecode(text.substring(5)) as Map,
          );
        } catch (_) {}
      } else {
        reminderTime ??= text;
      }
    }

    final completedDates =
        (map['completedDates'] as List?)?.map((e) => e.toString()).toList() ??
            [];
    final todayKey = StreakUtils.todayKey;
    final isCompletedToday = completedDates.contains(todayKey);
    final streak = (map['streak'] as num?)?.toInt() ??
        StreakUtils.currentStreak(completedDates, referenceToday: todayKey);
    final longestStreak = (map['longestStreak'] as num?)?.toInt() ??
        StreakUtils.longestStreak(completedDates);

    final brokenDates =
        (map['brokenDates'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return Habit(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      name: map['title'] as String? ?? map['name'] as String? ?? '',
      iconPath: meta['iconPath'] as String? ?? 'assets/habit_icon/Meditation-bro.svg',
      color: Color((meta['color'] as num?)?.toInt() ?? 0xFF3B82F6),
      type: parseType(map['type']),
      frequency: parseFrequency(map['frequency']),
      reminderTime: reminderTime ?? meta['reminderTime'] as String?,
      startDate: parseDate(meta['startDate']),
      endDate: parseDate(meta['endDate']),
      streak: streak,
      longestStreak: longestStreak,
      isCompletedToday: isCompletedToday,
      completedDates: completedDates,
      brokenDates: brokenDates,
      baselineFrequency: (meta['baselineFrequency'] as num?)?.toDouble(),
      targetFrequency: (meta['targetFrequency'] as num?)?.toDouble(),
      goalType: parseGoalType(meta['goalType']),
      frequencyUnit: meta['frequencyUnit'] as String?,
      replacementAction: meta['replacementAction'] as String?,
      triggerNotes: meta['triggerNotes'] as String?,
      todayLoggedCount: (meta['todayLoggedCount'] as num?)?.toDouble() ?? 0,
      frequencyLogs: (meta['frequencyLogs'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          <Map<String, dynamic>>[],
      daysOnTarget: brokenDates.isEmpty
          ? (meta['daysOnTarget'] as num?)?.toInt() ?? 0
          : 0,
    );
  }

  void refreshStreakFields() {
    streak = StreakUtils.currentStreak(completedDates);
    longestStreak = StreakUtils.longestStreak(completedDates);
    isCompletedToday = completedDates.contains(StreakUtils.todayKey);
  }
}
