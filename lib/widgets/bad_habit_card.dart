import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/custom_colors.dart';
import '../models/habit.dart';
import '../providers/habits_provider.dart';

class BadHabitCard extends StatelessWidget {
  final Habit habit;

  const BadHabitCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final habitsProvider = context.read<HabitsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseline = habit.baselineFrequency ?? 0;
    final target = habit.effectiveTarget;
    final today = habit.todayLoggedCount;
    final message = habitsProvider.motivationalMessageFor(habit);
    final unit = habit.frequencyUnit ?? 'units/day';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: habit.isOnTargetToday
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : MyColors.neutralGray.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: habit.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SvgPicture.asset(habit.iconPath, fit: BoxFit.contain),
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
                    Text(
                      '${_formatNum(baseline)} → ${_formatNum(target)} $unit',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: MyColors.kDescriptionColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: MyColors.accentYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${habit.daysOnTarget}d on target',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CountButton(
                icon: Icons.remove_rounded,
                onTap: () => habitsProvider.updateBadHabitCount(
                  habit.id,
                  today - 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'Today',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: MyColors.kDescriptionColor,
                      ),
                    ),
                    Text(
                      _formatNum(today),
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: habit.isOnTargetToday
                            ? const Color(0xFF10B981)
                            : MyColors.primaryBlue,
                      ),
                    ),
                    Text(
                      unit,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: MyColors.kDescriptionColor,
                      ),
                    ),
                  ],
                ),
              ),
              _CountButton(
                icon: Icons.add_rounded,
                onTap: () => habitsProvider.updateBadHabitCount(
                  habit.id,
                  today + 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: habit.reductionProgress,
              minHeight: 8,
              backgroundColor: MyColors.neutralGray,
              valueColor: AlwaysStoppedAnimation<Color>(
                habit.isOnTargetToday
                    ? const Color(0xFF10B981)
                    : MyColors.primaryBlue,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: MyColors.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: MyColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (habit.replacementAction != null &&
              habit.replacementAction!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Try instead: ${habit.replacementAction}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: MyColors.kDescriptionColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatNum(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1);
  }
}

class _CountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CountButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MyColors.primaryBlue.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: MyColors.primaryBlue),
        ),
      ),
    );
  }
}
