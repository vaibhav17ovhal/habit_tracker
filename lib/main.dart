import 'package:Demo/custom_widgets/providers.dart';
import 'package:Demo/screens/splash_screen.dart';
import 'package:Demo/services/hive_service.dart';
import 'package:Demo/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
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
