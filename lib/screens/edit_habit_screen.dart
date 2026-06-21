import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/models/habit.dart';
import 'package:Demo/providers/habits_provider.dart';
import 'package:Demo/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late HabitFrequency _frequency;
  late TimeOfDay _reminderTime;
  late DateTime _startDate;
  late DateTime _endDate;
  late BadHabitGoalType _goalType;
  late TextEditingController _currentFrequencyController;
  late TextEditingController _targetFrequencyController;
  late TextEditingController _replacementController;
  late TextEditingController _triggerNotesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    _frequency = habit.frequency;
    _reminderTime = _parseReminderTime(habit.reminderTime);
    _startDate = habit.startDate ?? DateTime.now();
    _endDate = habit.endDate ?? DateTime.now().add(const Duration(days: 30));
    _goalType = habit.goalType ?? BadHabitGoalType.quit;
    _currentFrequencyController = TextEditingController(
      text: habit.baselineFrequency?.toString() ?? '',
    );
    _targetFrequencyController = TextEditingController(
      text: habit.targetFrequency?.toString() ?? '',
    );
    _replacementController = TextEditingController(
      text: habit.replacementAction ?? '',
    );
    _triggerNotesController = TextEditingController(
      text: habit.triggerNotes ?? '',
    );
  }

  @override
  void dispose() {
    _currentFrequencyController.dispose();
    _targetFrequencyController.dispose();
    _replacementController.dispose();
    _triggerNotesController.dispose();
    super.dispose();
  }

  TimeOfDay _parseReminderTime(String? value) {
    if (value == null || value.isEmpty) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
    final parts = value.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 8, minute: 0);
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

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) => _themedPicker(context, child),
    );
    if (picked != null) setState(() => _reminderTime = picked);
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

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: MyColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();

    if (_endDate.isBefore(_startDate)) {
      _showSnack('End date must be after the start date.');
      return;
    }

    final reminder = DateFormat('HH:mm').format(
      DateTime(2024, 1, 1, _reminderTime.hour, _reminderTime.minute),
    );

    Habit updated;

    if (widget.habit.isBadHabit) {
      final current = double.tryParse(_currentFrequencyController.text.trim());
      if (current == null || current <= 0) {
        _showSnack('Enter your current frequency.');
        return;
      }

      double? target;
      if (_goalType == BadHabitGoalType.reduce) {
        target = double.tryParse(_targetFrequencyController.text.trim());
        if (target == null || target < 0 || target >= current) {
          _showSnack('Target must be less than your current frequency.');
          return;
        }
      }

      updated = widget.habit.copyWith(
        startDate: _startDate,
        endDate: _endDate,
        baselineFrequency: current,
        targetFrequency: _goalType == BadHabitGoalType.quit ? 0 : target,
        goalType: _goalType,
        replacementAction: _replacementController.text.trim().isEmpty
            ? null
            : _replacementController.text.trim(),
        triggerNotes: _triggerNotesController.text.trim().isEmpty
            ? null
            : _triggerNotesController.text.trim(),
      );
    } else {
      updated = widget.habit.copyWith(
        frequency: _frequency,
        reminderTime: reminder,
        startDate: _startDate,
        endDate: _endDate,
      );
    }

    setState(() => _isSaving = true);

    try {
      await context.read<HabitsProvider>().updateHabit(updated);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Habit updated successfully',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showApiErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, yyyy');

    return CustomScaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : MyColors.neutralGray,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        elevation: 0,
        title: Text(
          'Edit Habit',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : MyColors.kBlackColor,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : MyColors.kBlackColor,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HabitHeader(habit: habit),
          const SizedBox(height: 24),
          if (habit.isBadHabit) ...[
            _SectionLabel('Goal'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _GoalChip(
                    label: 'Quit completely',
                    selected: _goalType == BadHabitGoalType.quit,
                    onTap: () =>
                        setState(() => _goalType = BadHabitGoalType.quit),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _GoalChip(
                    label: 'Reduce gradually',
                    selected: _goalType == BadHabitGoalType.reduce,
                    onTap: () =>
                        setState(() => _goalType = BadHabitGoalType.reduce),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionLabel('Current frequency (${habit.frequencyUnit ?? 'units/day'})'),
            const SizedBox(height: 8),
            _TextField(controller: _currentFrequencyController, keyboardType: TextInputType.number),
            if (_goalType == BadHabitGoalType.reduce) ...[
              const SizedBox(height: 16),
              _SectionLabel('Target frequency'),
              const SizedBox(height: 8),
              _TextField(
                controller: _targetFrequencyController,
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            _SectionLabel('Replacement action (optional)'),
            const SizedBox(height: 8),
            _TextField(
              controller: _replacementController,
              hint: 'e.g. Chew gum instead',
            ),
            const SizedBox(height: 16),
            _SectionLabel('Trigger notes (optional)'),
            const SizedBox(height: 8),
            _TextField(
              controller: _triggerNotesController,
              hint: 'When do you usually do this?',
              maxLines: 2,
            ),
          ] else ...[
            _SectionLabel('Frequency'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: HabitFrequency.values.map((freq) {
                return ChoiceChip(
                  label: Text(freq.label, style: GoogleFonts.poppins(fontSize: 13)),
                  selected: _frequency == freq,
                  onSelected: (_) => setState(() => _frequency = freq),
                  selectedColor: MyColors.primaryBlue.withValues(alpha: 0.15),
                  labelStyle: GoogleFonts.poppins(
                    color: _frequency == freq
                        ? MyColors.primaryBlue
                        : (isDark ? Colors.white70 : MyColors.kDescriptionColor),
                    fontWeight: _frequency == freq
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  side: BorderSide(
                    color: _frequency == freq
                        ? MyColors.primaryBlue
                        : MyColors.kTextFieldBorderColor,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Daily reminder'),
            const SizedBox(height: 8),
            _DateTimeTile(
              icon: Icons.access_time_rounded,
              label: _reminderTime.format(context),
              onTap: _pickReminderTime,
            ),
          ],
          const SizedBox(height: 20),
          _SectionLabel('Start date'),
          const SizedBox(height: 8),
          _DateTimeTile(
            icon: Icons.calendar_today_rounded,
            label: dateFormat.format(_startDate),
            onTap: () => _pickDate(isStart: true, initial: _startDate, min: null, max: _endDate),
          ),
          const SizedBox(height: 16),
          _SectionLabel('End date'),
          const SizedBox(height: 8),
          _DateTimeTile(
            icon: Icons.event_rounded,
            label: dateFormat.format(_endDate),
            onTap: () => _pickDate(isStart: false, initial: _endDate, min: _startDate, max: null),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save Changes',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitHeader extends StatelessWidget {
  final Habit habit;

  const _HabitHeader({required this.habit});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColors.neutralGray.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: habit.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: SvgPicture.asset(habit.iconPath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : MyColors.kBlackColor,
                  ),
                ),
                Text(
                  habit.isBadHabit ? 'Bad habit' : 'Good habit',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: MyColors.kDescriptionColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : MyColors.kBlackColor,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;

  const _TextField({
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
        color: isDark ? Colors.white : MyColors.kBlackColor,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: MyColors.kDescriptionColor),
        filled: true,
        fillColor: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: MyColors.kTextFieldBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: MyColors.kTextFieldBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MyColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MyColors.kTextFieldBorderColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: MyColors.primaryBlue, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: isDark ? Colors.white : MyColors.kBlackColor,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  color: MyColors.kDescriptionColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GoalChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: selected
          ? MyColors.primaryBlue.withValues(alpha: 0.12)
          : (isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? MyColors.primaryBlue
                  : MyColors.kTextFieldBorderColor,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected
                  ? MyColors.primaryBlue
                  : (isDark ? Colors.white70 : MyColors.kDescriptionColor),
            ),
          ),
        ),
      ),
    );
  }
}
