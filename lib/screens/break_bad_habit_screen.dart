import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/models/habit.dart';
import 'package:Demo/models/habit_template.dart';
import 'package:Demo/providers/habits_provider.dart';
import 'package:Demo/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BreakBadHabitScreen extends StatefulWidget {
  const BreakBadHabitScreen({super.key});

  @override
  State<BreakBadHabitScreen> createState() => _BreakBadHabitScreenState();
}

class _BreakBadHabitScreenState extends State<BreakBadHabitScreen> {
  int? _selectedIndex;
  BadHabitGoalType _goalType = BadHabitGoalType.quit;
  bool _isSaving = false;
  final _currentFrequencyController = TextEditingController(text: '5');
  final _targetFrequencyController = TextEditingController(text: '2');
  final _replacementController = TextEditingController();
  final _triggerNotesController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 90));

  @override
  void dispose() {
    _currentFrequencyController.dispose();
    _targetFrequencyController.dispose();
    _replacementController.dispose();
    _triggerNotesController.dispose();
    super.dispose();
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
          _endDate = _startDate.add(const Duration(days: 90));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _saveHabit() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    if (_selectedIndex == null) {
      _showSnack('Pick a habit you want to break first.');
      return;
    }

    final current = double.tryParse(_currentFrequencyController.text.trim());
    if (current == null || current <= 0) {
      _showSnack('Enter your current frequency (e.g. 5 cigarettes/day).');
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

    if (_endDate.isBefore(_startDate)) {
      _showSnack('End date must be after the start date.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final template = kBadHabitTemplates[_selectedIndex!];
      final unit = kBadHabitUnits[template.name] ?? 'units/day';

      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: template.name,
        iconPath: template.iconPath,
        color: template.color,
        type: HabitType.bad,
        startDate: _startDate,
        endDate: _endDate,
        baselineFrequency: current,
        targetFrequency: _goalType == BadHabitGoalType.quit ? 0 : target,
        goalType: _goalType,
        frequencyUnit: unit,
        replacementAction: _replacementController.text.trim().isEmpty
            ? null
            : _replacementController.text.trim(),
        triggerNotes: _triggerNotesController.text.trim().isEmpty
            ? null
            : _triggerNotesController.text.trim(),
      );

      await context.read<HabitsProvider>().addHabit(habit);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${template.name} added — start tracking on your home screen!',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showApiErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: MyColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, yyyy');
    final selectedUnit = _selectedIndex != null
        ? kBadHabitUnits[kBadHabitTemplates[_selectedIndex!].name]
        : 'units/day';

    return CustomScaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : MyColors.neutralGray,
      appBar: AppBar(
        title: Text(
          'Break Bad Habit',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('What do you want to break?'),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kBadHabitTemplates.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final template = kBadHabitTemplates[index];
                return _BadHabitTemplateTile(
                  template: template,
                  isSelected: _selectedIndex == index,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
            const SizedBox(height: 24),
            _sectionTitle('Current Frequency'),
            _TextFieldTile(
              controller: _currentFrequencyController,
              hint: 'e.g. 5',
              suffix: selectedUnit ?? 'units/day',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Target Goal'),
            _GoalSelector(
              goalType: _goalType,
              onChanged: (value) => setState(() => _goalType = value),
            ),
            if (_goalType == BadHabitGoalType.reduce) ...[
              const SizedBox(height: 12),
              _TextFieldTile(
                controller: _targetFrequencyController,
                hint: 'e.g. 2',
                suffix: selectedUnit ?? 'units/day',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            const SizedBox(height: 24),
            _sectionTitle('Start & End Date'),
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
            _sectionTitle('Replacement Action (optional)'),
            _TextFieldTile(
              controller: _replacementController,
              hint: 'e.g. Chew gum instead of smoking',
            ),
            const SizedBox(height: 24),
            _sectionTitle('Trigger Notes (optional)'),
            _TextFieldTile(
              controller: _triggerNotesController,
              hint: 'e.g. After meals, when stressed',
              maxLines: 3,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFFEF4444).withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Start Breaking Habit',
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

class _BadHabitTemplateTile extends StatefulWidget {
  final HabitTemplate template;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _BadHabitTemplateTile({
    required this.template,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_BadHabitTemplateTile> createState() => _BadHabitTemplateTileState();
}

class _BadHabitTemplateTileState extends State<_BadHabitTemplateTile> {
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

class _TextFieldTile extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? suffix;
  final TextInputType keyboardType;
  final int maxLines;

  const _TextFieldTile({
    required this.controller,
    required this.hint,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: MyColors.kDescriptionColor),
        suffixText: suffix,
        suffixStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: MyColors.kDescriptionColor,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : MyColors.neutralGray,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : MyColors.neutralGray,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MyColors.primaryBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _GoalSelector extends StatelessWidget {
  final BadHabitGoalType goalType;
  final ValueChanged<BadHabitGoalType> onChanged;

  const _GoalSelector({
    required this.goalType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _GoalOption(
          title: 'Quit completely',
          subtitle: 'Reduce to zero',
          isSelected: goalType == BadHabitGoalType.quit,
          isDark: isDark,
          onTap: () => onChanged(BadHabitGoalType.quit),
        ),
        const SizedBox(height: 10),
        _GoalOption(
          title: 'Reduce frequency',
          subtitle: 'Set a smaller daily target',
          isSelected: goalType == BadHabitGoalType.reduce,
          isDark: isDark,
          onTap: () => onChanged(BadHabitGoalType.reduce),
        ),
      ],
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _GoalOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? MyColors.primaryBlue.withValues(alpha: 0.1)
              : (isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? MyColors.primaryBlue
                : (isDark ? Colors.white12 : MyColors.neutralGray),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? MyColors.primaryBlue : MyColors.kDescriptionColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
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
          ],
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
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
