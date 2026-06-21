import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/models/leaderboard_entry.dart';
import 'package:Demo/providers/gamification_provider.dart';
import 'package:Demo/providers/habits_provider.dart';
import 'package:Demo/providers/leaderboard_provider.dart';
import 'package:Demo/providers/progress_provider.dart';
import 'package:Demo/providers/rewards_provider.dart';
import 'package:Demo/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final habits = context.watch<HabitsProvider>();
    final progress = context.watch<ProgressProvider>();
    final rewards = context.read<RewardsProvider>();
    final gamification = context.read<GamificationProvider>();
    final leaderboard = context.read<LeaderboardProvider>();

    final entries = leaderboard.buildLeaderboard(
      user: user,
      habits: habits,
      progress: progress,
      rewards: rewards,
      gamification: gamification,
    );
    final currentUser = leaderboard.currentUserEntry(entries);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : MyColors.neutralGray,
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LeaderboardHero(
            currentUser: currentUser,
            totalPlayers: entries.length,
          ),
          const SizedBox(height: 20),
          Text(
            'All Players',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : MyColors.kBlackColor,
            ),
          ),
          const SizedBox(height: 12),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FullLeaderboardTile(entry: entry, isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardHero extends StatelessWidget {
  final LeaderboardEntry? currentUser;
  final int totalPlayers;

  const _LeaderboardHero({
    required this.currentUser,
    required this.totalPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColors.primaryBlue,
            MyColors.primaryBlue.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MyColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 36),
          const SizedBox(height: 10),
          Text(
            currentUser != null
                ? 'Your Rank: #${currentUser!.rank}'
                : 'Join the leaderboard',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            currentUser != null
                ? '${currentUser!.score} XP · Top ${((currentUser!.rank / totalPlayers) * 100).ceil()}%'
                : 'Complete habits to earn XP',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullLeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isDark;

  const _FullLeaderboardTile({
    required this.entry,
    required this.isDark,
  });

  Color? get _rankAccent {
    switch (entry.rank) {
      case 1:
        return const Color(0xFFFACC15);
      case 2:
        return const Color(0xFF94A3B8);
      case 3:
        return const Color(0xFFD97706);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _rankAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? MyColors.primaryBlue.withValues(alpha: 0.1)
            : (isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isCurrentUser
              ? MyColors.primaryBlue.withValues(alpha: 0.4)
              : (isDark ? Colors.white12 : MyColors.neutralGray),
          width: entry.isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent?.withValues(alpha: 0.2) ??
                  (isDark ? const Color(0xFF374151) : MyColors.neutralGray),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '#${entry.rank}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accent ?? MyColors.kDescriptionColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF374151) : MyColors.neutralGray,
            ),
            alignment: Alignment.center,
            child: Text(entry.avatarEmoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.isCurrentUser ? '${entry.name} (You)' : entry.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : MyColors.kBlackColor,
                  ),
                ),
                if (entry.rank <= 3)
                  Text(
                    entry.rank == 1
                        ? 'Gold Champion'
                        : entry.rank == 2
                            ? 'Silver Runner-up'
                            : 'Bronze Star',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: MyColors.kDescriptionColor,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${entry.score} XP',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: MyColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
