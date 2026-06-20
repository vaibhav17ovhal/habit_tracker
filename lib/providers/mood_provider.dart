import 'package:flutter/material.dart';

class MoodProvider extends ChangeNotifier {
  String selectedMood = "";
  List<String> selectedActivities = [];
  TextEditingController noteController = TextEditingController();

  final List<Map<String, dynamic>> moods = [
    {"label": "Terrible", "emoji": "assets/icons/terrible_icon.gif"},
    {"label": "Bad", "emoji": "assets/icons/bad_icon.gif"},
    {"label": "Okay", "emoji": "assets/icons/okay_icon.gif"},
    {"label": "Good", "emoji": "assets/icons/good_icon.gif"},
    {"label": "Excellent", "emoji": "assets/icons/excellent_icon.gif"},
  ];

  void selectMood(String mood) {
    selectedMood = mood;
    notifyListeners();
  }

  final List<String> activities = [
    "Family",
    "Friends",
    "Love",
    "Work",
    "School",
  ];


  void toggleActivity(String activity) {
    if (selectedActivities.contains(activity)) {
      selectedActivities.remove(activity);
    } else {
      selectedActivities.add(activity);
    }
    notifyListeners();
  }

  void clearMood() {
    selectedMood = "";
    selectedActivities.clear();
    noteController.clear();
    notifyListeners();
  }

  void saveMood() {
    // 👉 Later connect Firebase / Hive / API here
    debugPrint("Mood: $selectedMood");
    debugPrint("Activities: $selectedActivities");
    debugPrint("Note: ${noteController.text}");

    clearMood();
  }
}