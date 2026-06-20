import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../custom_widgets/custom_colors.dart';
import '../models/reward.dart';

class BadgeCard extends StatelessWidget {
  final RewardBadge badge;

  const BadgeCard({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: badge.isUnlocked
            ? (isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor)
            : (isDark ? const Color(0xFF111827) : MyColors.neutralGray),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: badge.isUnlocked
              ? MyColors.primaryBlue.withValues(alpha: 0.35)
              : (isDark ? Colors.white12 : MyColors.neutralGray),
        ),
        boxShadow: badge.isUnlocked
            ? [
                BoxShadow(
                  color: MyColors.primaryBlue.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: badge.isUnlocked
                  ? MyColors.accentYellow.withValues(alpha: 0.25)
                  : Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              badge.icon,
              color: badge.isUnlocked
                  ? MyColors.accentYellow
                  : MyColors.kDescriptionColor,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: badge.isUnlocked
                  ? (isDark ? Colors.white : MyColors.kBlackColor)
                  : MyColors.kDescriptionColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              height: 1.3,
              color: MyColors.kDescriptionColor,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                badge.isUnlocked ? Icons.check_circle : Icons.lock_outline,
                size: 14,
                color: badge.isUnlocked
                    ? MyColors.primaryBlue
                    : MyColors.kDescriptionColor,
              ),
              const SizedBox(width: 4),
              Text(
                badge.isUnlocked ? 'Unlocked' : '${badge.requiredStreak}+ days',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: badge.isUnlocked
                      ? MyColors.primaryBlue
                      : MyColors.kDescriptionColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
