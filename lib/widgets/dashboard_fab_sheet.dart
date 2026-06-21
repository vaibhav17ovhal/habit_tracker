import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/models/mood.dart';
import 'package:Demo/providers/mood_provider.dart';
import 'package:Demo/screens/habit_creation_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void showDashboardFabSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _DashboardFabSheet(),
  );
}

void showMoodPickerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Consumer<MoodProvider>(
          builder: (context, moodProvider, _) {
            final today = moodProvider.todayMood;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: MyColors.kDescriptionColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'How are you feeling today?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : MyColors.kBlackColor,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: kMoodOptions.map((option) {
                    final isSelected = today?.label == option.label;

                    return GestureDetector(
                      onTap: () async {
                        await moodProvider.selectMood(
                          option.label,
                          option.emoji,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 72,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? MyColors.primaryBlue.withValues(alpha: 0.12)
                              : (isDark
                                  ? const Color(0xFF374151)
                                  : MyColors.neutralGray),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? MyColors.primaryBlue
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(option.emoji,
                                style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 4),
                            Text(
                              option.label,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? MyColors.primaryBlue
                                    : MyColors.kDescriptionColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

class _DashboardFabSheet extends StatelessWidget {
  const _DashboardFabSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: MyColors.kDescriptionColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              children: [
                Text(
                  'Quick Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : MyColors.kBlackColor,
                  ),
                ),
                const SizedBox(height: 16),
                _FabOptionTile(
                  icon: Icons.add_circle_outline_rounded,
                  iconColor: MyColors.primaryBlue,
                  title: 'Add New Habit',
                  subtitle: 'Create a habit from templates',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HabitCreationScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _FabOptionTile(
                  icon: Icons.mood_rounded,
                  iconColor: MyColors.accentYellow,
                  title: "Today's Mood",
                  subtitle: 'Log how you feel right now',
                  onTap: () {
                    Navigator.pop(context);
                    showMoodPickerSheet(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FabOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FabOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF374151) : MyColors.neutralGray,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : MyColors.kBlackColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: MyColors.kDescriptionColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: MyColors.kDescriptionColor),
            ],
          ),
        ),
      ),
    );
  }
}
