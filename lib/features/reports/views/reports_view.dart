import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/reports_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/widgets/cards/premium_card.dart';
import '../../../core/widgets/buttons/premium_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ReportsView extends ConsumerWidget {
  const ReportsView({super.key});

  Widget _buildSummaryRow(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: AppRadius.sm,
                ),
                child: Icon(icon, color: color, size: 16.r),
              ),
              SizedBox(width: AppSpacing.md),
              Text(label, style: AppTypography.titleMedium),
            ],
          ),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<int> months = List.generate(12, (i) => i + 1);
    final List<int> years = List.generate(10, (i) => DateTime.now().year - 5 + i);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period filters
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: state.month,
                    decoration: InputDecoration(
                      labelText: 'Month',
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.softWhite,
                      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12.h),
                      border: OutlineInputBorder(borderRadius: AppRadius.md, borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: AppRadius.md, borderSide: BorderSide(color: isDark ? AppColors.darkGrey : AppColors.lightGrey)),
                      focusedBorder: OutlineInputBorder(borderRadius: AppRadius.md, borderSide: const BorderSide(color: AppColors.emeraldGreen, width: 2)),
                    ),
                    items: months
                        .map((m) => DropdownMenuItem(value: m, child: Text(DateFormat('MMMM').format(DateTime(2026, m)))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) ref.read(reportsProvider.notifier).updatePeriod(v, state.year);
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: state.year,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.softWhite,
                      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12.h),
                      border: OutlineInputBorder(borderRadius: AppRadius.md, borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: AppRadius.md, borderSide: BorderSide(color: isDark ? AppColors.darkGrey : AppColors.lightGrey)),
                      focusedBorder: OutlineInputBorder(borderRadius: AppRadius.md, borderSide: const BorderSide(color: AppColors.emeraldGreen, width: 2)),
                    ),
                    items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                    onChanged: (v) {
                      if (v != null) ref.read(reportsProvider.notifier).updatePeriod(state.month, v);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xl),

            // Financial Summary Card
            Text(
              'Summary Aggregates',
              style: AppTypography.titleLarge,
            ),
            SizedBox(height: AppSpacing.md),
            Skeletonizer(
              enabled: state.isLoading,
              child: PremiumCard(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: state.summary == null && !state.isLoading
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                          child: Column(
                            children: [
                              Opacity(opacity: 0.5, child: Icon(Icons.analytics_outlined, size: 48.r, color: AppColors.textLight)),
                              SizedBox(height: AppSpacing.sm),
                              Text('No data found for this period.', style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight)),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          _buildSummaryRow(
                            'Expected Interest',
                            currencyFormatter.format(state.summary?.expectedInterest ?? 0),
                            isDark ? AppColors.white : AppColors.textDark,
                            Icons.event_note,
                          ),
                          Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                          _buildSummaryRow(
                            'Collected Interest',
                            currencyFormatter.format(state.summary?.collectedInterest ?? 0),
                            AppColors.success,
                            Icons.check_circle_outline,
                          ),
                          Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                          _buildSummaryRow(
                            'Pending Overdue',
                            currencyFormatter.format(state.summary?.pendingInterest ?? 0),
                            AppColors.danger,
                            Icons.warning_amber_rounded,
                          ),
                          Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                          _buildSummaryRow(
                            'Principal Returned',
                            currencyFormatter.format(state.summary?.principalReturned ?? 0),
                            AppColors.info,
                            Icons.account_balance_wallet,
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // Export Section
            Text(
              'Export Options',
              style: AppTypography.titleLarge,
            ),
            SizedBox(height: AppSpacing.md),
            PremiumCard(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  PremiumButton(
                    text: 'Export as PDF',
                    icon: Icons.picture_as_pdf,
                    isLoading: state.isDownloading,
                    onPressed: state.isDownloading
                        ? null
                        : () async {
                            final path = await ref.read(reportsProvider.notifier).downloadPdfReport();
                            if (path != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('PDF downloaded successfully: $path'), backgroundColor: AppColors.emeraldGreen),
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to download PDF report'), backgroundColor: AppColors.danger),
                              );
                            }
                          },
                  ),
                  SizedBox(height: AppSpacing.md),
                  PremiumButton(
                    text: 'Export as Excel',
                    icon: Icons.table_view,
                    type: ButtonType.secondary,
                    isLoading: state.isDownloading,
                    onPressed: state.isDownloading
                        ? null
                        : () async {
                            final path = await ref.read(reportsProvider.notifier).downloadExcelReport();
                            if (path != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Excel downloaded successfully: $path'), backgroundColor: AppColors.emeraldGreen),
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to download Excel report'), backgroundColor: AppColors.danger),
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}
