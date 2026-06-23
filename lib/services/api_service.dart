import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_urls.dart';
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
          body['message'] as String? ?? 'Request failed (${response.statusCode})';
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
    final url = ApiUrls.url(path);
    final requestHeaders = auth ? await _authHeaders() : _jsonHeaders;

    _log('────────────────────────────────────────');
    _log('[$label] ▶ $method $url');
    _log('[$label] MODE: ${ApiConfig.deviceLabel}');
    _log('[$label] HEADERS: ${_sanitizeHeaders(requestHeaders)}');
    if (body != null) {
      _log('[$label] REQUEST: ${_sanitizeBody(body)}');
    }

    try {
      final uri = Uri.parse(url);
      final client = http.Client();

      try {
        late http.Response response;

        switch (method) {
          case 'GET':
            response = await client
                .get(uri, headers: requestHeaders)
                .timeout(ApiConfig.requestTimeout);
          case 'POST':
            response = await client
                .post(uri, headers: requestHeaders, body: body)
                .timeout(ApiConfig.requestTimeout);
          case 'PATCH':
            response = await client
                .patch(uri, headers: requestHeaders, body: body)
                .timeout(ApiConfig.requestTimeout);
          case 'PUT':
            response = await client
                .put(uri, headers: requestHeaders, body: body)
                .timeout(ApiConfig.requestTimeout);
          case 'DELETE':
            response = await client
                .delete(uri, headers: requestHeaders, body: body)
                .timeout(ApiConfig.requestTimeout);
          default:
            throw ApiException('Unsupported HTTP method: $method', 0);
        }

        return await _handleResponse(response, label: label);
      } finally {
        client.close();
      }
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
    _log('  2. PC browser: http://localhost:${ApiConfig.port}/');
    _log('  3. Android emulator → ApiDeviceMode.emulator (10.0.2.2)');
    _log('  4. Physical phone → ApiDeviceMode.physicalDevice + pcLanHost');
    _log('  5. Allow port ${ApiConfig.port} in Windows Firewall');
  }

  String _networkErrorMessage(Object error) {
    final text = error.toString().toLowerCase();
    final url = ApiUrls.baseUrl;

    if (text.contains('connection timed out') ||
        text.contains('connection refused') ||
        text.contains('failed host lookup') ||
        text.contains('network is unreachable')) {
      return 'Cannot reach server at $url. '
          'Check backend is running and ApiConfig.androidMode matches your device '
          '(emulator=10.0.2.2, physical=${ApiConfig.pcLanHost}).';
    }

    if (text.contains('timeout')) {
      return 'Request timed out connecting to $url.';
    }

    return 'Network error: ${error.toString()}';
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<AuthResponse> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    const label = 'SIGNUP';

    final body = await _send(
      label: label,
      method: 'POST',
      path: ApiUrls.signup,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const ApiException('Signup succeeded but no token was returned', 500);
    }

    await TokenStorage.saveToken(token);
    _log('[$label] JWT saved to secure storage');

    return AuthResponse(
      token: token,
      user: Map<String, dynamic>.from(body['user'] as Map? ?? {}),
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    const label = 'LOGIN';

    final body = await _send(
      label: label,
      method: 'POST',
      path: ApiUrls.login,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const ApiException('Login succeeded but no token was returned', 500);
    }

    await TokenStorage.saveToken(token);
    _log('[$label] JWT saved to secure storage');

    return AuthResponse(
      token: token,
      user: Map<String, dynamic>.from(body['user'] as Map? ?? {}),
    );
  }

  Future<void> logout() async {
    const label = 'LOGOUT';

    try {
      if (await TokenStorage.hasToken()) {
        await _send(
          label: label,
          method: 'POST',
          path: ApiUrls.logout,
          auth: true,
        );
      }
    } catch (e) {
      _log('[$label] Server logout failed (clearing local session anyway): $e');
    } finally {
      await TokenStorage.deleteToken();
      _log('[$label] JWT cleared from secure storage');
    }
  }

  Future<void> deleteAccount() async {
    const label = 'DELETE ACCOUNT';

    await _send(
      label: label,
      method: 'DELETE',
      path: ApiUrls.deleteAccount,
      auth: true,
    );

    await TokenStorage.deleteToken();
    _log('[$label] Account deleted; JWT cleared from secure storage');
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> completeProfile(
    Map<String, dynamic> profileData,
  ) async {
    const label = 'PROFILE SETUP';

    final body = await _send(
      label: label,
      method: 'POST',
      path: ApiUrls.profileSetup,
      auth: true,
      body: jsonEncode(profileData),
    );

    return Map<String, dynamic>.from(body['user'] as Map? ?? {});
  }

  Future<Map<String, dynamic>> getProfile() async {
    const label = 'GET PROFILE';

    final body = await _send(
      label: label,
      method: 'GET',
      path: ApiUrls.profile,
      auth: true,
    );

    return Map<String, dynamic>.from(body['user'] as Map? ?? {});
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    const label = 'UPDATE PROFILE';

    final body = await _send(
      label: label,
      method: 'PUT',
      path: ApiUrls.profile,
      auth: true,
      body: jsonEncode(profileData),
    );

    return Map<String, dynamic>.from(body['user'] as Map? ?? {});
  }

  // ── Habits ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> addHabit(Map<String, dynamic> habitData) async {
    const label = 'ADD HABIT';

    final body = await _send(
      label: label,
      method: 'POST',
      path: ApiUrls.habits,
      auth: true,
      body: jsonEncode(habitData),
    );

    return Map<String, dynamic>.from(body['habit'] as Map? ?? {});
  }

  Future<List<Map<String, dynamic>>> getHabits() async {
    const label = 'GET HABITS';

    final body = await _send(
      label: label,
      method: 'GET',
      path: ApiUrls.habits,
      auth: true,
    );

    final habits = body['habits'];
    if (habits is! List) return [];

    _log('[$label] Parsed ${habits.length} habit(s)');
    return habits
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> getHabitById(String id) async {
    const label = 'GET HABIT BY ID';

    final body = await _send(
      label: label,
      method: 'GET',
      path: ApiUrls.habitById(id),
      auth: true,
    );

    return Map<String, dynamic>.from(body['habit'] as Map? ?? {});
  }

  Future<Map<String, dynamic>> markHabitComplete(String id) async {
    const label = 'MARK COMPLETE';

    final body = await _send(
      label: label,
      method: 'PATCH',
      path: ApiUrls.habitComplete(id),
      auth: true,
    );

    return Map<String, dynamic>.from(body['habit'] as Map? ?? {});
  }

  Future<Map<String, dynamic>> breakHabit(String id) async {
    const label = 'BREAK HABIT';

    final body = await _send(
      label: label,
      method: 'PATCH',
      path: ApiUrls.habitBreak(id),
      auth: true,
    );

    return Map<String, dynamic>.from(body['habit'] as Map? ?? {});
  }

  Future<Map<String, dynamic>> updateHabit(
    String id,
    Map<String, dynamic> habitData,
  ) async {
    const label = 'UPDATE HABIT';

    final body = await _send(
      label: label,
      method: 'PUT',
      path: ApiUrls.habitById(id),
      auth: true,
      body: jsonEncode(habitData),
    );

    return Map<String, dynamic>.from(body['habit'] as Map? ?? {});
  }

  Future<void> deleteHabit(String id) async {
    const label = 'DELETE HABIT';

    await _send(
      label: label,
      method: 'DELETE',
      path: ApiUrls.habitById(id),
      auth: true,
    );
  }

  // ── Progress ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProgressCalendar({
    int? year,
    int? month,
    String? today,
  }) async {
    const label = 'GET PROGRESS CALENDAR';

    final body = await _send(
      label: label,
      method: 'GET',
      path: ApiUrls.progressCalendarPath(
        year: year,
        month: month,
        today: today,
      ),
      auth: true,
    );

    final days = body['days'];
    _log('[$label] Parsed ${days is List ? days.length : 0} day(s)');
    return Map<String, dynamic>.from(body);
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
