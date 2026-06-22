import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Animated hero logo: Lottie ring + pulsing app icon.
class SplashHeroLogo extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> glowAnimation;

  const SplashHeroLogo({
    super.key,
    required this.scaleAnimation,
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scaleAnimation, glowAnimation]),
      builder: (context, child) {
        final scale = scaleAnimation.value;
        final glow = glowAnimation.value;

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft glow behind logo
                Container(
                  width: 150 + glow * 20,
                  height: 150 + glow * 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: MyColors.primaryBlue
                            .withValues(alpha: 0.15 + glow * 0.12),
                        blurRadius: 32 + glow * 16,
                        spreadRadius: 4 + glow * 6,
                      ),
                      BoxShadow(
                        color: MyColors.accentYellow
                            .withValues(alpha: 0.12 + glow * 0.08),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Lottie spinner ring
                Lottie.asset(
                  'assets/lottie/splash_hero.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
                // App logo
                Container(
                  width: 108,
                  height: 108,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: MyColors.primaryBlue.withValues(alpha: 0.12),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MyColors.primaryBlue.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/app_logo_img.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
