import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/providers/habits_provider.dart';
import 'package:Demo/providers/mood_provider.dart';
import 'package:Demo/providers/progress_provider.dart';
import 'package:Demo/widgets/bad_habit_reduction_chart.dart';
import 'package:Demo/widgets/streak_calendar.dart';
import 'package:Demo/widgets/today_water_drop_card.dart';
import 'package:Demo/widgets/weekly_bar_chart.dart';
import 'package:Demo/widgets/weekly_mood_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitsProvider = context.watch<HabitsProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final weekData = progressProvider.weeklyProgress();
    final weekMoods = moodProvider.weeklyMoods();
    final completedDays = progressProvider.completedDaysInMonth();
    final monthlyRate = progressProvider.monthlyCompletionRate > 0
        ? progressProvider.monthlyCompletionRate
        : progressProvider.monthlyCompletionRateFromRecords();
    final bestStreak = progressProvider.bestStreak > 0
        ? progressProvider.bestStreak
        : habitsProvider.maxStreak;
    final badHabits = habitsProvider.badHabits;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : MyColors.neutralGray,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Progress',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatsRow(
              maxStreak: bestStreak,
              completedToday: habitsProvider.completedCount,
              totalHabits: habitsProvider.totalCount,
              monthlyRate: monthlyRate,
            ),
            const SizedBox(height: 16),
            Text(
              'Good Habits — Weekly Progress',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : MyColors.kDescriptionColor,
              ),
            ),
            const SizedBox(height: 10),
            WeeklyBarChart(weekData: weekData),
            const SizedBox(height: 16),
            WeeklyMoodChart(weekMoods: weekMoods),
            const SizedBox(height: 16),
            TodayWaterDropCard(
              completedCount: habitsProvider.completedCount,
              totalCount: habitsProvider.totalCount,
            ),
            const SizedBox(height: 16),
            StreakCalendar(
              month: DateTime.now(),
              completedDays: completedDays,
            ),
            if (badHabits.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Bad Habits — Reduction Trends',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : MyColors.kDescriptionColor,
                ),
              ),
              const SizedBox(height: 12),
              ...badHabits.map(
                (habit) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: BadHabitReductionChart(
                    habit: habit,
                    weekData: habitsProvider.weeklyReductionData(habit),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int maxStreak;
  final int completedToday;
  final int totalHabits;
  final double monthlyRate;

  const _StatsRow({
    required this.maxStreak,
    required this.completedToday,
    required this.totalHabits,
    required this.monthlyRate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Best Streak',
            value: '$maxStreak days',
            icon: Icons.local_fire_department_rounded,
            iconColor: MyColors.accentYellow,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Today',
            value: '$completedToday/$totalHabits',
            icon: Icons.check_circle_outline_rounded,
            iconColor: MyColors.primaryBlue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'This Month',
            value: '${(monthlyRate * 100).round()}%',
            icon: Icons.calendar_month_rounded,
            iconColor: const Color(0xFF10B981),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : MyColors.neutralGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : MyColors.kBlackColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: MyColors.kDescriptionColor,
            ),
          ),
        ],
      ),
    );
  }
}
