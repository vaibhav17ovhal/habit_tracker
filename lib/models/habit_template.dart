import 'package:flutter/material.dart';

import '../custom_widgets/custom_colors.dart';

class HabitTemplate {
  final String name;
  final String iconPath;
  final Color color;

  const HabitTemplate({
    required this.name,
    required this.iconPath,
    required this.color,
  });
}

const kGoodHabitTemplates = [
  HabitTemplate(
    name: 'Meditate',
    iconPath: 'assets/habit_icon/Meditation-bro.svg',
    color: MyColors.primaryBlue,
  ),
  HabitTemplate(
    name: 'Run',
    iconPath: 'assets/habit_icon/Cross country race-pana.svg',
    color: const Color(0xFF10B981),
  ),
  HabitTemplate(
    name: 'Read',
    iconPath: 'assets/habit_icon/Book lover-amico.svg',
    color: const Color(0xFF8B5CF6),
  ),
  HabitTemplate(
    name: 'Journal',
    iconPath: 'assets/habit_icon/Diary-bro.svg',
    color: const Color(0xFFEC4899),
  ),
];

const kBadHabitTemplates = [
  HabitTemplate(
    name: 'Smoking',
    iconPath: 'assets/break_habit_icon/stop_smoking_icon.svg',
    color: const Color(0xFFEF4444),
  ),
  HabitTemplate(
    name: 'Alcohol',
    iconPath: 'assets/break_habit_icon/stop_drinking_icon.svg',
    color: const Color(0xFF6366F1),
  ),
  HabitTemplate(
    name: 'Junk Food',
    iconPath: 'assets/break_habit_icon/limit_junk_food_icon.svg',
    color: const Color(0xFFF97316),
  ),
  HabitTemplate(
    name: 'Screen Time',
    iconPath: 'assets/habit_icon/Insomnia-amico.svg',
    color: const Color(0xFF3B82F6),
  ),
];

const kBadHabitUnits = {
  'Smoking': 'cigarettes/day',
  'Alcohol': 'drinks/day',
  'Junk Food': 'servings/day',
  'Screen Time': 'hours/day',
};
