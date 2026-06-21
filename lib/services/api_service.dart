import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class AuthResponse {
  final String token;
  final Map<String, dynamic> user;

  const AuthResponse({required this.token, required this.user});
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static VoidCallback? onUnauthorized;

  static const _tag = '[HabitHero API]';

  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void _log(String message) {
    debugPrint('$_tag $message');
  }

  String _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    final auth = sanitized['Authorization'];
    if (auth != null && auth.startsWith('Bearer ')) {
      final token = auth.substring(7);
      sanitized['Authorization'] = token.length <= 12
          ? 'Bearer ***'
          : 'Bearer ${token.substring(0, 6)}...${token.substring(token.length - 4)}';
    }
    return sanitized.toString();
  }

  String _sanitizeBody(String? body) {
    if (body == null || body.isEmpty) return '(empty)';

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        if (map.containsKey('password')) {
          map['password'] = '***';
        }
        return const JsonEncoder.withIndent('  ').convert(map);
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.readToken();
    return {
      ..._jsonHeaders,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _handleResponse(
    http.Response response, {
    required String label,
  }) async {
    _log('[$label] ← STATUS ${response.statusCode}');
    _log('[$label] ← RESPONSE ${_sanitizeBody(response.body)}');

    Map<String, dynamic> body = {};

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        } else if (decoded is Map) {
          body = Map<String, dynamic>.from(decoded);
        }
      } catch (e, stack) {
        _log('[$label] ✗ JSON PARSE ERROR: $e');
        _log('[$label] STACK: $stack');
        throw ApiException(
          'Invalid JSON response (${response.statusCode})',
          response.statusCode,
        );
      }
    }

    if (response.statusCode == 401) {
      _log('[$label] ✗ UNAUTHORIZED — clearing token');
      await TokenStorage.deleteToken();
      onUnauthorized?.call();
      throw ApiException(
        body['message'] as String? ?? 'Session expired. Please sign in again.',
        401,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          body['message'] as String? ??
          'Request failed (${response.statusCode})';
      _log('[$label] ✗ API ERROR ($response.statusCode): $message');
      throw ApiException(message, response.statusCode);
    }

    _log('[$label] ✓ SUCCESS');
    return body;
  }

  Future<Map<String, dynamic>> _send({
    required String label,
    required String method,
    required String path,
    String? body,
    bool auth = false,
  }) async {
    final url = '${ApiConfig.baseUrl}$path';
    final requestHeaders = auth ? await _authHeaders() : _jsonHeaders;

    _log('────────────────────────────────────────');
    _log('[$label] ▶ $method $url');
    _log('[$label] BASE URL: ${ApiConfig.baseUrl}');
    _log('[$label] HEADERS: ${_sanitizeHeaders(requestHeaders)}');
    if (body != null) {
      _log('[$label] REQUEST: ${_sanitizeBody(body)}');
    }

    try {
      final uri = Uri.parse(url);
      late http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: requestHeaders);
        case 'POST':
          response = await http.post(uri, headers: requestHeaders, body: body);
        case 'PATCH':
          response = await http.patch(uri, headers: requestHeaders, body: body);
        default:
          throw ApiException('Unsupported HTTP method: $method', 0);
      }

      return await _handleResponse(response, label: label);
    } on ApiException {
      rethrow;
    } catch (e, stack) {
      _log('[$label] ✗ NETWORK/UNKNOWN ERROR: $e');
      _log('[$label] STACK: $stack');
      _logConnectionHelp();
      throw ApiException(_networkErrorMessage(e), 0);
    }
  }

  void _logConnectionHelp() {
    _log('TROUBLESHOOTING:');
    _log('  1. Start backend: cd Habit_tracker_backend && npm run dev');
    _log('  2. PC browser test: http://localhost:${ApiConfig.port}/');
    if (ApiConfig.isUsingLanHost) {
      _log('  3. Flutter uses LAN IP: ${ApiConfig.baseUrl}');
      _log(
        '  4. Update ApiConfig.androidDevHost if ipconfig shows a different IPv4',
      );
      _log('  5. Phone/emulator must reach that IP (same Wi‑Fi / network)');
    } else {
      _log('  3. Desktop uses: ${ApiConfig.baseUrl}');
    }
    _log('  6. Allow port ${ApiConfig.port} in Windows Firewall if needed');
  }

  String _networkErrorMessage(Object error) {
    final text = error.toString().toLowerCase();
    final url = ApiConfig.baseUrl;

    if (text.contains('connection timed out') ||
        text.contains('connection refused') ||
        text.contains('failed host lookup') ||
        text.contains('network is unreachable')) {
      return 'Cannot reach server at $url. '
          'Start backend (npm run dev), then set ApiConfig.androidDevHost '
          'to your PC IPv4 from ipconfig (currently ${ApiConfig.androidDevHost}).';
    }

    return 'Network error: ${error.toString()}';
  }

  /// Sign Up
  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String name,
  }) async
  {
    const label = 'SIGNUP';

    final body = await _send(
      label: label,
      method: 'POST',
      path: '/signup',
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );

    final token = body['token'] as String?;

    if (token == null || token.isEmpty) {
      _log('[$label] ✗ No token in signup response');
      throw const ApiException(
        'Signup succeeded but no token was returned',
        500,
      );
    }

    await TokenStorage.saveToken(token);
    _log('[$label] JWT saved to secure storage');

    return AuthResponse(
      token: token,
      user: Map<String, dynamic>.from(body['user'] as Map? ?? {}),
    );
  }

  /// Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async
  {
    const label = 'LOGIN';

    final body = await _send(
      label: label,
      method: 'POST',
      path: '/login',
      body: jsonEncode({'email': email, 'password': password}),
    );

    final token = body['token'] as String?;

    if (token == null || token.isEmpty) {
      _log('[$label] ✗ No token in login response');
      throw const ApiException(
        'Login succeeded but no token was returned',
        500,
      );
    }

    await TokenStorage.saveToken(token);
    _log('[$label] JWT saved to secure storage');

    return AuthResponse(
      token: token,
      user: Map<String, dynamic>.from(body['user'] as Map? ?? {}),
    );
  }

  /// Log out
  Future<void> logout() async {
    _log('[LOGOUT] Clearing JWT from secure storage');
    await TokenStorage.deleteToken();
    _log('[LOGOUT] ✓ Token cleared');
  }


  /// Add Habit
  Future<Map<String, dynamic>> addHabit(Map<String, dynamic> habitData) async {
    const label = 'ADD HABIT';

    final body = await _send(
      label: label,
      method: 'POST',
      path: '/habits',
      auth: true,
      body: jsonEncode(habitData),
    );

    return Map<String, dynamic>.from(body['habit'] as Map? ?? {});
  }

  /// Get Habit
  Future<List<Map<String, dynamic>>> getHabits() async {
    const label = 'GET HABITS';

    final body = await _send(
      label: label,
      method: 'GET',
      path: '/habits',
      auth: true,
    );

    final habits = body['habits'];

    if (habits is! List) {
      _log('[$label] ⚠ habits field missing or not a list — returning []');
      return [];
    }

    _log('[$label] Parsed ${habits.length} habit(s)');
    return habits
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  /// Mark Habit Complete
  Future<Map<String, dynamic>> markHabitComplete(String habitId) async {
    const label = 'MARK COMPLETE';

    final body = await _send(
      label: label,
      method: 'PATCH',
      path: '/habits/$habitId/complete',
      auth: true,
    );

    return Map<String, dynamic>.from(body['habit'] as Map? ?? {});
  }


  /// Break Bad Habit
  Future<Map<String, dynamic>> breakHabit(
    String habitId, {
    required double todayLoggedCount,
  }) async
  {
    const label = 'BREAK HABIT';

    final body = await _send(
      label: label,
      method: 'PATCH',
      path: '/habits/$habitId/break',
      auth: true,
      body: jsonEncode({'todayLoggedCount': todayLoggedCount}),
    );

    return Map<String, dynamic>.from(body['habit'] as Map? ?? {});
  }
}

void showApiErrorSnackBar(BuildContext context, Object error) {
  final message = error is ApiException
      ? error.message
      : 'Something went wrong. Please try again.';

  debugPrint('[HabitHero API] ✗ UI ERROR: $error');
  if (error is! ApiException) {
    debugPrint('[HabitHero API] ✗ Error type: ${error.runtimeType}');
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, maxLines: 4, overflow: TextOverflow.ellipsis),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
    ),
  );
}
