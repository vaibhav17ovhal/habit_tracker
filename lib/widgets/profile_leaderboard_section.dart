import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/models/leaderboard_entry.dart';
import 'package:Demo/screens/leaderboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileLeaderboardSection extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUser;

  const ProfileLeaderboardSection({
    super.key,
    required this.entries,
    required this.currentUser,
  });

  List<LeaderboardEntry> get _topThree =>
      entries.length >= 3 ? entries.take(3).toList() : entries;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Leaderboard',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MyColors.kDescriptionColor,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white12 : MyColors.neutralGray,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (_topThree.isNotEmpty) _PodiumRow(topThree: _topThree),
              if (entries.length > 3) ...[
                const SizedBox(height: 14),
                ...entries.skip(3).take(2).map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _LeaderboardRow(entry: entry, isDark: isDark),
                      ),
                    ),
              ],
              if (currentUser != null &&
                  currentUser!.rank > 5 &&
                  !entries.take(5).any((e) => e.isCurrentUser)) ...[
                const SizedBox(height: 4),
                _LeaderboardRow(entry: currentUser!, isDark: isDark),
              ],
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: MyColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MyColors.primaryBlue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Full Leaderboard',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: MyColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: MyColors.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PodiumRow extends StatelessWidget {
  final List<LeaderboardEntry> topThree;

  const _PodiumRow({required this.topThree});

  @override
  Widget build(BuildContext context) {
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: second != null ? _PodiumItem(entry: second, place: 2) : const SizedBox()),
        Expanded(child: first != null ? _PodiumItem(entry: first, place: 1) : const SizedBox()),
        Expanded(child: third != null ? _PodiumItem(entry: third, place: 3) : const SizedBox()),
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int place;

  const _PodiumItem({required this.entry, required this.place});

  Color get _medalColor {
    switch (place) {
      case 1:
        return const Color(0xFFFACC15);
      case 2:
        return const Color(0xFFCBD5E1);
      case 3:
        return const Color(0xFFD97706);
      default:
        return MyColors.primaryBlue;
    }
  }

  double get _podiumHeight {
    switch (place) {
      case 1:
        return 72;
      case 2:
        return 56;
      case 3:
        return 48;
      default:
        return 40;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = entry.name.split(' ').first;

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: entry.isCurrentUser
                ? MyColors.primaryBlue.withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF374151) : MyColors.neutralGray),
            border: Border.all(
              color: entry.isCurrentUser
                  ? MyColors.primaryBlue
                  : _medalColor,
              width: entry.isCurrentUser ? 2 : 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(entry.avatarEmoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : MyColors.kBlackColor,
          ),
        ),
        Text(
          '${entry.score} XP',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: MyColors.kDescriptionColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: _podiumHeight,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _medalColor.withValues(alpha: 0.85),
                _medalColor.withValues(alpha: 0.45),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '#$place',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isDark;

  const _LeaderboardRow({required this.entry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? MyColors.primaryBlue.withValues(alpha: 0.08)
            : (isDark ? const Color(0xFF111827) : MyColors.neutralGray),
        borderRadius: BorderRadius.circular(12),
        border: entry.isCurrentUser
            ? Border.all(color: MyColors.primaryBlue.withValues(alpha: 0.35))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${entry.rank}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: MyColors.kDescriptionColor,
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF374151) : MyColors.kWhiteColor,
            ),
            alignment: Alignment.center,
            child: Text(entry.avatarEmoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.isCurrentUser ? '${entry.name} (You)' : entry.name,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: entry.isCurrentUser ? FontWeight.w700 : FontWeight.w500,
                color: isDark ? Colors.white : MyColors.kBlackColor,
              ),
            ),
          ),
          Text(
            '${entry.score} XP',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MyColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
