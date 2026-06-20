import 'package:flutter/material.dart';

import '../models/greeting_model.dart';

class HomeProvider extends ChangeNotifier {
  int selectedTabIndex = 1;

  DateTime selectedDate = DateTime.now();

  void changeTab(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  void changeDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  GreetingData getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return GreetingData(
        text: "Good Morning",
        icon: Icons.wb_sunny,
      );
    } else if (hour < 17) {
      return GreetingData(
        text: "Good Afternoon",
        icon: Icons.wb_sunny_outlined,
      );
    } else {
      return GreetingData(
        text: "Good Evening",
        icon: Icons.nights_stay,
      );
    }
  }

  // 🧠 Dummy progress (replace later with real DB/habits)
  double getProgress() {
    if (selectedDate.day == DateTime.now().day) return 0.6;
    return 0.3;
  }

  String getProgressText() {
    if (selectedDate.day == DateTime.now().day) return "3 of 5 habits done";
    return "1 of 5 habits done";
  }

  void resetToToday() {
    selectedDate = DateTime.now();
    notifyListeners();
  }

}