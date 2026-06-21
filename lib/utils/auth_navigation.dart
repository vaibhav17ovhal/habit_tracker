import 'package:Demo/main.dart';
import 'package:Demo/screens/sign_in_screen.dart';
import 'package:Demo/services/hive_service.dart';
import 'package:Demo/utils/app_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Sends the user to Sign In using the root navigator.
///
/// Uses [rootNavigatorKey] and waits until after the current frame so logout
/// provider updates (which rebuild [MaterialApp]) do not unmount the caller
/// before navigation runs.
void navigateToSignIn({bool clearLoginFlag = true}) {
  if (clearLoginFlag) {
    HiveService.settings.put(HiveService.keyIsLogin, false);
  }

  void pushSignIn() {
    rootNavigatorKey.currentState?.pushAndRemoveUntil(
      AppPageRoute(page: const SignInScreen()),
      (_) => false,
    );
  }

  if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
    WidgetsBinding.instance.addPostFrameCallback((_) => pushSignIn());
  } else {
    pushSignIn();
  }
}
