import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/custom_widgets/habit_card.dart';
import 'package:Demo/providers/dashboard_provider.dart';
import 'package:Demo/providers/habits_provider.dart';
import 'package:Demo/providers/progress_provider.dart';
import 'package:Demo/providers/user_provider.dart';
import 'package:Demo/widgets/app_bar_mood_chip.dart';
import 'package:Demo/widgets/dashboard_greeting_banner.dart';
import 'package:Demo/widgets/motivational_quote_banner.dart';
import 'package:Demo/widgets/today_water_drop_card.dart';
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
                if (habitsProvider.habits.isEmpty)
                  const _EmptyHabitsState()
                else
                  ...habitsProvider.habits.map(
                    (habit) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
            ),
          ),
          _ProgressSummaryBar(
            completed: habitsProvider.completedCount,
            total: habitsProvider.totalCount,
            progress: progress,
            isDark: isDark,
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
  final bool isDark;

  const _ProgressSummaryBar({
    required this.completed,
    required this.total,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Progress",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MyColors.kDescriptionColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completed/$total habits completed',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : MyColors.kBlackColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percent% complete',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: MyColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 78,
            height: 104,
            child: AnimatedWaterDropIndicator(
              fillLevel: progress,
              fillLabel: '$percent%',
              isDark: isDark,
              width: 78,
              height: 104,
              labelFontSize: 14,
              labelTopRatio: 0.30,
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
            'Tap + to add a habit or log your mood',
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
