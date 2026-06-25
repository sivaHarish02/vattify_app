import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../../../routes/route_names.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_logo.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  Widget _buildKpiCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 24.r,
              child: Icon(icon, color: color, size: 24.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style:
                        theme.textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final theme = Theme.of(context);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    // Dynamic rates calculations
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
        child: Skeletonizer(
          enabled: state.isLoading,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Target Summary Indicator
                Card(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Interest Collection Progress',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontSize: 16.sp),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currencyFormatter.format(
                                  state.kpis?.monthlyCollectedInterest ?? 0),
                              style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary),
                            ),
                            Text(
                              'Target: ${currencyFormatter.format(state.kpis?.monthlyExpectedInterest ?? 0)}',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: theme.textTheme.bodyMedium?.color),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        LinearProgressIndicator(
                          value: collectionRatio.isNaN ? 0.0 : collectionRatio,
                          backgroundColor: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(4.r),
                          minHeight: 8.h,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${(collectionRatio * 100).toStringAsFixed(1)}% collected for this month',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // 2. Main KPI Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 1.35,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildKpiCard(
                      context,
                      'Total Principal Given',
                      currencyFormatter
                          .format(state.kpis?.totalPrincipalGiven ?? 0),
                      Icons.arrow_upward,
                      Colors.blue,
                    ),
                    _buildKpiCard(
                      context,
                      'Active Outstanding',
                      currencyFormatter
                          .format(state.kpis?.totalActiveBalance ?? 0),
                      Icons.account_balance_wallet,
                      Colors.indigo,
                    ),
                    _buildKpiCard(
                      context,
                      'Monthly Expected',
                      currencyFormatter
                          .format(state.kpis?.monthlyExpectedInterest ?? 0),
                      Icons.event_note,
                      Colors.orange,
                    ),
                    _buildKpiCard(
                      context,
                      'Pending Overdue',
                      currencyFormatter
                          .format(state.kpis?.totalPendingInterest ?? 0),
                      Icons.warning_amber_rounded,
                      Colors.red,
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // 3. Quick Actions
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(RouteNames.borrowers),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Add Borrower'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(RouteNames.collections),
                        icon: const Icon(Icons.autorenew),
                        label: const Text('Generate Run'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // 4. Recent Collections List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Collections',
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.collections),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                if (state.recentCollections.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: 0.2,
                            child: AppLogo.small(),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No collections recorded recently.',
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.recentCollections.length,
                    itemBuilder: (context, index) {
                      final item = state.recentCollections[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(0.1),
                          child: Icon(Icons.arrow_downward,
                              color: Colors.green, size: 20.r),
                        ),
                        title: Text(item.borrowerName,
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          'Interest for ${item.month}/${item.year} • ${DateFormat('dd MMM').format(item.date)}',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        trailing: Text(
                          currencyFormatter.format(item.amount),
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
