import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import '../services/token_storage.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;

  AppUser? get user => _user;
  bool get isDarkTheme => _isDarkTheme;
  bool get notificationsEnabled => _notificationsEnabled;
  ThemeMode get themeMode =>
      _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  String get displayName => _user?.name ?? 'Habit Hero';
  String get displayEmail => _user?.email ?? 'hero@habithero.app';
  String get avatarPath =>
      _user?.avatarPath ??
      'assets/images/mahdi-chaghari-3xTP_gWUlrg-unsplash.jpg';

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
    await HiveService.user.put(HiveService.keyUser, user.toMap());
    await HiveService.settings.put(HiveService.keyIsLogin, true);
    notifyListeners();
  }

  Future<void> saveFromApiUser(Map<String, dynamic> apiUser) async {
    final user = AppUser(
      id: apiUser['id']?.toString() ?? '',
      name: apiUser['name'] as String? ?? 'Habit Hero',
      email: apiUser['email'] as String? ?? '',
    );
    await saveUser(user);
  }

  Future<bool> hasValidSession() async {
    return await TokenStorage.hasToken() &&
        HiveService.settings.get(HiveService.keyIsLogin, defaultValue: false);
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    if (_user == null) return;
    final updated = _user!.copyWith(name: name, email: email);
    await HiveService.user.put(HiveService.keyUser, updated.toMap());
    _user = updated;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    await HiveService.settings.put(HiveService.keyThemeDark, _isDarkTheme);
    if (_user != null) {
      final updated = _user!.copyWith(isDarkTheme: _isDarkTheme);
      await HiveService.user.put(HiveService.keyUser, updated.toMap());
      _user = updated;
    }
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await HiveService.settings
        .put(HiveService.keyNotifications, _notificationsEnabled);
    if (_user != null) {
      final updated = _user!.copyWith(notificationsEnabled: value);
      await HiveService.user.put(HiveService.keyUser, updated.toMap());
      _user = updated;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    await ApiService.instance.logout();
    await HiveService.settings.put(HiveService.keyIsLogin, false);
    await HiveService.user.delete(HiveService.keyUser);
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await ApiService.instance.logout();
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
