import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTypography {
  static const String fontFamily = 'Inter'; // Fallback if Inter isn't loaded, system default will be used nicely

  static TextStyle get largeDisplay => TextStyle(
        fontFamily: fontFamily,
        fontSize: 36.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      );

  static TextStyle get headline => TextStyle(
        fontFamily: fontFamily,
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get titleLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      );
}
