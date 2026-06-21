import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/custom_widgets/habit_card.dart';
import 'package:Demo/providers/dashboard_provider.dart';
import 'package:Demo/providers/habits_provider.dart';
import 'package:Demo/providers/progress_provider.dart';
import 'package:Demo/providers/user_provider.dart';
import 'package:Demo/widgets/app_bar_mood_chip.dart';
import 'package:Demo/widgets/bad_habit_card.dart';
import 'package:Demo/widgets/dashboard_greeting_banner.dart';
import 'package:Demo/widgets/motivational_quote_banner.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitsProvider = context.watch<HabitsProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final userProvider = context.watch<UserProvider>();
    final progressProvider = context.read<ProgressProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = habitsProvider.progressFraction;
    final goodHabits = habitsProvider.goodHabits;
    final badHabits = habitsProvider.badHabits;

    return CustomScaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : MyColors.neutralGray,
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Habit Hero',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: MyColors.primaryBlue,
          ),
        ),
        actions: [
          const AppBarMoodChip(),
          GestureDetector(
            onTap: () => dashboardProvider.changeIndex(3),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(userProvider.avatarPath),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                DashboardGreetingBanner(
                  userName: userProvider.displayName,
                  maxStreak: habitsProvider.maxStreak,
                  progress: progress,
                ),
                const MotivationalQuoteBanner(),
                if (goodHabits.isEmpty && badHabits.isEmpty)
                  const _EmptyHabitsState()
                else ...[
                  if (goodHabits.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Good Habits',
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: MyColors.primaryBlue,
                    ),
                    ...goodHabits.map(
                      (habit) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: HabitCard(
                          habit: habit,
                          onToggle: (_) => habitsProvider.toggleCompletion(
                            habit.id,
                            progressProvider: progressProvider,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (badHabits.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Breaking Bad Habits',
                      icon: Icons.trending_down_rounded,
                      iconColor: const Color(0xFFEF4444),
                    ),
                    ...badHabits.map(
                      (habit) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: BadHabitCard(habit: habit),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          _ProgressSummaryBar(
            completed: habitsProvider.completedCount,
            total: habitsProvider.totalCount,
            progress: progress,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : MyColors.kBlackColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSummaryBar extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;

  const _ProgressSummaryBar({
    required this.completed,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed/$total habits completed',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : MyColors.kBlackColor,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: MyColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : progress,
              minHeight: 8,
              backgroundColor: MyColors.neutralGray,
              valueColor: const AlwaysStoppedAnimation<Color>(
                MyColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHabitsState extends StatelessWidget {
  const _EmptyHabitsState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.track_changes_rounded,
            size: 64,
            color: MyColors.primaryBlue.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : MyColors.kBlackColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a good habit, break a bad one, or log your mood',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: MyColors.kDescriptionColor,
            ),
          ),
        ],
      ),
    );
  }
}
