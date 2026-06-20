import 'package:flutter/material.dart';

class SaveGoodHabitProvider extends ChangeNotifier {
  // =========================
  // Repeat Section
  // =========================

  String repeatType = "Weekly";

  List<bool> weeklyDays = List.generate(7, (_) => true);

  int intervalDays = 2;

  List<DateTime> upcomingDates = [];

  // =========================
  // Monthly
  // =========================

  List<int> selectedDates = [];

  bool selectAllDates = false;

  // =========================
  // Time Management
  // =========================

  int durationValue = 20;

  String durationUnit = "mins";

  String frequencyUnit = "per day";

  // =========================
  // Reminders
  // =========================

  List<TimeOfDay> reminders = [
    const TimeOfDay(hour: 9, minute: 0),
  ];

  // =========================
  // Dates
  // =========================

  DateTime startDate = DateTime.now();

  bool neverEnds = true;

  DateTime? endDate;

  SaveGoodHabitProvider() {
    _generateUpcomingDates();
  }

  // =========================================================
  // Repeat
  // =========================================================

  void setRepeatType(String type) {
    repeatType = type;
    notifyListeners();
  }

  void toggleWeeklyDay(int index, bool value) {
    weeklyDays[index] = value;
    notifyListeners();
  }

  void setIntervalDays(int days) {
    if (days < 1) return;

    intervalDays = days;
    _generateUpcomingDates();

    notifyListeners();
  }

  void _generateUpcomingDates() {
    upcomingDates.clear();

    for (int i = 0; i < 10; i++) {
      upcomingDates.add(
        startDate.add(
          Duration(days: intervalDays * i),
        ),
      );
    }
  }

  // =========================================================
  // Monthly
  // =========================================================

  void toggleSelectAllDates(bool value) {
    selectAllDates = value;

    if (value) {
      selectedDates = List.generate(31, (i) => i + 1);
    } else {
      selectedDates.clear();
    }

    notifyListeners();
  }

  void toggleMonthlyDate(int day, bool selected) {
    if (selected) {
      if (!selectedDates.contains(day)) {
        selectedDates.add(day);
      }
    } else {
      selectedDates.remove(day);
    }

    selectedDates.sort();

    selectAllDates = selectedDates.length == 31;

    notifyListeners();
  }

  // =========================================================
  // Time Management
  // =========================================================

  void setDurationValue(int value) {
    final max = getMaxValue();

    if (value < 1) {
      durationValue = 1;
    } else if (value > max) {
      durationValue = max;
    } else {
      durationValue = value;
    }

    notifyListeners();
  }

  void setDurationUnit(String unit) {
    durationUnit = unit;

    _validateDuration();

    notifyListeners();
  }

  void setFrequencyUnit(String unit) {
    frequencyUnit = unit;

    _validateDuration();

    notifyListeners();
  }

  void _validateDuration() {
    final max = getMaxValue();

    if (durationValue > max) {
      durationValue = max;
    }
  }

  int getMaxValue() {
    if (durationUnit == "secs") {
      return 59;
    }

    if (durationUnit == "mins") {
      return switch (frequencyUnit) {
        "per day" => 180,
        "per week" => 1260,
        "per month" => 5400,
        "per year" => 64800,
        _ => 180,
      };
    }

    if (durationUnit == "hours") {
      return switch (frequencyUnit) {
        "per day" => 12,
        "per week" => 84,
        "per month" => 360,
        "per year" => 4380,
        _ => 12,
      };
    }

    return 12;
  }

  // =========================================================
  // Reminders
  // =========================================================

  void addReminder(TimeOfDay reminder) {
    reminders.add(reminder);
    notifyListeners();
  }

// Inside SaveGoodHabitProvider
  void removeReminder(TimeOfDay reminder) {
    reminders.remove(reminder);
    notifyListeners();
  }


  void updateReminder(int index, TimeOfDay reminder) {
    reminders[index] = reminder;
    notifyListeners();
  }

  // =========================================================
  // Dates
  // =========================================================

  void setStartDate(DateTime date) {
    startDate = date;

    // Reset endDate if it's before the new startDate
    if (endDate != null && endDate!.isBefore(startDate!)) {
      endDate = null;
    }

    notifyListeners();
  }


  void setNeverEnds(bool value) {
    neverEnds = value;

    if (neverEnds) {
      endDate = null;
    }

    notifyListeners();
  }


  void setEndDate(DateTime date) {
    if (startDate != null && date.isBefore(startDate!)) {
      // Ignore invalid selection
      return;
    }
    endDate = date;
    notifyListeners();
  }


  // =========================================================
  // Summary
  // =========================================================

  String get durationText {
    return "$durationValue $durationUnit $frequencyUnit";
  }


}