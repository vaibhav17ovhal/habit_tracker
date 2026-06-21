class RewardBadge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int requiredStreak;
  final bool isUnlocked;

  const RewardBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requiredStreak,
    required this.isUnlocked,
  });
}
