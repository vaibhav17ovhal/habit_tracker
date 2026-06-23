import 'package:Demo/custom_widgets/custom_colors.dart';
import 'package:Demo/providers/banner_quote_provider.dart';
import 'package:Demo/providers/habits_provider.dart';
import 'package:Demo/providers/mood_provider.dart';
import 'package:Demo/providers/progress_provider.dart';
import 'package:Demo/providers/splash_provider.dart';
import 'package:Demo/providers/user_provider.dart';
import 'package:Demo/widgets/splash/splash_animated_background.dart';
import 'package:Demo/widgets/splash/splash_hero_logo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final AnimationController _textController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoGlow;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _initAnimations() {
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.12), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 45),
    ]).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _logoGlow = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _loaderFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _textController.forward();
    });
  }

  Future<void> _init() async {
    final habitsProvider = context.read<HabitsProvider>();
    final userProvider = context.read<UserProvider>();
    final progressProvider = context.read<ProgressProvider>();
    final moodProvider = context.read<MoodProvider>();
    final bannerProvider = context.read<BannerQuoteProvider>();
    final splashProvider = context.read<SplashProvider>();

    await userProvider.loadFromStorage();
    await progressProvider.loadFromStorage();
    await moodProvider.loadFromStorage();
    await bannerProvider.loadForCurrentSlot();

    if (await userProvider.hasValidSession()) {
      try {
        await habitsProvider.fetchFromApi();
        await habitsProvider.syncProgress(progressProvider);
      } catch (_) {
        await habitsProvider.loadFromStorage();
        await progressProvider.syncFromHabits(habitsProvider.goodHabits);
      }
    } else {
      await habitsProvider.loadFromStorage();
      if (habitsProvider.totalCount > 0) {
        await progressProvider.syncFromHabits(habitsProvider.goodHabits);
        if (progressProvider.records.isEmpty) {
          await progressProvider.seedSampleWeek(
            totalHabits: habitsProvider.totalCount,
          );
        }
        await progressProvider.recordDay(
          date: DateTime.now(),
          completedCount: habitsProvider.completedCount,
          totalCount: habitsProvider.totalCount,
        );
      }
    }

    if (!mounted) return;
    splashProvider.navigateToNextScreen(context);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SplashAnimatedBackground(animation: _bgController),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                SplashHeroLogo(
                  scaleAnimation: _logoScale,
                  glowAnimation: _logoGlow,
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          MyColors.primaryBlue,
                          Color(0xFF2563EB),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'Habit Hero',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _taglineFade,
                  child: SlideTransition(
                    position: _taglineSlide,
                    child: Text(
                      'Track. Improve. Transform',
                      style: GoogleFonts.poppins(
                        color: MyColors.kDescriptionColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _loaderFade,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoadingAnimationWidget.staggeredDotsWave(
                        color: MyColors.primaryBlue,
                        size: 44,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Loading your habits...',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: MyColors.kDescriptionColor.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
