class AppUser {
  final String id;
  final String name;
  final String email;
  final String avatarPath;
  final bool notificationsEnabled;
  final bool isDarkTheme;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarPath = 'assets/images/mahdi-chaghari-3xTP_gWUlrg-unsplash.jpg',
    this.notificationsEnabled = true,
    this.isDarkTheme = false,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarPath,
    bool? notificationsEnabled,
    bool? isDarkTheme,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarPath': avatarPath,
        'notificationsEnabled': notificationsEnabled,
        'isDarkTheme': isDarkTheme,
      };

  factory AppUser.fromMap(Map<dynamic, dynamic> map) {
    return AppUser(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Hero',
      email: map['email'] as String? ?? '',
      avatarPath: map['avatarPath'] as String? ??
          'assets/images/mahdi-chaghari-3xTP_gWUlrg-unsplash.jpg',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      isDarkTheme: map['isDarkTheme'] as bool? ?? false,
    );
  }
}
