import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TodayWaterDropCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const TodayWaterDropCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  double get _fillPercent =>
      totalCount == 0 ? 0 : (completedCount / totalCount).clamp(0.0, 1.0);

  int get _fillPercentage => (_fillPercent * 100).round();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final dayNumber = DateFormat('d').format(now);
    final monthYear = DateFormat('MMMM yyyy').format(now);
    final weekday = DateFormat('EEEE').format(now);
    final surface = isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor;

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekday,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MyColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    color: isDark ? Colors.white : MyColors.kBlackColor,
                  ),
                ),
                Text(
                  monthYear,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MyColors.kDescriptionColor,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  totalCount == 0
                      ? 'Add habits to track today'
                      : '$completedCount of $totalCount habits done',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: MyColors.kDescriptionColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_fillPercentage% complete',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: MyColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            height: 175,
            child: AnimatedWaterDropIndicator(
              fillLevel: _fillPercent,
              fillLabel: totalCount == 0 ? '0%' : '$_fillPercentage%',
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedWaterDropIndicator extends StatefulWidget {
  final double fillLevel;
  final String? fillLabel;
  final bool isDark;
  final double width;
  final double height;
  final double labelFontSize;
  final double labelTopRatio;

  const AnimatedWaterDropIndicator({
    super.key,
    required this.fillLevel,
    this.fillLabel,
    required this.isDark,
    this.width = 130,
    this.height = 175,
    this.labelFontSize = 22,
    this.labelTopRatio = 0.29,
  });

  @override
  State<AnimatedWaterDropIndicator> createState() =>
      _AnimatedWaterDropIndicatorState();
}

class _AnimatedWaterDropIndicatorState extends State<AnimatedWaterDropIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        final wavePhase = _waveController.value * math.pi * 2;
        final bob = math.sin(wavePhase * 0.6) * 1.2;
        final labelTop = widget.height * widget.labelTopRatio + bob;

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: widget.fillLevel),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, fill, _) {
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Transform.translate(
                  offset: Offset(0, bob),
                  child: CustomPaint(
                    size: Size(widget.width, widget.height),
                    painter: WaterDropPainter(
                      fillLevel: fill,
                      wavePhase: wavePhase,
                      isDark: widget.isDark,
                    ),
                  ),
                ),
                if (widget.fillLabel != null)
                  Positioned(
                    top: labelTop,
                    child: Text(
                      widget.fillLabel!,
                      style: GoogleFonts.poppins(
                        fontSize: widget.labelFontSize,
                        fontWeight: FontWeight.w800,
                        color: fill >= 0.38
                            ? Colors.white
                            : const Color(0xFF1E40AF),
                        shadows: fill >= 0.38
                            ? [
                                Shadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _WaterBubble {
  final double xRatio;
  final double phaseOffset;
  final double radius;
  final double speed;

  const _WaterBubble({
    required this.xRatio,
    required this.phaseOffset,
    required this.radius,
    required this.speed,
  });
}

const _waterBubbles = [
  _WaterBubble(xRatio: 0.22, phaseOffset: 0.0, radius: 2.0, speed: 1.0),
  _WaterBubble(xRatio: 0.45, phaseOffset: 0.35, radius: 1.6, speed: 0.85),
  _WaterBubble(xRatio: 0.62, phaseOffset: 0.62, radius: 2.4, speed: 1.15),
  _WaterBubble(xRatio: 0.78, phaseOffset: 0.18, radius: 1.8, speed: 0.95),
  _WaterBubble(xRatio: 0.35, phaseOffset: 0.82, radius: 1.4, speed: 0.75),
  _WaterBubble(xRatio: 0.55, phaseOffset: 0.48, radius: 2.1, speed: 1.05),
  _WaterBubble(xRatio: 0.28, phaseOffset: 0.55, radius: 1.7, speed: 0.9),
  _WaterBubble(xRatio: 0.70, phaseOffset: 0.72, radius: 1.5, speed: 0.8),
];

class WaterDropPainter extends CustomPainter {
  final double fillLevel;
  final double wavePhase;
  final bool isDark;

  WaterDropPainter({
    required this.fillLevel,
    required this.wavePhase,
    required this.isDark,
  });

  double _surfaceWave(double x, double width, {double amplitude = 3.2}) {
    final t = (x / width) * math.pi * 2.4 + wavePhase;
    return math.sin(t) * amplitude +
        math.sin(t * 0.65 - wavePhase * 0.8) * (amplitude * 0.35);
  }

  Path _dropPath(Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final tipY = h * 0.02;
    final baseY = h * 0.70;

    final path = Path();
    path.moveTo(cx, tipY);

    // c1 hugs the tip (sharp apex); c2 at bottom-right on baseY (round base).
    // Width bulges in the lower body, tapering smoothly toward the top point.
    path.cubicTo(
      cx + w * 0.022,
      tipY + h * 0.003,
      cx + w * 0.55,
      baseY,
      cx,
      baseY,
    );

    path.cubicTo(
      cx - w * 0.55,
      baseY,
      cx - w * 0.022,
      tipY + h * 0.003,
      cx,
      tipY,
    );

    path.close();
    return path;
  }

  /// Inside liquid path
  Path _liquidPath(Rect bounds, double level) {
    if (level <= 0) return Path();

    final clamped = level.clamp(0.0, 1.0);
    final fillTop = bounds.bottom - (bounds.height * clamped);
    final path = Path();
    path.moveTo(bounds.left, bounds.bottom);
    path.lineTo(bounds.right, bounds.bottom);

    for (var x = bounds.right; x >= bounds.left; x -= 1) {
      path.lineTo(x, fillTop + _surfaceWave(x - bounds.left, bounds.width));
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final drop = _dropPath(size);
    final bounds = drop.getBounds();
    final baseCenter = Offset(size.width * 0.5, size.height * 0.81);

    /// Bottom shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: baseCenter.translate(0, 2),
        width: size.width * 0.64,
        height: size.height * 0.09,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.10),
    );

    /// Bottom blue shadow
    final baseRect = Rect.fromCenter(
      center: baseCenter,
      width: size.width * 0.58,
      height: size.height * 0.075,
    );
    canvas.drawOval(
      baseRect,
      Paint()
        ..shader = ui.Gradient.linear(
          baseRect.topLeft,
          baseRect.bottomRight,
          const [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
          const [0.0, 0.55, 1.0],
        ),
    );

    canvas.drawShadow(drop, Colors.black.withValues(alpha: 0.18), 6, true);

    /// Top Empty space inside shape
    canvas.drawPath(
      drop,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(bounds.left, bounds.top),
          Offset(bounds.right, bounds.bottom),
          isDark
              ? const [Color(0xFF4B5563), Color(0xFF374151), Color(0xFF1F2937)]
              : const [
                  Color(0xFFF8FAFC),
                  Color(0xFFEFF6FF),
                  Color(0xFFDBEAFE),
                  Color(0xFFBFDBFE),
                ],
          isDark ? const [0.0, 0.45, 1.0] : const [0.0, 0.35, 0.7, 1.0],
        ),
    );

    canvas.save();
    canvas.clipPath(drop);

    final liquid = _liquidPath(bounds, fillLevel);
    if (!liquid.getBounds().isEmpty) {
      final fillBounds = liquid.getBounds();
      canvas.drawPath(
        liquid,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(fillBounds.left, fillBounds.top - 4),
            Offset(fillBounds.left, fillBounds.bottom),
            const [
              Color(0xFF93C5FD),
              Color(0xFF3B82F6),
              Color(0xFF2563EB),
              Color(0xFF1D4ED8),
            ],
            const [0.0, 0.35, 0.72, 1.0],
          ),
      );

      final surfaceY = fillBounds.top + 1.5;
      final wave = Path();
      for (var x = fillBounds.left; x <= fillBounds.right; x += 1) {
        final y = surfaceY +
            _surfaceWave(x - bounds.left, bounds.width, amplitude: 2.8);
        if (x == fillBounds.left) {
          wave.moveTo(x, y);
        } else {
          wave.lineTo(x, y);
        }
      }
      canvas.drawPath(
        wave,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.62)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );

      if (fillLevel > 0.05) {
        final bubbleCount =
            (8 * fillLevel).round().clamp(1, _waterBubbles.length);
        for (var i = 0; i < bubbleCount; i++) {
          final bubble = _waterBubbles[i];
          final bx = fillBounds.left + bubble.xRatio * fillBounds.width;
          final travel = fillBounds.height * 0.85;
          final normalized =
              (wavePhase * bubble.speed + bubble.phaseOffset) % 1.0;
          final by = fillBounds.bottom - (normalized * travel) - 6;
          if (by < fillBounds.top + 4) continue;

          canvas.drawCircle(
            Offset(bx, by),
            bubble.radius,
            Paint()..color = Colors.white.withValues(alpha: 0.48),
          );
        }
      }
    }

    canvas.restore();

    canvas.drawPath(
      drop,
      Paint()
        ..color = const Color(0xFF2563EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant WaterDropPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.isDark != isDark;
  }
}
