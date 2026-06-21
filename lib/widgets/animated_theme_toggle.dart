import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:flutter/material.dart';

class AnimatedThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const AnimatedThemeToggle({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isDark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 58,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E3A8A), const Color(0xFF312E81)]
                : [const Color(0xFFBAE6FD), MyColors.accentYellow],
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Icon(
                isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                key: ValueKey(isDark),
                size: 16,
                color: isDark
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFF59E0B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
