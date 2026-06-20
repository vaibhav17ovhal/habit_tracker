import 'package:Demo/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashProvider extends ChangeNotifier{

  SharedPreferences? preference;
  bool isLogin = false;

  void stayLogin(BuildContext context) async {
    preference = await SharedPreferences.getInstance();
    isLogin = preference?.getBool("is_login") ?? false;

    if(isLogin){
      if(context.mounted){
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(),));
      }
    }
    else{
      if(context.mounted){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen(),));
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(),));
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
      }
    }
  }

  void navigateToNextScreen(BuildContext context){
    Future.delayed(Duration(seconds: 7), (){
      stayLogin(context);
    });
  }
}