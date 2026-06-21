import 'package:flutter/material.dart';

import '../models/mood.dart';
import '../services/hive_service.dart';

class MoodProvider extends ChangeNotifier {
  final List<MoodEntry> _entries = [];

  List<MoodEntry> get entries => List.unmodifiable(_entries);

  MoodEntry? get todayMood {
    final now = DateTime.now();
    for (final entry in _entries) {
      if (_isSameDay(entry.date, now)) return entry;
    }
    return null;
  }

  Future<void> loadFromStorage() async {
    _entries.clear();
    final raw = HiveService.settings.get(HiveService.keyMoods);
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          _entries.add(MoodEntry.fromMap(item));
        }
      }
    }
    notifyListeners();
  }

  Future<void> selectMood(String label, String emoji) async {
    final now = DateTime.now();
    _entries.removeWhere((e) => _isSameDay(e.date, now));
    _entries.add(MoodEntry(date: now, label: label, emoji: emoji));
    await _persist();
    notifyListeners();
  }

  List<MoodEntry?> weeklyMoods({DateTime? reference}) {
    final now = reference ?? DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) {
      final day = DateTime(start.year, start.month, start.day + index);
      for (final entry in _entries) {
        if (_isSameDay(entry.date, day)) return entry;
      }
      return null;
    });
  }

  Future<void> _persist() async {
    await HiveService.settings.put(
      HiveService.keyMoods,
      _entries.map((e) => e.toMap()).toList(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
