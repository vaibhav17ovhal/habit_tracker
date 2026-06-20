import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static const isLogin = 'is_login';
  static const userId = 'id';
  static const name = 'name';
  static const fcmToken = 'fcm_token';
  static const country = "country";
  static const countryCode = "country_code";
  static const paymentStatus = "payment_status";
  static const phone = "phone";
  static const email = "email";
  static const type = "type";
  static const accessCode = "access_code";
  static const accessToken = 'token';
  static const firstName = 'first_name';
  static const lastName = 'last_name';
  static const image = 'image';
  static const ingredientCount = 'ingredientCount';

  static void savingData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();

    if (data is String) {
      prefs.setString(key, data);
    } else if (data is int) {
      prefs.setInt(key, data);
    } else if (data is bool) {
      prefs.setBool(key, data);
    } else {
      print("Invalid datatype");
    }
  }

  ///---------------------Read Data------------------------

  static Future<dynamic> readData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    dynamic object = prefs.getString(key);
    return object;
  }

  ///---------------------Delete Data------------------------

  static Future<bool> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  ///---------------------Clear all Data------------------------

  static Future clearData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}