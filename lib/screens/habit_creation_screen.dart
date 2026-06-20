import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/models/habit.dart';
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
  final _nameController = TextEditingController();
  HabitFrequency _frequency = HabitFrequency.daily;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;

  static const _icons = [
    'assets/habit_icon/Meditation-bro.svg',
    'assets/habit_icon/Cross country race-pana.svg',
    'assets/habit_icon/Book lover-amico.svg',
    'assets/break_habit_icon/stop_smoking_icon.svg',
    'assets/break_habit_icon/limit_junk_food_icon.svg',
    'assets/habit_icon/Insomnia-amico.svg',
    'assets/habit_icon/Yoga practice-bro.svg',
    'assets/habit_icon/Hydratation-rafiki.svg',
  ];

  static const _colors = [
    MyColors.primaryBlue,
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFF6366F1),
    Color(0xFFEC4899),
    MyColors.accentYellow,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: MyColors.primaryBlue,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  Future<void> _saveHabit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a habit name',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: MyColors.primaryBlue,
        ),
      );
      return;
    }

    final habitsProvider = context.read<HabitsProvider>();
    final progressProvider = context.read<ProgressProvider>();
    final reminder = DateFormat('HH:mm').format(
      DateTime(2024, 1, 1, _reminderTime.hour, _reminderTime.minute),
    );

    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      iconPath: _icons[_selectedIconIndex],
      color: _colors[_selectedColorIndex],
      frequency: _frequency,
      reminderTime: reminder,
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
            _sectionTitle('Habit Name'),
            TextField(
              controller: _nameController,
              style: GoogleFonts.poppins(),
              decoration: _inputDecoration('e.g. Meditate, Run, Read'),
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
                  color: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
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
                    Icon(Icons.chevron_right,
                        color: MyColors.kDescriptionColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Choose Icon'),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final selected = _selectedIconIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 72,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? _colors[_selectedColorIndex]
                                .withValues(alpha: 0.15)
                            : (isDark
                                ? const Color(0xFF1F2937)
                                : MyColors.kWhiteColor),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? _colors[_selectedColorIndex]
                              : (isDark
                                  ? Colors.white12
                                  : MyColors.neutralGray),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: SvgPicture.asset(_icons[index]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Choose Color'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(_colors.length, (index) {
                final selected = _selectedColorIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _colors[index],
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: MyColors.kBlackColor, width: 3)
                          : null,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: _colors[index].withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }),
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

  InputDecoration _inputDecoration(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: MyColors.kTextFieldHintTextColor),
      filled: true,
      fillColor: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
