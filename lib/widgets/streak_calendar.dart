import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../custom_widgets/custom_colors.dart';

class StreakCalendar extends StatelessWidget {
  final DateTime month;
  final Set<int> completedDays;

  const StreakCalendar({
    super.key,
    required this.month,
    required this.completedDays,
  });

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    final leadingEmpty = firstWeekday - 1;
    final today = DateTime.now();
    final totalCells = leadingEmpty + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Container(
      width: double.infinity,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Streak Calendar',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : MyColors.kBlackColor,
                  ),
                ),
              ),
              Text(
                _monthLabel(month),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MyColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(7, (index) {
              return Expanded(
                child: Center(
                  child: Text(
                    _weekdays[index],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: MyColors.kDescriptionColor,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const cellGap = 8.0;
              final cellSize = (constraints.maxWidth - (cellGap * 6)) / 7;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(rowCount, (row) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: row < rowCount - 1 ? cellGap : 0,
                    ),
                    child: Row(
                      children: List.generate(7, (col) {
                        final index = row * 7 + col;
                        final isEmpty =
                            index < leadingEmpty || index >= totalCells;

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: col < 6 ? cellGap : 0,
                            ),
                            child: isEmpty
                                ? SizedBox(height: cellSize)
                                : _DayCell(
                                    day: index - leadingEmpty + 1,
                                    size: cellSize,
                                    isCompleted: completedDays
                                        .contains(index - leadingEmpty + 1),
                                    isToday: today.year == month.year &&
                                        today.month == month.month &&
                                        today.day == index - leadingEmpty + 1,
                                    isDark: isDark,
                                  ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _legendDot(MyColors.primaryBlue, 'Completed'),
              const SizedBox(width: 16),
              _legendDot(MyColors.accentYellow, 'Today'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: MyColors.kDescriptionColor,
          ),
        ),
      ],
    );
  }

  String _monthLabel(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final double size;
  final bool isCompleted;
  final bool isToday;
  final bool isDark;

  const _DayCell({
    required this.day,
    required this.size,
    required this.isCompleted,
    required this.isToday,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isCompleted
              ? MyColors.primaryBlue
              : isToday
                  ? MyColors.accentYellow.withValues(alpha: 0.35)
                  : (isDark ? const Color(0xFF374151) : MyColors.neutralGray),
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(
                  color: MyColors.accentYellow,
                  width: 1.5,
                )
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isCompleted
                  ? Colors.white
                  : (isDark ? Colors.white70 : MyColors.kBlackColor),
            ),
          ),
        ),
      ),
    );
  }
}
