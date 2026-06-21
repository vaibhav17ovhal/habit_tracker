import 'package:flutter/material.dart';

enum HabitFrequency { daily, weekly, monthly }

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
  final HabitFrequency frequency;
  final String? reminderTime;
  final DateTime? startDate;
  final DateTime? endDate;
  int streak;
  bool isCompletedToday;

  Habit({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.color,
    this.frequency = HabitFrequency.daily,
    this.reminderTime,
    this.startDate,
    this.endDate,
    this.streak = 0,
    this.isCompletedToday = false,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? iconPath,
    Color? color,
    HabitFrequency? frequency,
    String? reminderTime,
    DateTime? startDate,
    DateTime? endDate,
    int? streak,
    bool? isCompletedToday,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      streak: streak ?? this.streak,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconPath': iconPath,
        'color': color.toARGB32(),
        'frequency': frequency.index,
        'reminderTime': reminderTime,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'streak': streak,
        'isCompletedToday': isCompletedToday,
      };

  factory Habit.fromMap(Map<dynamic, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      iconPath: map['iconPath'] as String,
      color: Color(map['color'] as int),
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
    );
  }
}
