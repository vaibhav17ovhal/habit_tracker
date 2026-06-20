import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/custom_widgets/habit_card.dart';
import 'package:Demo/providers/dashboard_provider.dart';
import 'package:Demo/providers/habits_provider.dart';
import 'package:Demo/providers/progress_provider.dart';
import 'package:Demo/providers/user_provider.dart';
import 'package:Demo/screens/habit_creation_screen.dart';
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

    return CustomScaffold(
      backgroundColor: MyColors.neutralGray,
      appBar: AppBar(
        backgroundColor: MyColors.kWhiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Habit Hero',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: MyColors.primaryBlue,
          ),
        ),
        actions: [
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
            child: habitsProvider.habits.isEmpty
                ? _EmptyHabitsState(
                    onAddHabit: () => _navigateToCreateHabit(context),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: habitsProvider.habits.length,
                    itemBuilder: (context, index) {
                      final habit = habitsProvider.habits[index];
                      return HabitCard(
                        habit: habit,
                        onToggle: (_) => habitsProvider.toggleCompletion(
                          habit.id,
                          progressProvider: progressProvider,
                        ),
                      );
                    },
                  ),
          ),
          _ProgressSummaryBar(
            completed: habitsProvider.completedCount,
            total: habitsProvider.totalCount,
            progress: habitsProvider.progressFraction,
          ),
        ],
      ),
    );
  }

  static void _navigateToCreateHabit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HabitCreationScreen()),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: MyColors.kWhiteColor,
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
                  color: MyColors.kBlackColor,
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
              value: progress,
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
  final VoidCallback onAddHabit;

  const _EmptyHabitsState({required this.onAddHabit});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                color: MyColors.kBlackColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create your first habit',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: MyColors.kDescriptionColor,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onAddHabit,
              icon: const Icon(Icons.add, color: MyColors.primaryBlue),
              label: Text(
                'Add habit',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: MyColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
