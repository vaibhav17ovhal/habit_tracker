import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const habitsBox = 'habits_box';
  static const userBox = 'user_box';
  static const progressBox = 'progress_box';
  static const settingsBox = 'settings_box';

  static const keyHabits = 'habits';
  static const keyUser = 'user';
  static const keyProgress = 'daily_progress';
  static const keyOnboardingComplete = 'onboarding_complete';
  static const keyIsLogin = 'is_login';
  static const keyThemeDark = 'theme_dark';
  static const keyNotifications = 'notifications_enabled';
  static const keyMoods = 'mood_records';
  static const keyBannerQuote = 'banner_quote';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(settingsBox);
    await Hive.openBox(habitsBox);
    await Hive.openBox(userBox);
    await Hive.openBox(progressBox);
  }

  static Box get settings => Hive.box(settingsBox);
  static Box get habits => Hive.box(habitsBox);
  static Box get user => Hive.box(userBox);
  static Box get progress => Hive.box(progressBox);
}
