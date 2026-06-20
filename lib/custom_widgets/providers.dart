import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/break_bad_habit_provider.dart';
import '../providers/build_a_habit_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/habits_provider.dart';
import '../providers/home_provider.dart';
import '../providers/login_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/rewards_provider.dart';
import '../providers/save_good_habit_provider.dart';
import '../providers/sign_up_provider.dart';
import '../providers/splash_provider.dart';
import '../providers/user_provider.dart';

class AppProviders {
  static MultiProvider getProviders({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SplashProvider()),
        ChangeNotifierProvider(create: (context) => SignUpProvider()),
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        ChangeNotifierProvider(create: (context) => DashboardProvider()),
        ChangeNotifierProvider(create: (context) => HabitsProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ProgressProvider()),
        ChangeNotifierProvider(create: (context) => RewardsProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => MoodProvider()),
        ChangeNotifierProvider(create: (context) => BuildAHabitProvider()),
        ChangeNotifierProvider(create: (context) => SaveGoodHabitProvider()),
        ChangeNotifierProvider(create: (context) => BreakBadHabitProvider()),
      ],
      child: child,
    );
  }
}
