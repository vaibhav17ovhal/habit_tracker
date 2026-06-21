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

const kHabitTemplates = [
  HabitTemplate(
    name: 'Meditate',
    iconPath: 'assets/habit_icon/Meditation-bro.svg',
    color: MyColors.primaryBlue,
  ),
  HabitTemplate(
    name: 'Run',
    iconPath: 'assets/habit_icon/Cross country race-pana.svg',
    color: Color(0xFF10B981),
  ),
  HabitTemplate(
    name: 'Read',
    iconPath: 'assets/habit_icon/Book lover-amico.svg',
    color: Color(0xFF8B5CF6),
  ),
  HabitTemplate(
    name: 'Journal',
    iconPath: 'assets/habit_icon/Diary-bro.svg',
    color: Color(0xFFEC4899),
  ),
  HabitTemplate(
    name: 'Stop Smoking',
    iconPath: 'assets/break_habit_icon/stop_smoking_icon.svg',
    color: Color(0xFFEF4444),
  ),
  HabitTemplate(
    name: 'Limit Junk Food',
    iconPath: 'assets/break_habit_icon/limit_junk_food_icon.svg',
    color: Color(0xFFF97316),
  ),
  HabitTemplate(
    name: 'Limit Screen Time',
    iconPath: 'assets/habit_icon/Insomnia-amico.svg',
    color: Color(0xFF6366F1),
  ),
];
