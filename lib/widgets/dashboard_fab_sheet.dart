import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/models/mood.dart';
import 'package:Demo/providers/mood_provider.dart';
import 'package:Demo/screens/habit_creation_screen.dart';
import 'package:Demo/utils/app_page_route.dart';
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
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : MyColors.kBlackColor,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: kMoodOptions.map((option) {
                    final isSelected = today?.label == option.label;
                    return _AnimatedMoodOption(
                      option: option,
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () async {
                        await moodProvider.selectMood(
                          option.label,
                          option.emoji,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
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

class _AnimatedMoodOption extends StatefulWidget {
  final MoodOption option;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _AnimatedMoodOption({
    required this.option,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_AnimatedMoodOption> createState() => _AnimatedMoodOptionState();
}

class _AnimatedMoodOptionState extends State<_AnimatedMoodOption>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  double _tapScale = 1;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.isSelected) {
      _bounceController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedMoodOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _bounceController.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _bounceController.stop();
      _bounceController.value = 0;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    setState(() => _tapScale = 0.88);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _tapScale = 1);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _tapScale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: AnimatedBuilder(
          animation: _bounceController,
          builder: (context, child) {
            final bounce = widget.isSelected
                ? 1 + (_bounceController.value * 0.08)
                : 1.0;
            return Transform.scale(
              scale: bounce,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? MyColors.primaryBlue.withValues(alpha: 0.12)
                  : (widget.isDark
                      ? const Color(0xFF374151)
                      : MyColors.neutralGray),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isSelected
                    ? MyColors.primaryBlue
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: MyColors.primaryBlue.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Text(widget.option.emoji,
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  widget.option.label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected
                        ? MyColors.primaryBlue
                        : MyColors.kDescriptionColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
                    fontWeight: FontWeight.w600,
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
                      AppPageRoute(page: const HabitCreationScreen()),
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
                        fontWeight: FontWeight.w400,
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
