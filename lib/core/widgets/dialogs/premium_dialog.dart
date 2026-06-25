import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_spacing.dart';
import '../../themes/app_typography.dart';
import '../buttons/premium_button.dart';

class PremiumDialog extends StatelessWidget {
  final String title;
  final String message;
  final String primaryActionText;
  final VoidCallback onPrimaryAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final bool isDestructive;
  final IconData? icon;

  const PremiumDialog({
    super.key,
    required this.title,
    required this.message,
    required this.primaryActionText,
    required this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.isDestructive = false,
    this.icon,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    required String primaryActionText,
    required VoidCallback onPrimaryAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    bool isDestructive = false,
    IconData? icon,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              elevation: 0,
              content: PremiumDialog(
                title: title,
                message: message,
                primaryActionText: primaryActionText,
                onPrimaryAction: onPrimaryAction,
                secondaryActionText: secondaryActionText,
                onSecondaryAction: onSecondaryAction,
                isDestructive: isDestructive,
                icon: icon,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.white,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.premiumHeavy,
        border: Border.all(
          color: isDark ? AppColors.darkGrey : AppColors.lightGrey,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.danger.withOpacity(0.1)
                    : AppColors.emeraldGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32.r,
                color: isDestructive ? AppColors.danger : AppColors.emeraldGreen,
              ),
            ),
            SizedBox(height: AppSpacing.md),
          ],
          Text(
            title,
            style: AppTypography.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              if (secondaryActionText != null) ...[
                Expanded(
                  child: PremiumButton(
                    text: secondaryActionText!,
                    type: ButtonType.secondary,
                    onPressed: onSecondaryAction ?? () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: PremiumButton(
                  text: primaryActionText,
                  type: isDestructive ? ButtonType.danger : ButtonType.primary,
                  onPressed: onPrimaryAction,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
