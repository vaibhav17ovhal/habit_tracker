import 'package:Demo/custom_widgets/providers.dart';
import 'package:Demo/screens/sign_in_screen.dart';
import 'package:Demo/screens/splash_screen.dart';
import 'package:Demo/services/api_service.dart';
import 'package:Demo/services/hive_service.dart';
import 'package:Demo/theme/app_theme.dart';
import 'package:Demo/utils/app_page_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  ApiService.onUnauthorized = () {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    HiveService.settings.put(HiveService.keyIsLogin, false);
    rootNavigatorKey.currentState?.pushAndRemoveUntil(
      AppPageRoute(page: const SignInScreen()),
      (_) => false,
    );
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders.getProviders(
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            navigatorKey: rootNavigatorKey,
            title: 'Habit Hero',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: userProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
