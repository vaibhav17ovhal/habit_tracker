import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import '../services/token_storage.dart';
import '../utils/avatar_utils.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;

  AppUser? get user => _user;
  bool get isDarkTheme => _isDarkTheme;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isProfileSetupComplete => _user?.profileSetupComplete ?? false;
  ThemeMode get themeMode =>
      _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  String get displayName => _user?.name ?? 'Habit Hero';
  String get displayEmail => _user?.email ?? 'hero@habithero.app';
  String get displayUsername =>
      _user?.username.isNotEmpty == true ? '@${_user!.username}' : '';
  String get avatarPath => resolveAvatarUrl(
        _user?.avatarPath ??
            'assets/images/mahdi-chaghari-3xTP_gWUlrg-unsplash.jpg',
      );

  Future<void> loadFromStorage() async {
    final settings = HiveService.settings;
    _isDarkTheme = settings.get(HiveService.keyThemeDark, defaultValue: false);
    _notificationsEnabled =
        settings.get(HiveService.keyNotifications, defaultValue: true);

    final userMap = HiveService.user.get(HiveService.keyUser);
    if (userMap != null && userMap is Map) {
      _user = AppUser.fromMap(userMap);
      _isDarkTheme = _user!.isDarkTheme;
      _notificationsEnabled = _user!.notificationsEnabled;
    }
    notifyListeners();
  }

  Future<void> saveUser(AppUser user) async {
    _user = user;
    _isDarkTheme = user.isDarkTheme;
    _notificationsEnabled = user.notificationsEnabled;
    await HiveService.user.put(HiveService.keyUser, user.toMap());
    await HiveService.settings.put(HiveService.keyIsLogin, true);
    await HiveService.settings.put(HiveService.keyThemeDark, user.isDarkTheme);
    await HiveService.settings.put(
      HiveService.keyNotifications,
      user.notificationsEnabled,
    );
    notifyListeners();
  }

  Future<void> saveFromApiUser(Map<String, dynamic> apiUser) async {
    await saveUser(AppUser.fromApiMap(apiUser));
  }

  Future<void> completeProfileSetup(Map<String, dynamic> profileData) async {
    final apiUser = await ApiService.instance.completeProfile(profileData);
    await saveFromApiUser(apiUser);
  }

  Future<void> fetchProfile({bool preserveLocalTheme = false}) async {
    if (!await TokenStorage.hasToken()) {
      await loadFromStorage();
      return;
    }

    final localTheme = _isDarkTheme;
    final apiUser = Map<String, dynamic>.from(
      await ApiService.instance.getProfile(),
    );

    if (preserveLocalTheme) {
      final preferences = Map<String, dynamic>.from(
        apiUser['preferences'] as Map? ?? {},
      );
      preferences['theme'] = localTheme ? 'dark' : 'light';
      apiUser['preferences'] = preferences;
    }

    await saveFromApiUser(apiUser);
  }

  Future<void> updateProfileViaApi(Map<String, dynamic> profileData) async {
    if (await TokenStorage.hasToken()) {
      final apiUser = await ApiService.instance.updateProfile(profileData);
      await saveFromApiUser(apiUser);
      return;
    }

    if (_user == null) return;
    final updated = _user!.copyWith(
      name: profileData['name'] as String? ?? _user!.name,
      email: profileData['email'] as String? ?? _user!.email,
      username: profileData['username'] as String? ?? _user!.username,
      gender: profileData['gender'] as String? ?? _user!.gender,
      primaryGoal: profileData['primaryGoal'] as String? ?? _user!.primaryGoal,
      routinePreference:
          profileData['routinePreference'] as String? ?? _user!.routinePreference,
      notificationsEnabled: profileData['notificationsEnabled'] as bool? ??
          _user!.notificationsEnabled,
      reminderTime: profileData['reminderTime'] as String? ?? _user!.reminderTime,
      isDarkTheme: (profileData['theme'] as String? ?? 'light') == 'dark',
      weeklyTarget: (profileData['weeklyTarget'] as num?)?.toInt() ??
          _user!.weeklyTarget,
      defaultCategories: (profileData['defaultCategories'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          _user!.defaultCategories,
    );
    await saveUser(updated);
  }

  Future<bool> hasValidSession() async {
    return await TokenStorage.hasToken() &&
        HiveService.settings.get(HiveService.keyIsLogin, defaultValue: false);
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    await updateProfileViaApi({'name': name, 'email': email});
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    await HiveService.settings.put(HiveService.keyThemeDark, _isDarkTheme);
    if (_user != null) {
      final updated = _user!.copyWith(isDarkTheme: _isDarkTheme);
      _user = updated;
      await HiveService.user.put(HiveService.keyUser, updated.toMap());
    }
    notifyListeners();

    if (await TokenStorage.hasToken()) {
      try {
        final apiUser = await ApiService.instance.updateProfile({
          'theme': _isDarkTheme ? 'dark' : 'light',
        });
        final synced = AppUser.fromApiMap(apiUser).copyWith(
          isDarkTheme: _isDarkTheme,
        );
        _user = synced;
        await HiveService.user.put(HiveService.keyUser, synced.toMap());
        notifyListeners();
      } catch (_) {
        // Keep the local theme choice even if the server sync fails.
      }
    }
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await HiveService.settings
        .put(HiveService.keyNotifications, _notificationsEnabled);
    if (_user != null) {
      final updated = _user!.copyWith(notificationsEnabled: value);
      await saveUser(updated);
    } else {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    await ApiService.instance.logout();
    await HiveService.settings.put(HiveService.keyIsLogin, false);
    await HiveService.user.delete(HiveService.keyUser);
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (await TokenStorage.hasToken()) {
      await ApiService.instance.deleteAccount();
    } else {
      await ApiService.instance.logout();
    }

    await HiveService.habits.delete(HiveService.keyHabits);
    await HiveService.progress.delete(HiveService.keyProgress);
    await HiveService.settings.delete(HiveService.keyMoods);
    await HiveService.settings.delete(HiveService.keyIsLogin);
    await HiveService.settings.delete(HiveService.keyThemeDark);
    await HiveService.settings.delete(HiveService.keyNotifications);
    await HiveService.user.delete(HiveService.keyUser);

    _user = null;
    _isDarkTheme = false;
    _notificationsEnabled = true;
    notifyListeners();
  }
}
