import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../custom_widgets/custom_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: MyColors.neutralGray,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MyColors.primaryBlue,
        primary: MyColors.primaryBlue,
        secondary: MyColors.accentYellow,
        surface: MyColors.kWhiteColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: MyColors.kWhiteColor,
        foregroundColor: MyColors.kBlackColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: MyColors.primaryBlue,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: MyColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? MyColors.primaryBlue
              : Colors.transparent,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF111827),
      colorScheme: ColorScheme.fromSeed(
        seedColor: MyColors.primaryBlue,
        brightness: Brightness.dark,
        primary: MyColors.primaryBlue,
        secondary: MyColors.accentYellow,
        surface: const Color(0xFF1F2937),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: MyColors.primaryBlue,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: MyColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    );
  }
}
