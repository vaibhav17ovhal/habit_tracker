import 'package:flutter/material.dart';

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
  bool isCompletedToday;

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
    this.isCompletedToday = false,
    this.baselineFrequency,
    this.targetFrequency,
    this.goalType,
    this.frequencyUnit,
    this.replacementAction,
    this.triggerNotes,
    this.todayLoggedCount = 0,
    List<Map<String, dynamic>>? frequencyLogs,
    this.daysOnTarget = 0,
  }) : frequencyLogs = frequencyLogs ?? <Map<String, dynamic>>[];

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
    bool? isCompletedToday,
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
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
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
        'isCompletedToday': isCompletedToday,
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
    return Habit(
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
      isCompletedToday: map['isCompletedToday'] as bool? ?? false,
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
  }

  Map<String, dynamic> toApiMap() => {
        'name': name,
        'iconPath': iconPath,
        'color': color.toARGB32(),
        'type': isBadHabit ? 'bad' : 'good',
        'frequency': frequency.name,
        'reminderTime': reminderTime,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'streak': streak,
        'isCompletedToday': isCompletedToday,
        'baselineFrequency': baselineFrequency,
        'targetFrequency': targetFrequency,
        'goalType': goalType?.name,
        'frequencyUnit': frequencyUnit,
        'replacementAction': replacementAction,
        'triggerNotes': triggerNotes,
        'todayLoggedCount': todayLoggedCount,
        'frequencyLogs': frequencyLogs,
        'daysOnTarget': daysOnTarget,
      };

  factory Habit.fromApiMap(Map<String, dynamic> map) {
    HabitType parseType(dynamic value) {
      if (value == 'bad' || value == 1) return HabitType.bad;
      return HabitType.good;
    }

    HabitFrequency parseFrequency(dynamic value) {
      if (value is int) {
        return HabitFrequency.values[value.clamp(0, 2)];
      }
      final name = value?.toString() ?? 'daily';
      return HabitFrequency.values.firstWhere(
        (f) => f.name == name,
        orElse: () => HabitFrequency.daily,
      );
    }

    BadHabitGoalType? parseGoalType(dynamic value) {
      if (value == null) return null;
      if (value is int) return BadHabitGoalType.values[value];
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

    return Habit(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      iconPath: map['iconPath'] as String? ?? '',
      color: Color((map['color'] as num?)?.toInt() ?? 0xFF3B82F6),
      type: parseType(map['type']),
      frequency: parseFrequency(map['frequency']),
      reminderTime: map['reminderTime'] as String?,
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      isCompletedToday: map['isCompletedToday'] as bool? ?? false,
      baselineFrequency: (map['baselineFrequency'] as num?)?.toDouble(),
      targetFrequency: (map['targetFrequency'] as num?)?.toDouble(),
      goalType: parseGoalType(map['goalType']),
      frequencyUnit: map['frequencyUnit'] as String?,
      replacementAction: map['replacementAction'] as String?,
      triggerNotes: map['triggerNotes'] as String?,
      todayLoggedCount: (map['todayLoggedCount'] as num?)?.toDouble() ?? 0,
      frequencyLogs: (map['frequencyLogs'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          <Map<String, dynamic>>[],
      daysOnTarget: (map['daysOnTarget'] as num?)?.toInt() ?? 0,
    );
  }
}
