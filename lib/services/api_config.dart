import 'dart:io';

import 'package:flutter/foundation.dart';

/// How the Flutter app reaches the backend on Android.
enum ApiDeviceMode {
  /// Android emulator → host machine localhost
  emulator,

  /// Physical phone on same Wi‑Fi → PC IPv4 from `ipconfig`
  physicalDevice,
}

class ApiConfig {
  static const int port = 5000;

  /// Switch between emulator and physical device.
  static const ApiDeviceMode androidMode = ApiDeviceMode.physicalDevice;

  /// PC Wi‑Fi IPv4 — used when [androidMode] is [ApiDeviceMode.physicalDevice].
  /// Run `ipconfig` on Windows to find yours.
  static const String pcLanHost = '192.168.1.10';

  static const Duration requestTimeout = Duration(seconds: 30);

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_HOST');
    if (fromEnv.isNotEmpty) {
      return 'http://$fromEnv:$port';
    }

    if (kIsWeb) return 'http://localhost:$port';
    if (Platform.isAndroid) {
      switch (androidMode) {
        case ApiDeviceMode.emulator:
          return 'http://10.0.2.2:$port';
        case ApiDeviceMode.physicalDevice:
          return 'http://$pcLanHost:$port';
      }
    }
    return 'http://localhost:$port';
  }

  static String get deviceLabel {
    if (kIsWeb) return 'web → localhost';
    if (Platform.isAndroid) {
      return androidMode == ApiDeviceMode.emulator
          ? 'android emulator → 10.0.2.2'
          : 'android physical → $pcLanHost';
    }
    return 'desktop → localhost';
  }
}
