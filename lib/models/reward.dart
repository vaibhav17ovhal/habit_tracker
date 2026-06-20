import 'package:flutter/material.dart';

class RewardBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int requiredStreak;
  final bool isUnlocked;

  const RewardBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredStreak,
    required this.isUnlocked,
  });

  RewardBadge copyWith({bool? isUnlocked}) {
    return RewardBadge(
      id: id,
      title: title,
      description: description,
      icon: icon,
      requiredStreak: requiredStreak,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
