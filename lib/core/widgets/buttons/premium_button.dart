import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../themes/app_typography.dart';

enum ButtonType { primary, secondary, danger, text }

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;
    Color borderColor = Colors.transparent;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = AppColors.emeraldGreen;
        textColor = AppColors.white;
        break;
      case ButtonType.secondary:
        backgroundColor = isDark ? AppColors.darkSurfaceElevated : AppColors.white;
        textColor = isDark ? AppColors.white : AppColors.textDark;
        borderColor = isDark ? AppColors.darkGrey : AppColors.lightGrey;
        break;
      case ButtonType.danger:
        backgroundColor = AppColors.danger.withOpacity(0.1);
        textColor = AppColors.danger;
        break;
      case ButtonType.text:
        backgroundColor = Colors.transparent;
        textColor = AppColors.emeraldGreen;
        break;
    }

    if (onPressed == null) {
      backgroundColor = backgroundColor.withOpacity(0.5);
      textColor = textColor.withOpacity(0.5);
      borderColor = borderColor.withOpacity(0.5);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isFullWidth ? double.infinity : null,
      padding: isFullWidth ? null : EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      height: 56.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.md,
        border: Border.all(color: borderColor, width: 1),
        boxShadow: type == ButtonType.primary && onPressed != null
            ? AppShadows.premiumSoft
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.md,
          onTap: isLoading ? null : onPressed,
          splashColor: AppColors.glassWhite,
          highlightColor: AppColors.glassDark,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24.r,
                    height: 24.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: textColor, size: 20.r),
                        SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        text,
                        style: AppTypography.titleMedium.copyWith(color: textColor),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
