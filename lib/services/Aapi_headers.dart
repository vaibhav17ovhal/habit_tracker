import 'package:flutter/cupertino.dart';

import '../utility/helper.dart';

class ApiHeaders {
  static Map<String, String> headerWithoutToken() {
    return {"Content-Type": "application/json", "Accept": "application/json"};
  }

  ///-------------Header With Token----------------------

  static Future<Map<String, String>> headerWithToken([
    bool? isMultipart,
  ]) async {
    String? token = await Helper.getAccessToken();
    debugPrint("Token: $token ");
    if (isMultipart ?? false) {
      debugPrint("Trueeee");
      return {
        "Authorization": "Bearer $token",
        'Accept': 'application/json',
        "Content-Type": "application/json",
      };
    } else {
      debugPrint("Falseeeee");
      return {
        "api-access-token": "a2d1e12a346d6ed0f0d0267a24587a203",
        'Accept': 'application/json',
      };
    }
  }
}