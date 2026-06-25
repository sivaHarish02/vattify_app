import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  // Margins & Paddings
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;

  // Specific Use Cases
  static double get screenPadding => md;
  static double get cardPadding => md;
}

class AppRadius {
  static BorderRadius get sm => BorderRadius.circular(8.r);
  static BorderRadius get md => BorderRadius.circular(16.r);
  static BorderRadius get lg => BorderRadius.circular(24.r);
  static BorderRadius get xl => BorderRadius.circular(32.r);
  static BorderRadius get circular => BorderRadius.circular(999.r);
}

class AppShadows {
  static List<BoxShadow> get premiumSoft => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 20.r,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get premiumHeavy => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 30.r,
          offset: const Offset(0, 10),
          spreadRadius: -5,
        ),
      ];
}
