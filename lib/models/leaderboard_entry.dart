class LeaderboardEntry {
  final int rank;
  final String name;
  final int score;
  final String avatarEmoji;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
    required this.avatarEmoji,
    this.isCurrentUser = false,
  });

  LeaderboardEntry copyWith({int? rank}) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      name: name,
      score: score,
      avatarEmoji: avatarEmoji,
      isCurrentUser: isCurrentUser,
    );
  }
}
