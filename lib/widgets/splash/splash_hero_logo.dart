import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:flutter/material.dart';

/// Splash logo — pre-rendered animated GIF with counter-rotating rings.
class SplashHeroLogo extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> glowAnimation;

  static const String splashAsset = 'assets/images/splash_animated_logo.gif';

  const SplashHeroLogo({
    super.key,
    required this.scaleAnimation,
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scaleAnimation, glowAnimation]),
      builder: (context, _) {
        final scale = scaleAnimation.value;
        final glow = glowAnimation.value;

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 230,
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _GlowHalo(glow: glow),
                Image.asset(
                  splashAsset,
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlowHalo extends StatelessWidget {
  final double glow;

  const _GlowHalo({required this.glow});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160 + glow * 24,
      height: 160 + glow * 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: MyColors.primaryBlue.withValues(alpha: 0.14 + glow * 0.1),
            blurRadius: 36 + glow * 14,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: MyColors.accentYellow.withValues(alpha: 0.08 + glow * 0.06),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
