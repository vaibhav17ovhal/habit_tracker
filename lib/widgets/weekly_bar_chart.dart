import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../custom_widgets/custom_colors.dart';
import '../models/progress.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<DailyProgress> weekData;

  const WeeklyBarChart({super.key, required this.weekData});

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : MyColors.kBlackColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final rate = weekData[index].completionRate.clamp(0.0, 1.0);
                final barHeight = 120 * rate;
                final isToday = _isToday(weekData[index].date);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(rate * 100).round()}%',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: MyColors.kDescriptionColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _LiquidBar(
                          height: barHeight < 8 ? 8 : barHeight,
                          isToday: isToday,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _labels[index],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight:
                                isToday ? FontWeight.w600 : FontWeight.w400,
                            color: isToday
                                ? MyColors.primaryBlue
                                : MyColors.kDescriptionColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _LiquidBar extends StatelessWidget {
  final double height;
  final bool isToday;
  final bool isDark;

  const _LiquidBar({
    required this.height,
    required this.isToday,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isToday
              ? [
                  const Color(0xFF93C5FD),
                  MyColors.primaryBlue,
                  const Color(0xFF1D4ED8),
                ]
              : [
                  MyColors.primaryBlue.withValues(alpha: 0.55),
                  MyColors.primaryBlue.withValues(alpha: 0.35),
                ],
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: MyColors.primaryBlue.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Colors.white.withValues(alpha: isToday ? 0.28 : 0.12),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
