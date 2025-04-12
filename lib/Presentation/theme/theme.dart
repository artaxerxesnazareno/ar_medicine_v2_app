import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static Color primaryColor = const Color(0xff44ec9e);
  static Color primaryColorDarker = const Color(0xff3dd992);
  static Color primaryColorLighter = const Color(0xff3dd992);
  static Color secondaryColor = const Color(0xff3d32ce);
  static Color whiteShade = const Color(0xffFFF8F9FA);
  static Color grayShade = const Color(0xff9FA4AF);
  static Color darkText = const Color(0xff2d2d2d);
  static Color lightText = const Color(0xffffffff);
  static Color cardBackground = const Color(0xffF8F9FA);
  static Color errorColor = const Color(0xffE53935);
  static Color successColor = const Color(0xff43A047);
  static Color warningColor = const Color(0xffFFA000);
  static Color shadowColor = const Color(0x299FA4AF);
  static Color arSceneBackground = const Color(0xffECF4FF);
  static Color quizOptionBorder = const Color(0xffE0E0E0);
  static Color progressBarBackground = const Color(0xffE0F2F1);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.whiteShade,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      error: AppColors.errorColor,
    ),
    cardTheme: CardTheme(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: AppColors.shadowColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.lightText,
        textStyle: AppFont.buttonText,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondaryColor,
        textStyle: AppFont.buttonText,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: AppColors.secondaryColor, width: 1.5),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondaryColor,
        textStyle: AppFont.buttonText,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.whiteShade,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppFont.title,
      iconTheme: IconThemeData(color: AppColors.secondaryColor),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.whiteShade,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.grayShade,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: AppFont.smallText,
      unselectedLabelStyle: AppFont.smallText,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primaryColor,
      linearTrackColor: AppColors.progressBarBackground,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
  );
}

class AppFont {
  static TextStyle regular = TextStyle(
    fontWeight: FontWeight.w600,
    color: AppColors.lightText,
    fontSize: 22,
  );

  static TextStyle regularBoldDark = TextStyle(
    fontWeight: FontWeight.w500,
    color: AppColors.darkText,
    fontSize: 18,
  );

  static TextStyle title = TextStyle(
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
    fontSize: 20,
  );

  static TextStyle subtitle = TextStyle(
    fontWeight: FontWeight.w500,
    color: AppColors.darkText,
    fontSize: 16,
  );

  static TextStyle bodyText = TextStyle(
    fontWeight: FontWeight.w400,
    color: AppColors.darkText,
    fontSize: 14,
    height: 1.5,
  );

  static TextStyle buttonText = TextStyle(
    fontWeight: FontWeight.w600,
    color: AppColors.lightText,
    fontSize: 16,
  );

  static TextStyle smallText = TextStyle(
    fontWeight: FontWeight.w400,
    color: AppColors.grayShade,
    fontSize: 12,
  );

  static TextStyle highlightText = TextStyle(
    fontWeight: FontWeight.w600,
    color: AppColors.secondaryColor,
    fontSize: 16,
  );
}

class AppRoutes {
  static const String home = '/';
  static const String journeyDetails = '/journey-details';
  static const String arView = '/ar-view';
  static const String quiz = '/quiz';
  static const String quizResults = '/quiz-results';
}
