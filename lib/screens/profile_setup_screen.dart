import 'dart:convert';
import 'dart:io';

import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/providers/dashboard_provider.dart';
import 'package:Demo/providers/user_provider.dart';
import 'package:Demo/screens/dashboard_screen.dart';
import 'package:Demo/services/api_service.dart';
import 'package:Demo/utils/app_page_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _picker = ImagePicker();

  File? _profileImage;
  DateTime? _dob;
  String? _gender;
  String _primaryGoal = 'build_good_habits';
  String _routinePreference = 'morning';
  bool _notificationsEnabled = true;
  bool _isDarkTheme = false;
  int _weeklyTarget = 5;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  final Set<String> _categories = {'Fitness', 'Mindfulness'};
  bool _isSubmitting = false;
  double _uploadProgress = 0;

  static const _goals = {
    'build_good_habits': 'Build good habits',
    'break_bad_habits': 'Break bad habits',
    'track_mood': 'Track mood',
  };

  static const _allCategories = [
    'Fitness',
    'Study',
    'Mindfulness',
    'Productivity',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _profileImage = File(picked.path));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded,
                    color: MyColors.primaryBlue),
                title: Text('Take Photo', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: MyColors.primaryBlue),
                title: Text('Choose from Gallery', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: MyColors.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  String? _validateUsername(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Username is required';
    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(text)) {
      return 'Use 3-20 letters, numbers, or underscores';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();

    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add a profile picture',
              style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please select your date of birth', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Select at least one habit category',
              style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.2;
    });

    try {
      final bytes = await _profileImage!.readAsBytes();
      setState(() => _uploadProgress = 0.55);

      final base64Avatar =
          'data:image/jpeg;base64,${base64Encode(bytes)}';
      final reminder = DateFormat('HH:mm').format(
        DateTime(2024, 1, 1, _reminderTime.hour, _reminderTime.minute),
      );

      setState(() => _uploadProgress = 0.75);

      final profileData = {
        'avatar': base64Avatar,
        'username': _usernameController.text.trim().toLowerCase(),
        'dob': _dob!.toIso8601String(),
        'gender': _gender ?? '',
        'primaryGoal': _primaryGoal,
        'routinePreference': _routinePreference,
        'notificationsEnabled': _notificationsEnabled,
        'reminderTime': reminder,
        'theme': _isDarkTheme ? 'dark' : 'light',
        'weeklyTarget': _weeklyTarget,
        'defaultCategories': _categories.toList(),
      };

      await context.read<UserProvider>().completeProfileSetup(profileData);
      context.read<DashboardProvider>().reset();

      if (!mounted) return;
      setState(() => _uploadProgress = 1);

      Navigator.pushAndRemoveUntil(
        context,
        AppPageRoute(page: const DashboardScreen()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) showApiErrorSnackBar(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _uploadProgress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, yyyy');

    return PopScope(
      canPop: false,
      child: CustomScaffold(
        backgroundColor:
            isDark ? const Color(0xFF111827) : MyColors.neutralGray,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor:
              isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
          elevation: 0,
          title: Text(
            'Set Up Your Profile',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : MyColors.kBlackColor,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                'Tell us about yourself so we can personalize your habit journey.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: MyColors.kDescriptionColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Center(child: _buildAvatarPicker(isDark)),
              if (_isSubmitting) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _uploadProgress > 0 ? _uploadProgress : null,
                    minHeight: 6,
                    backgroundColor: MyColors.neutralGray,
                    valueColor: const AlwaysStoppedAnimation(
                      MyColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Uploading profile...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: MyColors.kDescriptionColor,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              _SectionTitle('Username', isDark: isDark),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _usernameController,
                hint: 'e.g. habit_hero42',
                prefixText: '@',
                validator: _validateUsername,
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              _SectionTitle('Date of Birth', isDark: isDark),
              const SizedBox(height: 8),
              _PickerTile(
                label: _dob == null ? 'Select date of birth' : dateFormat.format(_dob!),
                icon: Icons.cake_outlined,
                onTap: _pickDob,
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              _SectionTitle('Gender (optional)', isDark: isDark),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: _inputDecoration(isDark, hint: 'Prefer not to say'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                  DropdownMenuItem(
                    value: 'prefer_not_to_say',
                    child: Text('Prefer not to say'),
                  ),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 20),
              _SectionTitle('Primary Goal', isDark: isDark),
              const SizedBox(height: 8),
              ..._goals.entries.map(
                (e) => RadioListTile<String>(
                  value: e.key,
                  groupValue: _primaryGoal,
                  activeColor: MyColors.primaryBlue,
                  title: Text(e.value, style: GoogleFonts.poppins(fontSize: 14)),
                  onChanged: (v) => setState(() => _primaryGoal = v!),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 12),
              _SectionTitle('Daily Routine Preference', isDark: isDark),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ChoiceChip(
                      label: 'Morning',
                      selected: _routinePreference == 'morning',
                      onTap: () =>
                          setState(() => _routinePreference = 'morning'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ChoiceChip(
                      label: 'Evening',
                      selected: _routinePreference == 'evening',
                      onTap: () =>
                          setState(() => _routinePreference = 'evening'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle('Notifications', isDark: isDark),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _notificationsEnabled,
                activeThumbColor: MyColors.primaryBlue,
                title: Text(
                  'Enable habit reminders',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
              if (_notificationsEnabled) ...[
                const SizedBox(height: 4),
                _PickerTile(
                  label: _reminderTime.format(context),
                  icon: Icons.access_time_rounded,
                  onTap: _pickReminderTime,
                  isDark: isDark,
                ),
              ],
              const SizedBox(height: 20),
              _SectionTitle('Theme Preference', isDark: isDark),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isDarkTheme,
                activeThumbColor: MyColors.primaryBlue,
                title: Text('Dark mode', style: GoogleFonts.poppins(fontSize: 14)),
                onChanged: (v) => setState(() => _isDarkTheme = v),
              ),
              const SizedBox(height: 20),
              _SectionTitle('Weekly Target', isDark: isDark),
              Text(
                '$_weeklyTarget habits per week',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MyColors.primaryBlue,
                ),
              ),
              Slider(
                value: _weeklyTarget.toDouble(),
                min: 1,
                max: 14,
                divisions: 13,
                activeColor: MyColors.primaryBlue,
                label: '$_weeklyTarget',
                onChanged: (v) => setState(() => _weeklyTarget = v.round()),
              ),
              const SizedBox(height: 12),
              _SectionTitle('Default Habit Categories', isDark: isDark),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allCategories.map((cat) {
                  final selected = _categories.contains(cat);
                  return FilterChip(
                    label: Text(cat, style: GoogleFonts.poppins(fontSize: 13)),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _categories.add(cat);
                        } else {
                          _categories.remove(cat);
                        }
                      });
                    },
                    selectedColor: MyColors.primaryBlue.withValues(alpha: 0.15),
                    checkmarkColor: MyColors.primaryBlue,
                    side: BorderSide(
                      color: selected
                          ? MyColors.primaryBlue
                          : MyColors.kTextFieldBorderColor,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Complete Setup',
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
      ),
    );
  }

  Widget _buildAvatarPicker(bool isDark) {
    return GestureDetector(
      onTap: _isSubmitting ? null : _showImageSourceSheet,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              border: Border.all(
                color: _profileImage == null
                    ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                    : MyColors.primaryBlue.withValues(alpha: 0.4),
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
            child: ClipOval(
              child: _profileImage != null
                  ? Image.file(_profileImage!, fit: BoxFit.cover)
                  : Icon(
                      Icons.person_rounded,
                      size: 56,
                      color: MyColors.kDescriptionColor.withValues(alpha: 0.5),
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: MyColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.poppins(
        color: isDark ? Colors.white : MyColors.kBlackColor,
      ),
      decoration: _inputDecoration(isDark, hint: hint).copyWith(
        prefixText: prefixText,
        prefixStyle: GoogleFonts.poppins(
          color: MyColors.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: MyColors.kDescriptionColor),
      filled: true,
      fillColor: isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MyColors.kTextFieldBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MyColors.kTextFieldBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MyColors.primaryBlue, width: 1.5),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SectionTitle(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
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

class _PickerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _PickerTile({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.white : MyColors.kBlackColor,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: MyColors.kDescriptionColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? MyColors.primaryBlue
                  : MyColors.kTextFieldBorderColor,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? MyColors.primaryBlue
                    : (isDark ? Colors.white70 : MyColors.kDescriptionColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
