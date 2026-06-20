class DailyProgress {
  final DateTime date;
  final int completedCount;
  final int totalCount;

  const DailyProgress({
    required this.date,
    required this.completedCount,
    required this.totalCount,
  });

  double get completionRate =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'completedCount': completedCount,
        'totalCount': totalCount,
      };

  factory DailyProgress.fromMap(Map<dynamic, dynamic> map) {
    return DailyProgress(
      date: DateTime.parse(map['date'] as String),
      completedCount: map['completedCount'] as int? ?? 0,
      totalCount: map['totalCount'] as int? ?? 0,
    );
  }
}
