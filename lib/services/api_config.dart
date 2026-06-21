import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Must match backend PORT in Habit_tracker_backend/.env (default 5000).
  static const int port = 5000;

  /// Your PC's Wi‑Fi IPv4 — run `ipconfig` if login times out.
  /// Backend: http://localhost:5000  →  Flutter Android: http://YOUR_PC_IP:5000
  static const String androidDevHost = '192.168.1.10';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_HOST');
    if (fromEnv.isNotEmpty) {
      return 'http://$fromEnv:$port';
    }

    if (kIsWeb) return 'http://localhost:$port';
    if (Platform.isAndroid) return 'http://$androidDevHost:$port';
    return 'http://localhost:$port';
  }

  static bool get isUsingLanHost =>
      !kIsWeb && Platform.isAndroid;
}
