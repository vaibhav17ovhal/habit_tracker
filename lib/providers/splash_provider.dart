import 'package:Demo/screens/dashboard_screen.dart';
import 'package:Demo/screens/onboarding_screen.dart';
import 'package:Demo/screens/sign_in_screen.dart';
import 'package:Demo/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dashboard_provider.dart';

class SplashProvider extends ChangeNotifier {
  Future<void> navigateToNextScreen(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    context.read<DashboardProvider>().reset();

    final onboardingComplete = HiveService.settings.get(
      HiveService.keyOnboardingComplete,
      defaultValue: false,
    );
    final isLogin = HiveService.settings.get(
      HiveService.keyIsLogin,
      defaultValue: false,
    );

    if (!onboardingComplete) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    if (isLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }
}
