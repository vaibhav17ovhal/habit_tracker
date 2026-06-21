import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/models/reward.dart';
import 'package:Demo/providers/habits_provider.dart';
import 'package:Demo/providers/rewards_provider.dart';
import 'package:Demo/widgets/badge_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BadgesAndRewardsScreen extends StatelessWidget {
  const BadgesAndRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitsProvider = context.watch<HabitsProvider>();
    final rewardsProvider = context.read<RewardsProvider>();
    final goodBadges = rewardsProvider.goodHabitBadgesFor(habitsProvider);
    final badBadges = rewardsProvider.badHabitBadgesFor(habitsProvider);
    final allBadges = [...goodBadges, ...badBadges];
    final unlocked = allBadges.where((b) => b.isUnlocked).length;
    final maxStreak = habitsProvider.maxStreak;
    final maxBadDays = habitsProvider.maxBadHabitDaysOnTarget;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: CustomScaffold(
        backgroundColor:
            isDark ? const Color(0xFF111827) : MyColors.neutralGray,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            'Rewards',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          bottom: TabBar(
            labelStyle: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            indicatorColor: MyColors.primaryBlue,
            labelColor: MyColors.primaryBlue,
            unselectedLabelColor: MyColors.kDescriptionColor,
            tabs: const [
              Tab(text: 'Good Habit Streak'),
              Tab(text: 'Bad Habit Streak'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _RewardsSummaryCard(
                unlocked: unlocked,
                total: allBadges.length,
                maxStreak: maxStreak,
                maxBadDays: maxBadDays,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _BadgeListTab(
                    badges: goodBadges,
                    currentStreak: maxStreak,
                    emptyMessage:
                        'Complete good habits daily to unlock streak badges!',
                  ),
                  _BadgeListTab(
                    badges: badBadges,
                    currentStreak: maxBadDays,
                    emptyMessage:
                        'Stay on target with bad habits to earn milestone badges!',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardsSummaryCard extends StatelessWidget {
  final int unlocked;
  final int total;
  final int maxStreak;
  final int maxBadDays;

  const _RewardsSummaryCard({
    required this.unlocked,
    required this.total,
    required this.maxStreak,
    required this.maxBadDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColors.primaryBlue,
            MyColors.primaryBlue.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '$unlocked / $total',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            'Badges Unlocked',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Good streak: $maxStreak days · Bad on target: $maxBadDays days',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeListTab extends StatelessWidget {
  final List<RewardBadge> badges;
  final int currentStreak;
  final String emptyMessage;

  const _BadgeListTab({
    required this.badges,
    required this.currentStreak,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: MyColors.kDescriptionColor,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: badges.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: BadgeCard(
              badge: badges[index],
              currentStreak: currentStreak,
            ),
          ),
        );
      },
    );
  }
}
