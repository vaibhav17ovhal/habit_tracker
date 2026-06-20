import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../custom_widgets/custom_colors.dart';
import 'local_storage.dart';

class Helper {
  ///.......Email validation...............
  static bool emailValidation(String email) {
    final bool emailValid = RegExp(
      r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
    ).hasMatch(email);
    return emailValid;
  }

  ///--------------Access Token-------------------
  static Future<String> getAccessToken() async {
    String access = await StorageManager.readData(StorageManager.accessToken);
    return access;
  }

  // static userNotExit(String msg, BuildContext context) async {
  //   if (msg == "Unauthenticated.") {
  //     StorageManager.clearData();
  //     StorageManager.savingData(StorageManager.isLogin, false);
  //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignInScreen(),), (route) => false,);
  //   }
  // }

  static bool validatePassword(String value) {
    RegExp regex = RegExp(r'.{6,}');
    return regex.hasMatch(value);
  }

  ///.......Password validation...............
  static String? isPasswordValidationTest(String em) {
    String? msg;

    String repExpCount = r'.{6,}';
    RegExp regExpC = RegExp(repExpCount);
    if (!regExpC.hasMatch(em)) {
      msg = "Password must be of at least 6 characters in length";
    } else {
      msg = null;
    }
    return msg;
  }

  static void showCustomDialog(BuildContext context, var page) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: MyColors.kAppThemeColor,
              ),
              child: page,
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
        }
        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  ///.........Toast..........
  static customToast(String msg) {
    return Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: MyColors.kAppThemeColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static wazeWidget({required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        padding: const EdgeInsets.only(right: 5),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          'assets/img_waze.png',
          fit: BoxFit.contain,
          height: 40,
          width: 40,
        ),
      ),
    );
  }

  static googleMapWidget({required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: 35,
        width: 35,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          'assets/ic_google_map.svg',
          fit: BoxFit.cover,
          height: 35,
          width: 35,
        ),
      ),
    );
  }

  /// Date Format
  static String getDateFormatAccording(DateTime date) {
    var formatter = DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(date);
    return formattedDate;
  }

  ///--------------InternetConnection------------
  static Future<bool> checkInternetConnection() async {
    // bool isConnected = false;
    // final List<ConnectivityResult> connectivityResult =
    //     await (Connectivity().checkConnectivity());
    // // debugPrint("asdfg : ${connectivityResult.contains(ConnectivityResult.wifi)}");
    // if (connectivityResult.contains(ConnectivityResult.mobile)) {
    //   isConnected = true;

    // } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
    //   isConnected = true;
    // } else {
    //   Helper.customToast("No Internet Connection");
    // }
    return true;
  }

  ///--------------  Loader  -----------------------
  static progressLoadingDialog(BuildContext context, bool status) {
    if (status) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(color: MyColors.kAppThemeColor),
          );
        },
      );
    } else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static void showError(String message, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}