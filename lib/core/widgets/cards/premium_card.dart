import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool hasGlassEffect;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.hasGlassEffect = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBg = isDark ? AppColors.darkSurfaceElevated : AppColors.white;
    final finalBg = backgroundColor ?? defaultBg;

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: hasGlassEffect ? finalBg.withOpacity(0.7) : finalBg,
        borderRadius: AppRadius.lg,
        boxShadow: isDark ? [] : AppShadows.premiumSoft,
        border: isDark ? Border.all(color: AppColors.darkGrey, width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.lg,
          onTap: onTap,
          splashColor: AppColors.glassWhite,
          highlightColor: AppColors.glassDark,
          child: Padding(
            padding: padding ?? EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );

    return card;
  }
}
