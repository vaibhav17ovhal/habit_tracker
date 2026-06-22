class AppUser {
  final String id;
  final String name;
  final String email;
  final String avatarPath;
  final String username;
  final DateTime? dob;
  final String gender;
  final String primaryGoal;
  final String routinePreference;
  final bool notificationsEnabled;
  final String reminderTime;
  final bool isDarkTheme;
  final int weeklyTarget;
  final List<String> defaultCategories;
  final bool profileSetupComplete;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarPath = 'assets/images/mahdi-chaghari-3xTP_gWUlrg-unsplash.jpg',
    this.username = '',
    this.dob,
    this.gender = '',
    this.primaryGoal = '',
    this.routinePreference = 'morning',
    this.notificationsEnabled = true,
    this.reminderTime = '08:00',
    this.isDarkTheme = false,
    this.weeklyTarget = 5,
    this.defaultCategories = const [],
    this.profileSetupComplete = false,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarPath,
    String? username,
    DateTime? dob,
    String? gender,
    String? primaryGoal,
    String? routinePreference,
    bool? notificationsEnabled,
    String? reminderTime,
    bool? isDarkTheme,
    int? weeklyTarget,
    List<String>? defaultCategories,
    bool? profileSetupComplete,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      username: username ?? this.username,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      routinePreference: routinePreference ?? this.routinePreference,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
      defaultCategories: defaultCategories ?? this.defaultCategories,
      profileSetupComplete:
          profileSetupComplete ?? this.profileSetupComplete,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarPath': avatarPath,
        'username': username,
        'dob': dob?.toIso8601String(),
        'gender': gender,
        'primaryGoal': primaryGoal,
        'routinePreference': routinePreference,
        'notificationsEnabled': notificationsEnabled,
        'reminderTime': reminderTime,
        'isDarkTheme': isDarkTheme,
        'weeklyTarget': weeklyTarget,
        'defaultCategories': defaultCategories,
        'profileSetupComplete': profileSetupComplete,
      };

  factory AppUser.fromMap(Map<dynamic, dynamic> map) {
    return AppUser(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Hero',
      email: map['email'] as String? ?? '',
      avatarPath: map['avatarPath'] as String? ??
          'assets/images/mahdi-chaghari-3xTP_gWUlrg-unsplash.jpg',
      username: map['username'] as String? ?? '',
      dob: map['dob'] != null ? DateTime.tryParse(map['dob'] as String) : null,
      gender: map['gender'] as String? ?? '',
      primaryGoal: map['primaryGoal'] as String? ?? '',
      routinePreference: map['routinePreference'] as String? ?? 'morning',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      reminderTime: map['reminderTime'] as String? ?? '08:00',
      isDarkTheme: map['isDarkTheme'] as bool? ?? false,
      weeklyTarget: map['weeklyTarget'] as int? ?? 5,
      defaultCategories: (map['defaultCategories'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      profileSetupComplete: map['profileSetupComplete'] as bool? ?? false,
    );
  }

  factory AppUser.fromApiMap(Map<String, dynamic> map) {
    final preferences = map['preferences'] as Map? ?? {};
    final habitTargets = map['habitTargets'] as Map? ?? {};

    return AppUser(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? 'Habit Hero',
      email: map['email'] as String? ?? '',
      avatarPath: (map['avatar'] as String?)?.isNotEmpty == true
          ? map['avatar'] as String
          : 'assets/images/mahdi-chaghari-3xTP_gWUlrg-unsplash.jpg',
      username: map['username'] as String? ?? '',
      dob: map['dob'] != null
          ? DateTime.tryParse(map['dob'].toString())
          : null,
      gender: map['gender'] as String? ?? '',
      primaryGoal: map['primaryGoal'] as String? ?? '',
      routinePreference:
          preferences['routinePreference'] as String? ?? 'morning',
      notificationsEnabled:
          preferences['notificationsEnabled'] as bool? ?? true,
      reminderTime: preferences['reminderTime'] as String? ?? '08:00',
      isDarkTheme: (preferences['theme'] as String? ?? 'light') == 'dark',
      weeklyTarget: (habitTargets['weeklyTarget'] as num?)?.toInt() ?? 5,
      defaultCategories: (habitTargets['defaultCategories'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      profileSetupComplete: map['profileSetupComplete'] as bool? ?? false,
    );
  }
}
