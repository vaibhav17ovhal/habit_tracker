import 'api_config.dart';

/// Central registry for the Habit Hero API base URL and all endpoint paths.
///
/// Device-specific host resolution (emulator vs physical phone) lives in
/// [ApiConfig]. This class defines every route the app calls.
class ApiUrls {
  ApiUrls._();

  // ── Base URL ──────────────────────────────────────────────────────────────

  static String get baseUrl => ApiConfig.baseUrl;

  static int get port => ApiConfig.port;

  static String url(String path) => '$baseUrl$path';

  // ── Health ──────────────────────────────────────────────────────────────────

  static const String health = '/';

  static String get healthUrl => url(health);

  // ── Auth ──────────────────────────────────────────────────────────────────

  static const String signup = '/signup';

  static const String login = '/login';

  static const String logout = '/logout';

  static const String deleteAccount = '/delete-account';

  /// Alternate auth routes mounted at `/api/auth/*` on the backend.
  static const String authSignup = '/api/auth/signup';

  static const String authLogin = '/api/auth/login';

  static const String authLogout = '/api/auth/logout';

  static const String authDeleteAccount = '/api/auth/delete-account';

  static String get signupUrl => url(signup);

  static String get loginUrl => url(login);

  static String get logoutUrl => url(logout);

  static String get deleteAccountUrl => url(deleteAccount);

  // ── Habits ────────────────────────────────────────────────────────────────

  static const String habits = '/habits';

  static String habitById(String id) => '$habits/$id';

  static String habitComplete(String id) => '$habits/$id/complete';

  static String habitBreak(String id) => '$habits/$id/break';

  static String get habitsUrl => url(habits);

  static String habitByIdUrl(String id) => url(habitById(id));

  static String habitCompleteUrl(String id) => url(habitComplete(id));

  static String habitBreakUrl(String id) => url(habitBreak(id));

  // ── Profile ───────────────────────────────────────────────────────────────

  static const String profileSetup = '/profile/setup';

  static const String profile = '/profile';

  static String get profileUrl => url(profile);

  static String get profileSetupUrl => url(profileSetup);
}
