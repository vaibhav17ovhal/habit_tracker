import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../custom_widgets/custom_colors.dart';
import '../models/habit.dart';

class BadHabitReductionChart extends StatelessWidget {
  final Habit habit;
  final List<double> weekData;

  const BadHabitReductionChart({
    super.key,
    required this.habit,
    required this.weekData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseline = habit.baselineFrequency ?? 1;
    final maxY = baseline * 1.2;
    final labels = _weekdayLabels();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : MyColors.neutralGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: habit.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.trending_down_rounded,
                  color: habit.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${habit.name} Reduction',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : MyColors.kBlackColor,
                      ),
                    ),
                    Text(
                      'Last 7 days · ${habit.frequencyUnit ?? 'units'}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: MyColors.kDescriptionColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _ReductionLinePainter(
                data: weekData,
                maxY: maxY,
                targetY: habit.effectiveTarget,
                lineColor: habit.color,
                targetColor: const Color(0xFF10B981),
                gridColor: isDark ? Colors.white12 : MyColors.neutralGray,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(labels.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 140),
                      child: Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: MyColors.kDescriptionColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _weekdayLabels() {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day - (6 - i));
      return names[day.weekday - 1];
    });
  }
}

class _ReductionLinePainter extends CustomPainter {
  final List<double> data;
  final double maxY;
  final double targetY;
  final Color lineColor;
  final Color targetColor;
  final Color gridColor;

  _ReductionLinePainter({
    required this.data,
    required this.maxY,
    required this.targetY,
    required this.lineColor,
    required this.targetColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxY <= 0) return;

    final chartHeight = size.height - 24;
    final stepX = data.length <= 1 ? 0.0 : size.width / (data.length - 1);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= 3; i++) {
      final y = chartHeight * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final targetYPos = chartHeight - (targetY / maxY * chartHeight);
    final targetPaint = Paint()
      ..color = targetColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, targetYPos),
      Offset(size.width, targetYPos),
      targetPaint,
    );

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < data.length; i++) {
      final x = stepX * i;
      final y = chartHeight - (data[i] / maxY * chartHeight).clamp(0, chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(stepX * (data.length - 1), chartHeight);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.25),
            lineColor.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final dotPaint = Paint()..color = lineColor;
    for (var i = 0; i < data.length; i++) {
      final x = stepX * i;
      final y = chartHeight - (data[i] / maxY * chartHeight).clamp(0, chartHeight);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _ReductionLinePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.maxY != maxY ||
        oldDelegate.targetY != targetY;
  }
}
