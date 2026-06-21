import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/models/habit.dart';
import 'package:Demo/models/habit_template.dart';
import 'package:Demo/providers/habits_provider.dart';
import 'package:Demo/providers/progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HabitCreationScreen extends StatefulWidget {
  const HabitCreationScreen({super.key});

  @override
  State<HabitCreationScreen> createState() => _HabitCreationScreenState();
}

class _HabitCreationScreenState extends State<HabitCreationScreen> {
  int? _selectedIndex;
  HabitFrequency _frequency = HabitFrequency.daily;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) => _themedPicker(context, child),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  Widget _themedPicker(BuildContext context, Widget? child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: MyColors.primaryBlue,
          primary: MyColors.primaryBlue,
          secondary: MyColors.accentYellow,
          surface: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      child: child!,
    );
  }

  Future<void> _pickDate({
    required bool isStart,
    required DateTime initial,
    required DateTime? min,
    required DateTime? max,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: min ?? DateTime(2020),
      lastDate: max ?? DateTime(2030),
      builder: (context, child) => _themedPicker(context, child),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 30));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _saveHabit() async {
    if (_selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pick a habit to start your journey — you\'ve got this! 💪',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: MyColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Choose an end date after your start date to keep your journey on track.',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final template = kHabitTemplates[_selectedIndex!];
    final habitsProvider = context.read<HabitsProvider>();
    final progressProvider = context.read<ProgressProvider>();
    final reminder = DateFormat('HH:mm').format(
      DateTime(2024, 1, 1, _reminderTime.hour, _reminderTime.minute),
    );

    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: template.name,
      iconPath: template.iconPath,
      color: template.color,
      frequency: _frequency,
      reminderTime: reminder,
      startDate: _startDate,
      endDate: _endDate,
    );

    await habitsProvider.addHabit(habit);
    await progressProvider.recordDay(
      date: DateTime.now(),
      completedCount: habitsProvider.completedCount,
      totalCount: habitsProvider.totalCount,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, yyyy');

    return CustomScaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : MyColors.neutralGray,
      appBar: AppBar(
        title: Text(
          'New Habit',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Choose Your Habit'),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kHabitTemplates.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final template = kHabitTemplates[index];
                final isSelected = _selectedIndex == index;

                return _HabitTemplateTile(
                  template: template,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
            const SizedBox(height: 24),
            _sectionTitle('Start & End Date'),
            Text(
              'Choose your start date to begin your journey!',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: MyColors.kDescriptionColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: 'Start Date',
                    value: dateFormat.format(_startDate),
                    onTap: () => _pickDate(
                      isStart: true,
                      initial: _startDate,
                      min: DateTime(2020),
                      max: DateTime(2030),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTile(
                    label: 'End Date',
                    value: dateFormat.format(_endDate),
                    onTap: () => _pickDate(
                      isStart: false,
                      initial: _endDate,
                      min: _startDate,
                      max: DateTime(2030),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle('Frequency'),
            _FrequencySelector(
              selected: _frequency,
              onChanged: (value) => setState(() => _frequency = value),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Reminder Time'),
            GestureDetector(
              onTap: _pickReminderTime,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white12 : MyColors.neutralGray,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: MyColors.primaryBlue),
                    const SizedBox(width: 12),
                    Text(
                      _reminderTime.format(context),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: MyColors.kDescriptionColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Create Habit',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: MyColors.kDescriptionColor,
        ),
      ),
    );
  }
}

class _HabitTemplateTile extends StatefulWidget {
  final HabitTemplate template;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _HabitTemplateTile({
    required this.template,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_HabitTemplateTile> createState() => _HabitTemplateTileState();
}

class _HabitTemplateTileState extends State<_HabitTemplateTile> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) {
        setState(() => _scale = 1);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.template.color.withValues(
              alpha: widget.isSelected ? 0.25 : 0.12,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? widget.template.color
                  : widget.template.color.withValues(alpha: 0.3),
              width: widget.isSelected ? 2.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.template.color.withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Expanded(
                child: SvgPicture.asset(
                  widget.template.iconPath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.template.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : MyColors.kBlackColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: MyColors.primaryBlue.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: MyColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: MyColors.accentYellow.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Color(0xFFB45309),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequencySelector extends StatelessWidget {
  final HabitFrequency selected;
  final ValueChanged<HabitFrequency> onChanged;

  const _FrequencySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: HabitFrequency.values.map((frequency) {
        final isSelected = selected == frequency;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: frequency != HabitFrequency.monthly ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(frequency),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? MyColors.primaryBlue
                      : (isDark
                          ? const Color(0xFF1F2937)
                          : MyColors.kWhiteColor),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? MyColors.primaryBlue
                        : (isDark ? Colors.white12 : MyColors.neutralGray),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  frequency.label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : MyColors.kBlackColor),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
