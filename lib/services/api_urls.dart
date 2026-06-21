class ApiUrls {
  static final ApiUrls _apiMethods = ApiUrls._internal();

  ApiUrls._internal();

  factory ApiUrls() {
    return _apiMethods;
  }

  /// --------------------->>>>>  Live Base URL  <<<<<----------------------------


  /// --------------------->>>>>  Development Base URL  <<<<<----------------------------
  /// Legacy URL — Habit Hero API now uses ApiConfig in lib/services/api_config.dart
  /// Backend port: 5000  |  Update androidDevHost to your PC IPv4 from ipconfig
  static const String baseURL = "http://192.168.1.10:5000";
  
  /// --------------------->>>>>  All URL  <<<<<----------------------------

  static const String signUp = "$baseURL/user/auth";


}