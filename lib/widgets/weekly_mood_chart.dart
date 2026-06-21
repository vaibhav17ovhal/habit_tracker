import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/models/mood.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyMoodChart extends StatelessWidget {
  final List<MoodEntry?> weekMoods;

  const WeeklyMoodChart({super.key, required this.weekMoods});

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : MyColors.neutralGray.withValues(alpha: 0.9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Mood Trend',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : MyColors.kBlackColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final mood = weekMoods[index];
              final isToday = _isToday(index);

              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: mood != null
                          ? MyColors.accentYellow.withValues(alpha: 0.2)
                          : (isDark
                              ? const Color(0xFF374151)
                              : MyColors.neutralGray),
                      borderRadius: BorderRadius.circular(12),
                      border: isToday
                          ? Border.all(color: MyColors.primaryBlue, width: 1.5)
                          : null,
                    ),
                    child: Text(
                      mood?.emoji ?? '—',
                      style: TextStyle(
                        fontSize: mood != null ? 22 : 16,
                        color: mood != null
                            ? null
                            : MyColors.kDescriptionColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _labels[index],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isToday
                          ? MyColors.primaryBlue
                          : MyColors.kDescriptionColor,
                    ),
                  ),
                  if (mood != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      mood.label,
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        color: MyColors.kDescriptionColor,
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _isToday(int index) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final day = DateTime(start.year, start.month, start.day + index);
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }
}
