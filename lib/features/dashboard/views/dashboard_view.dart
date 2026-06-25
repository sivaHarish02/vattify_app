import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../../../routes/route_names.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/cards/premium_card.dart';
import '../../../core/widgets/buttons/premium_button.dart';
import '../../../features/auth/providers/auth_provider.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final userName = authState.user?.username ?? 'Admin';

    double collectionRatio = 0.0;
    if (state.kpis != null && state.kpis!.monthlyExpectedInterest > 0) {
      collectionRatio = state.kpis!.monthlyCollectedInterest /
          state.kpis!.monthlyExpectedInterest;
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardProvider.notifier).fetchDashboardData();
        },
        color: AppColors.emeraldGreen,
        child: Skeletonizer(
          enabled: state.isLoading,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getGreeting()},',
                                style: AppTypography.bodyLarge
                                    .copyWith(color: AppColors.textLight),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                userName,
                                style: AppTypography.headline,
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 24.r,
                            backgroundColor:
                                AppColors.emeraldGreen.withOpacity(0.1),
                            child: AppLogo.small(),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl),

                      // Hero Balance Card
                      PremiumCard(
                        backgroundColor: AppColors.emeraldGreen,
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_balance_wallet,
                                    color: AppColors.white.withOpacity(0.8),
                                    size: 20.r),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Total Active Balance',
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.white.withOpacity(0.9)),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              currencyFormatter
                                  .format(state.kpis?.totalActiveBalance ?? 0),
                              style: AppTypography.largeDisplay
                                  .copyWith(color: AppColors.white),
                            ),
                            SizedBox(height: AppSpacing.lg),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Monthly Expected',
                                      style: AppTypography.caption.copyWith(
                                          color:
                                              AppColors.white.withOpacity(0.7)),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      currencyFormatter.format(
                                          state.kpis?.monthlyExpectedInterest ??
                                              0),
                                      style: AppTypography.titleMedium
                                          .copyWith(color: AppColors.white),
                                    ),
                                  ],
                                ),
                                Container(
                                    width: 1,
                                    height: 32.h,
                                    color: AppColors.white.withOpacity(0.3)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'This Month Collected',
                                      style: AppTypography.caption.copyWith(
                                          color:
                                              AppColors.white.withOpacity(0.7)),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      currencyFormatter.format(state
                                              .kpis?.monthlyCollectedInterest ??
                                          0),
                                      style: AppTypography.titleMedium
                                          .copyWith(color: AppColors.white),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),

                      // Progress Section
                      Text('Collection Progress',
                          style: AppTypography.titleLarge),
                      SizedBox(height: AppSpacing.md),
                      PremiumCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    '${(collectionRatio * 100).toStringAsFixed(1)}%',
                                    style: AppTypography.headline.copyWith(
                                        color: AppColors.emeraldGreen)),
                                Text('of Monthly Target',
                                    style: AppTypography.bodyMedium
                                        .copyWith(color: AppColors.textLight)),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm),
                            ClipRRect(
                              borderRadius: AppRadius.circular,
                              child: LinearProgressIndicator(
                                value: collectionRatio.isNaN
                                    ? 0.0
                                    : collectionRatio,
                                backgroundColor: isDark
                                    ? AppColors.darkGrey
                                    : AppColors.lightGrey,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.emeraldGreen),
                                minHeight: 8.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),

                      // Grid KPIs
                      Text('Overview', style: AppTypography.titleLarge),
                      SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallKpiCard(
                              'Principal Given',
                              currencyFormatter
                                  .format(state.kpis?.totalPrincipalGiven ?? 0),
                              Icons.arrow_upward,
                              AppColors.info,
                              isDark,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildSmallKpiCard(
                              'Pending Overdue',
                              currencyFormatter.format(
                                  state.kpis?.totalPendingInterest ?? 0),
                              Icons.warning_amber_rounded,
                              AppColors.warning,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl),

                      // Quick Actions
                      Text('Quick Actions', style: AppTypography.titleLarge),
                      SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: PremiumButton(
                              text: 'Add Borrower',
                              icon: Icons.person_add_alt_1,
                              type: ButtonType.secondary,
                              onPressed: () => context.go(RouteNames.borrowers),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: PremiumButton(
                              text: 'Generate Run',
                              icon: Icons.autorenew,
                              type: ButtonType.secondary,
                              onPressed: () =>
                                  context.go(RouteNames.collections),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl),

                      // Recent Collections
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Collections',
                              style: AppTypography.titleLarge),
                          PremiumButton(
                            text: 'View All',
                            type: ButtonType.text,
                            isFullWidth: false,
                            onPressed: () => context.go(RouteNames.collections),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm),

                      if (state.recentCollections.isEmpty)
                        PremiumCard(
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: AppSpacing.xl),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      size: 48.r,
                                      color:
                                          AppColors.textLight.withOpacity(0.5)),
                                  SizedBox(height: AppSpacing.md),
                                  Text(
                                    'No collections recorded yet.',
                                    style: AppTypography.bodyMedium
                                        .copyWith(color: AppColors.textLight),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.recentCollections.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final item = state.recentCollections[index];
                            return PremiumCard(
                              padding: EdgeInsets.all(AppSpacing.sm),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm),
                                leading: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: AppRadius.md,
                                  ),
                                  child: Icon(Icons.arrow_downward,
                                      color: AppColors.success, size: 20.r),
                                ),
                                title: Text(item.borrowerName,
                                    style: AppTypography.titleMedium),
                                subtitle: Text(
                                  '${item.month}/${item.year} • ${DateFormat('dd MMM').format(item.date)}',
                                  style: AppTypography.caption,
                                ),
                                trailing: Text(
                                  currencyFormatter.format(item.amount),
                                  style: AppTypography.titleMedium
                                      .copyWith(color: AppColors.success),
                                ),
                              ),
                            );
                          },
                        ),

                      SizedBox(
                          height: 100.h), // padding for floating bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallKpiCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.sm,
            ),
            child: Icon(icon, color: color, size: 20.r),
          ),
          SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.caption),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTypography.titleLarge),
          ),
        ],
      ),
    );
  }
}
