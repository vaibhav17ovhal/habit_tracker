class StreakUtils {
  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String get todayKey => dateKey(DateTime.now());

  static String addDays(String key, int delta) {
    final parts = key.split('-').map(int.parse).toList();
    final date = DateTime(parts[0], parts[1], parts[2]);
    final shifted = date.add(Duration(days: delta));
    return dateKey(shifted);
  }

  static List<String> uniqueSortedDates(List<String> dates) {
    return dates.where((d) => d.isNotEmpty).toSet().toList()..sort();
  }

  static int currentStreak(
    List<String> completedDates, {
    String? referenceToday,
  }) {
    final set = uniqueSortedDates(completedDates).toSet();
    if (set.isEmpty) return 0;

    var cursor = referenceToday ?? todayKey;
    if (!set.contains(cursor)) {
      cursor = addDays(cursor, -1);
    }

    var streak = 0;
    while (set.contains(cursor)) {
      streak++;
      cursor = addDays(cursor, -1);
    }
    return streak;
  }

  static int longestStreak(List<String> completedDates) {
    final sorted = uniqueSortedDates(completedDates);
    if (sorted.isEmpty) return 0;
    if (sorted.length == 1) return 1;

    var max = 1;
    var current = 1;

    for (var i = 1; i < sorted.length; i++) {
      if (addDays(sorted[i - 1], 1) == sorted[i]) {
        current++;
      } else {
        current = 1;
      }
      if (current > max) max = current;
    }

    return max;
  }

  static double monthlyCompletionRate({
    required List<String> completedDates,
    required int totalGoodHabits,
    DateTime? reference,
  }) {
    if (totalGoodHabits <= 0) return 0;

    final now = reference ?? DateTime.now();
    final daysElapsed = now.day;
    if (daysElapsed <= 0) return 0;

    final counts = <String, int>{};
    for (final date in completedDates) {
      final parts = date.split('-').map(int.parse).toList();
      if (parts[0] != now.year || parts[1] != now.month) continue;
      counts[date] = (counts[date] ?? 0) + 1;
    }

    var totalCompleted = 0;
    for (var day = 1; day <= daysElapsed; day++) {
      final key = dateKey(DateTime(now.year, now.month, day));
      totalCompleted += counts[key] ?? 0;
    }

    return totalCompleted / (totalGoodHabits * daysElapsed);
  }
}
