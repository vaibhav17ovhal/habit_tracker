import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/habit.dart';
import '../widgets/habit_card_menu.dart';
import 'custom_colors.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColors.neutralGray.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: habit.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: SvgPicture.asset(
              habit.iconPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : MyColors.kBlackColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 18,
                      color: MyColors.accentYellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${habit.streak} day streak',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: MyColors.kDescriptionColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onEdit != null && onDelete != null)
            HabitCardMenu(onEdit: onEdit!, onDelete: onDelete!),
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: habit.isCompletedToday,
              activeColor: MyColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: BorderSide(
                color: habit.isCompletedToday
                    ? MyColors.primaryBlue
                    : MyColors.kTextFieldBorderColor,
                width: 1.5,
              ),
              onChanged: (value) => onToggle(value ?? false),
            ),
          ),
        ],
      ),
    );
  }
}
