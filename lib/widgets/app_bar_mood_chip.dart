import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/providers/mood_provider.dart';
import 'package:Demo/widgets/dashboard_fab_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AppBarMoodChip extends StatelessWidget {
  const AppBarMoodChip({super.key});

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();
    final today = moodProvider.todayMood;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => showMoodPickerSheet(context),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: today == null
            ? _SetMoodChip(key: const ValueKey('set'), isDark: isDark)
            : _SelectedMoodChip(
                key: ValueKey(today.label),
                emoji: today.emoji,
                label: today.label,
              ),
      ),
    );
  }
}

class _SetMoodChip extends StatelessWidget {
  final bool isDark;

  const _SetMoodChip({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColors.accentYellow.withValues(alpha: 0.35),
            MyColors.primaryBlue.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MyColors.accentYellow.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😊', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            'Set Mood',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : MyColors.kBlackColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedMoodChip extends StatelessWidget {
  final String emoji;
  final String label;

  const _SelectedMoodChip({
    super.key,
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [MyColors.primaryBlue, Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MyColors.primaryBlue.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                'Today',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
