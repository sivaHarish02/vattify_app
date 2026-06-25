import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.emeraldGreen,
      scaffoldBackgroundColor: AppColors.softWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.emeraldGreen,
        secondary: AppColors.deepGreen,
        background: AppColors.softWhite,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onBackground: AppColors.textDark,
        onSurface: AppColors.textDark,
        error: AppColors.danger,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.textDark),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.largeDisplay.copyWith(color: AppColors.textDark),
        headlineLarge: AppTypography.headline.copyWith(color: AppColors.textDark),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.textDark),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.textDark),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textDark),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.textDark),
        bodySmall: AppTypography.caption.copyWith(color: AppColors.textLight),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.emeraldGreen,
        unselectedItemColor: AppColors.textLight,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGrey,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.emeraldGreen,
      scaffoldBackgroundColor: AppColors.richBlack,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.emeraldGreen,
        secondary: AppColors.deepGreen,
        background: AppColors.richBlack,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onBackground: AppColors.softWhite,
        onSurface: AppColors.softWhite,
        error: AppColors.danger,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.softWhite),
        titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.softWhite),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.largeDisplay.copyWith(color: AppColors.softWhite),
        headlineLarge: AppTypography.headline.copyWith(color: AppColors.softWhite),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.softWhite),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.softWhite),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.softWhite),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.softWhite),
        bodySmall: AppTypography.caption.copyWith(color: AppColors.darkGrey),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        selectedItemColor: AppColors.emeraldGreen,
        unselectedItemColor: AppColors.darkGrey,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkGrey,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
