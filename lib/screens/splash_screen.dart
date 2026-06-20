import 'package:Demo/custom_widgets/custom_font_family.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../custom_widgets/custom_colors.dart';
import '../custom_widgets/custom_scaffold.dart';
import '../providers/splash_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);

    splashProvider.navigateToNextScreen(context);

    /// FCM Token
    // String? token = await FirebaseMessaging.instance.getToken();
    // StorageManager.savingData(
    //   StorageManager.fcmToken,
    //   token.toString(),
    // );
    // debugPrint('fcm token is>> ${token.toString()}');
    // debugPrint("🔥 FCM TOKEN: $token");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: MyColors.kAppThemeColor,
      // body:
      // Image.asset(
      //   "assets/images/Sequence 03_2 2.gif",
      //   height: double.infinity,
      //   width: double.infinity,
      // ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/images/splash_screen_bg_img.png",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Positioned(
            left: 55,
            right: 55,
            child: Column(
              children: [
                Image.asset("assets/images/app_logo_img.png"),
                Text(
                  "Habit Tracker",
                  style: TextStyle(
                    color: MyColors.darkNavyBlue,
                    fontFamily: FontFamily.sfProBold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Track. Improve. Transform",
                  style: TextStyle(
                    color: MyColors.darkNavyBlue,
                    fontFamily: FontFamily.sfProMedium,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
