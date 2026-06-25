import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/route_names.dart';
import '../../features/notifications/providers/notifications_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_spacing.dart';
import '../themes/app_typography.dart';
import 'app_logo.dart';
import 'dialogs/premium_dialog.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/borrowers')) return 1;
    if (location.startsWith('/collections')) return 2;
    if (location.startsWith('/reports')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteNames.dashboard);
        break;
      case 1:
        context.go(RouteNames.borrowers);
        break;
      case 2:
        context.go(RouteNames.collections);
        break;
      case 3:
        context.go(RouteNames.reports);
        break;
      case 4:
        context.go(RouteNames.settings);
        break;
    }
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Overview';
      case 1:
        return 'Borrowers';
      case 2:
        return 'Collections';
      case 3:
        return 'Reports';
      case 4:
        return 'Settings';
      default:
        return 'Vattify';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);
    final notificationState = ref.watch(notificationsProvider);
    final isTablet = MediaQuery.of(context).size.width > 600;

    final appBar = AppBar(
      title: Text(
        _getAppBarTitle(selectedIndex),
        style: AppTypography.headline,
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, size: 28.r),
              onPressed: () => context.push(RouteNames.notifications),
            ),
            if (notificationState.unreadCount > 0)
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                  ),
                  constraints: BoxConstraints(minWidth: 12.w, minHeight: 12.h),
                ),
              ),
          ],
        ),
        SizedBox(width: AppSpacing.sm),
      ],
    );

    final scaffold = isTablet
        ? Scaffold(
            appBar: appBar,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => _onItemTapped(index, context),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xl, top: AppSpacing.md),
                    child: AppLogo.small(),
                  ),
                  minWidth: 80.w,
                  destinations: _buildNavDestinations(),
                ),
                VerticalDivider(thickness: 1, width: 1, color: Theme.of(context).dividerColor),
                Expanded(child: child),
              ],
            ),
          )
        : Scaffold(
            appBar: appBar,
            body: child,
            bottomNavigationBar: PremiumBottomNav(
              currentIndex: selectedIndex,
              onTap: (index) => _onItemTapped(index, context),
            ),
          );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (selectedIndex == 0) {
          final shouldExit = await PremiumDialog.show<bool>(
            context: context,
            title: 'Exit Vattify',
            message: 'Are you sure you want to close the application?',
            primaryActionText: 'Exit',
            secondaryActionText: 'Cancel',
            isDestructive: true,
            icon: Icons.logout,
            onPrimaryAction: () => Navigator.of(context).pop(true),
          );
          if (shouldExit == true) {
            SystemNavigator.pop();
          }
        } else {
          context.go(RouteNames.dashboard);
        }
      },
      child: scaffold,
    );
  }

  List<NavigationRailDestination> _buildNavDestinations() {
    return const [
      NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Overview')),
      NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Borrowers')),
      NavigationRailDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: Text('Collections')),
      NavigationRailDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: Text('Reports')),
      NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
    ];
  }
}

class PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PremiumBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, bottom: AppSpacing.md),
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated.withOpacity(0.9) : AppColors.white.withOpacity(0.9),
        borderRadius: AppRadius.circular,
        boxShadow: AppShadows.premiumHeavy,
        border: Border.all(color: isDark ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.5)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Overview'),
            _buildNavItem(1, Icons.people_outline, Icons.people, 'Borrowers'),
            _buildNavItem(2, Icons.receipt_long_outlined, Icons.receipt_long, 'Collect'),
            _buildNavItem(3, Icons.analytics_outlined, Icons.analytics, 'Reports'),
            _buildNavItem(4, Icons.settings_outlined, Icons.settings, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16.w : 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.emeraldGreen.withOpacity(0.15) : Colors.transparent,
          borderRadius: AppRadius.circular,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.emeraldGreen : AppColors.textLight,
              size: 24.r,
            ),
            if (isSelected) ...[
              SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.emeraldGreen,
                  fontSize: 13.sp,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
