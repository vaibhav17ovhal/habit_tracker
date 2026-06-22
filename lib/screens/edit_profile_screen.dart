import 'dart:convert';
import 'dart:io';

import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/custom_widgets/custom_scaffold.dart';
import 'package:Demo/models/user.dart';
import 'package:Demo/providers/user_provider.dart';
import 'package:Demo/services/api_service.dart';
import 'package:Demo/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _picker = ImagePicker();

  File? _newProfileImage;
  String _existingAvatarPath = '';
  DateTime? _dob;
  String? _gender;
  String _primaryGoal = 'build_good_habits';
  String _routinePreference = 'morning';
  bool _notificationsEnabled = true;
  bool _isDarkTheme = false;
  int _weeklyTarget = 5;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  final Set<String> _categories = {};
  bool _isLoading = true;
  bool _isSaving = false;
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  TimeOfDay _parseReminderTime(String? value) {
    if (value == null || value.isEmpty) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
    final parts = value.split(':');
    if (parts.length >= 2) {
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return const TimeOfDay(hour: 8, minute: 0);
  }

  void _applyUser(AppUser user) {
    final userProvider = context.read<UserProvider>();

    _nameController.text = user.name;
    _emailController.text = user.email;
    _usernameController.text = user.username;
    _existingAvatarPath = user.avatarPath;
    _dob = user.dob;
    _gender = user.gender.isEmpty ? null : user.gender;
    _primaryGoal = user.primaryGoal.isNotEmpty
        ? user.primaryGoal
        : 'build_good_habits';
    _routinePreference = user.routinePreference;
    _notificationsEnabled = user.notificationsEnabled;
    _isDarkTheme = userProvider.isDarkTheme;
    _weeklyTarget = user.weeklyTarget;
    _reminderTime = _parseReminderTime(user.reminderTime);
    _categories
      ..clear()
      ..addAll(user.defaultCategories);
  }

  Future<void> _loadProfile() async {
    final userProvider = context.read<UserProvider>();

    try {
      if (userProvider.user != null) {
        _applyUser(userProvider.user!);
      }
      await userProvider.fetchProfile(preserveLocalTheme: true);
      if (!mounted) return;
      if (userProvider.user != null) {
        _applyUser(userProvider.user!);
      }
    } catch (e) {
      if (mounted) showApiErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _newProfileImage = File(picked.path));
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

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validateUsername(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Username is required';
    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(text)) {
      return 'Use 3-20 letters, numbers, or underscores';
    }
    return null;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your date of birth',
              style: GoogleFonts.poppins()),
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
      _isSaving = true;
      _uploadProgress = 0.2;
    });

    try {
      final reminder = DateFormat('HH:mm').format(
        DateTime(2024, 1, 1, _reminderTime.hour, _reminderTime.minute),
      );

      final profileData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
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

      if (_newProfileImage != null) {
        setState(() => _uploadProgress = 0.55);
        final bytes = await _newProfileImage!.readAsBytes();
        profileData['avatar'] = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      setState(() => _uploadProgress = 0.8);

      await context.read<UserProvider>().updateProfileViaApi(profileData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated successfully',
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
      if (mounted) {
        setState(() {
          _isSaving = false;
          _uploadProgress = 0;
        });
      }
    }
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
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : MyColors.kBlackColor,
          ),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : MyColors.kBlackColor,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: MyColors.primaryBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: _buildAvatarPicker(isDark)),
                    if (_isSaving) ...[
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
                    ],
                    const SizedBox(height: 24),
                    _ThemedFormField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      validator: _validateName,
                      isDark: isDark,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    _ThemedFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      label: 'Email Address',
                      hint: 'Enter your email',
                      validator: _validateEmail,
                      isDark: isDark,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    _ThemedFormField(
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      label: 'Username',
                      hint: 'habit_hero42',
                      validator: _validateUsername,
                      isDark: isDark,
                      prefixText: '@',
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('Date of Birth', isDark: isDark),
                    const SizedBox(height: 8),
                    _PickerTile(
                      label: _dob == null
                          ? 'Select date of birth'
                          : dateFormat.format(_dob!),
                      icon: Icons.cake_outlined,
                      onTap: _pickDob,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('Gender (optional)', isDark: isDark),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      dropdownColor:
                          isDark ? const Color(0xFF1F2937) : MyColors.kWhiteColor,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white : MyColors.kBlackColor,
                      ),
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
                    ..._goals.entries.map(
                      (e) => RadioListTile<String>(
                        value: e.key,
                        groupValue: _primaryGoal,
                        activeColor: MyColors.primaryBlue,
                        title: Text(
                          e.value,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isDark ? Colors.white : MyColors.kBlackColor,
                          ),
                        ),
                        onChanged: (v) => setState(() => _primaryGoal = v!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionTitle('Daily Routine', isDark: isDark),
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
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.white : MyColors.kBlackColor,
                        ),
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
                    _SectionTitle('Theme', isDark: isDark),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isDarkTheme,
                      activeThumbColor: MyColors.primaryBlue,
                      title: Text(
                        'Dark mode',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.white : MyColors.kBlackColor,
                        ),
                      ),
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
                    _SectionTitle('Habit Categories', isDark: isDark),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allCategories.map((cat) {
                        final selected = _categories.contains(cat);
                        return FilterChip(
                          label: Text(
                            cat,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark ? Colors.white : MyColors.kBlackColor,
                            ),
                          ),
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
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primaryBlue,
                          foregroundColor: Colors.white,
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
              ),
            ),
    );
  }

  Widget _buildAvatarPicker(bool isDark) {
    return GestureDetector(
      onTap: _isSaving ? null : _showImageSourceSheet,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: MyColors.primaryBlue.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _newProfileImage != null
                  ? Image.file(_newProfileImage!, fit: BoxFit.cover)
                  : UserAvatar(
                      imagePath: _existingAvatarPath,
                      radius: 55,
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

  InputDecoration _inputDecoration(bool isDark, {required String hint}) {
    final labelColor = isDark ? Colors.white : MyColors.kBlackColor;

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: MyColors.kDescriptionColor),
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: labelColor,
      ),
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

class _ThemedFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final bool isDark;
  final String? prefixText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  const _ThemedFormField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.isDark,
    required this.validator,
    this.prefixText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? Colors.white : MyColors.kBlackColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : MyColors.kBlackColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: MyColors.kDescriptionColor),
            prefixText: prefixText,
            prefixStyle: GoogleFonts.poppins(
              color: MyColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
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
              borderSide:
                  const BorderSide(color: MyColors.primaryBlue, width: 1.5),
            ),
          ),
        ),
      ],
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
