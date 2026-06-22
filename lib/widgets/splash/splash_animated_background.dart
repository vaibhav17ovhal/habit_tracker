import 'dart:math' as math;

import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:flutter/material.dart';

/// Soft animated gradient background with floating brand-colored orbs.
class SplashAnimatedBackground extends StatefulWidget {
  final Animation<double> animation;

  const SplashAnimatedBackground({
    super.key,
    required this.animation,
  });

  @override
  State<SplashAnimatedBackground> createState() =>
      _SplashAnimatedBackgroundState();
}

class _SplashAnimatedBackgroundState extends State<SplashAnimatedBackground> {
  static const _skyTop = Color(0xFFEFF6FF);
  static const _skyMid = Color(0xFFF8FAFC);
  static const _warmGlow = Color(0xFFFEF9C3);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, _) {
        final t = widget.animation.value;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(_skyTop, _warmGlow, math.sin(t * math.pi) * 0.15)!,
                Color.lerp(_skyMid, MyColors.neutralGray, 0.4)!,
                Color.lerp(
                  MyColors.neutralGray,
                  _warmGlow.withValues(alpha: 0.6),
                  math.cos(t * math.pi * 0.8) * 0.2 + 0.2,
                )!,
              ],
            ),
          ),
          child: Stack(
            children: [
              _Orb(
                color: MyColors.primaryBlue.withValues(alpha: 0.18),
                size: 220,
                offset: Offset(
                  -80 + math.sin(t * math.pi * 2) * 24,
                  -120 + math.cos(t * math.pi * 2) * 18,
                ),
              ),
              _Orb(
                color: MyColors.accentYellow.withValues(alpha: 0.22),
                size: 180,
                offset: Offset(
                  MediaQuery.sizeOf(context).width - 100 +
                      math.cos(t * math.pi * 2) * 20,
                  80 + math.sin(t * math.pi * 2) * 16,
                ),
              ),
              _Orb(
                color: MyColors.primaryBlue.withValues(alpha: 0.08),
                size: 300,
                offset: Offset(
                  MediaQuery.sizeOf(context).width * 0.25,
                  MediaQuery.sizeOf(context).height * 0.55 +
                      math.sin(t * math.pi) * 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double size;
  final Offset offset;

  const _Orb({
    required this.color,
    required this.size,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.35,
              spreadRadius: size * 0.05,
            ),
          ],
        ),
      ),
    );
  }
}
