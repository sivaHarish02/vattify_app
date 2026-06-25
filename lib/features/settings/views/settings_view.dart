import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/widgets/cards/premium_card.dart';
import '../../../core/widgets/dialogs/premium_dialog.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = authState.user;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User profile card
            if (user != null)
              PremiumCard(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36.r,
                      backgroundColor: AppColors.emeraldGreen.withOpacity(0.1),
                      child: Icon(Icons.person_outline, size: 36.r, color: AppColors.emeraldGreen),
                    ),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: AppTypography.headline,
                          ),
                          Text(
                            '@${user.username}',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: user.isAdmin
                                  ? AppColors.danger.withOpacity(0.1)
                                  : AppColors.info.withOpacity(0.1),
                              borderRadius: AppRadius.sm,
                            ),
                            child: Text(
                              user.isAdmin ? 'ADMINISTRATOR' : 'FAMILY MEMBER',
                              style: AppTypography.caption.copyWith(
                                color: user.isAdmin ? AppColors.danger : AppColors.info,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: AppSpacing.xl),

            // Settings Group
            Text(
              'Preferences',
              style: AppTypography.titleLarge,
            ),
            SizedBox(height: AppSpacing.md),
            PremiumCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                title: Text('Dark Mode Display', style: AppTypography.titleMedium),
                subtitle: Text('Enable midnight slate colors', style: AppTypography.caption),
                secondary: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.textLight.withOpacity(0.1),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Icon(Icons.dark_mode_outlined, color: isDark ? AppColors.white : AppColors.textDark),
                ),
                activeColor: AppColors.emeraldGreen,
                value: themeMode == ThemeMode.dark,
                onChanged: (_) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // Session Group
            Text(
              'Session Management',
              style: AppTypography.titleLarge,
            ),
            SizedBox(height: AppSpacing.md),
            PremiumCard(
              padding: EdgeInsets.zero,
              onTap: () async {
                final confirm = await PremiumDialog.show<bool>(
                  context: context,
                  title: 'Confirm Sign Out',
                  message: 'Are you sure you want to sign out? Your session credentials will be cleared.',
                  primaryActionText: 'Sign Out',
                  secondaryActionText: 'Cancel',
                  icon: Icons.logout,
                  isDestructive: true,
                  onPrimaryAction: () => Navigator.pop(context, true),
                );
                
                if (confirm == true) {
                  await ref.read(authProvider.notifier).logout();
                }
              },
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: AppRadius.sm,
                  ),
                  child: const Icon(Icons.logout, color: AppColors.danger),
                ),
                title: Text('Sign Out', style: AppTypography.titleMedium.copyWith(color: AppColors.danger)),
                subtitle: Text('Sign out of your active Vattify session', style: AppTypography.caption),
                trailing: Icon(Icons.chevron_right, color: AppColors.textLight, size: 24.r),
              ),
            ),
            
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}
