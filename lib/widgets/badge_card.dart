import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/models/reward.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BadgeCard extends StatelessWidget {
  final RewardBadge badge;
  final int currentStreak;

  const BadgeCard({
    super.key,
    required this.badge,
    required this.currentStreak,
  });

  double get _progress =>
      (currentStreak / badge.requiredStreak).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: badge.isUnlocked
            ? (isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor)
            : (isDark ? const Color(0xFF111827) : MyColors.kWhiteColor),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: badge.isUnlocked
              ? MyColors.primaryBlue.withValues(alpha: 0.4)
              : (isDark ? Colors.white12 : MyColors.neutralGray),
          width: badge.isUnlocked ? 1.5 : 1,
        ),
        boxShadow: badge.isUnlocked
            ? [
                BoxShadow(
                  color: MyColors.primaryBlue.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(
            opacity: badge.isUnlocked ? 1 : 0.45,
            child: Text(
              badge.emoji,
              style: const TextStyle(fontSize: 56),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: badge.isUnlocked
                  ? (isDark ? Colors.white : MyColors.kBlackColor)
                  : MyColors.kDescriptionColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.4,
              color: MyColors.kDescriptionColor,
            ),
          ),
          const SizedBox(height: 16),
          if (!badge.isUnlocked) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                backgroundColor: MyColors.neutralGray,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  MyColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$currentStreak / ${badge.requiredStreak} days',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: MyColors.kDescriptionColor,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: badge.isUnlocked
                  ? MyColors.accentYellow.withValues(alpha: 0.25)
                  : MyColors.neutralGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  badge.isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline,
                  size: 14,
                  color: badge.isUnlocked
                      ? MyColors.primaryBlue
                      : MyColors.kDescriptionColor,
                ),
                const SizedBox(width: 6),
                Text(
                  badge.isUnlocked
                      ? 'Unlocked'
                      : 'Need ${badge.requiredStreak}-day streak',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: badge.isUnlocked
                        ? MyColors.primaryBlue
                        : MyColors.kDescriptionColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
