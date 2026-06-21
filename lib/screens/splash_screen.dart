import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/providers/banner_quote_provider.dart';
import 'package:Demo/providers/habits_provider.dart';
import 'package:Demo/providers/mood_provider.dart';
import 'package:Demo/providers/progress_provider.dart';
import 'package:Demo/providers/splash_provider.dart';
import 'package:Demo/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
    final habitsProvider = context.read<HabitsProvider>();
    final userProvider = context.read<UserProvider>();
    final progressProvider = context.read<ProgressProvider>();
    final moodProvider = context.read<MoodProvider>();
    final bannerProvider = context.read<BannerQuoteProvider>();
    final splashProvider = context.read<SplashProvider>();

    await habitsProvider.loadFromStorage();
    await userProvider.loadFromStorage();
    await progressProvider.loadFromStorage();
    await moodProvider.loadFromStorage();
    await bannerProvider.loadForCurrentSlot();

    if (habitsProvider.totalCount > 0) {
      await progressProvider.seedSampleWeek(
        totalHabits: habitsProvider.totalCount,
      );
      await progressProvider.recordDay(
        date: DateTime.now(),
        completedCount: habitsProvider.completedCount,
        totalCount: habitsProvider.totalCount,
      );
    }

    if (!mounted) return;
    splashProvider.navigateToNextScreen(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/splash_screen_bg_img.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Positioned(
            left: 55,
            right: 55,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/app_logo_img.png'),
                const SizedBox(height: 12),
                Text(
                  'Habit Hero',
                  style: GoogleFonts.poppins(
                    color: MyColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track. Improve. Transform',
                  style: GoogleFonts.poppins(
                    color: MyColors.kBlackColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  color: MyColors.primaryBlue,
                  strokeWidth: 2.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
