class GreetingHelper {
  static String timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static String subtitle({
    required int maxStreak,
    required double progress,
  }) {
    if (progress >= 1) return 'All habits done today! 🎉';
    if (maxStreak >= 7) return 'Keep going! You\'re on fire 🔥';
    if (progress > 0) return 'Keep going! You\'re making progress.';
    return 'Let\'s build great habits today!';
  }
}
