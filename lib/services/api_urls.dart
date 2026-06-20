class ApiUrls {
  static final ApiUrls _apiMethods = ApiUrls._internal();

  ApiUrls._internal();

  factory ApiUrls() {
    return _apiMethods;
  }

  /// --------------------->>>>>  Live Base URL  <<<<<----------------------------


  /// --------------------->>>>>  Development Base URL  <<<<<----------------------------
  static const String baseURL = "http://192.168.31.57:7000";
  
  /// --------------------->>>>>  All URL  <<<<<----------------------------

  static const String signUp = "$baseURL/user/auth";


}