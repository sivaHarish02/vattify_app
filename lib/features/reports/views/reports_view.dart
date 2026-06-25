import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/reports_provider.dart';

class ReportsView extends ConsumerWidget {
  const ReportsView({super.key});

  Widget _buildSummaryRow(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp)),
          Text(
            value,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: color),
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

    final List<int> months = List.generate(12, (i) => i + 1);
    final List<int> years = List.generate(10, (i) => DateTime.now().year - 5 + i);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period filters
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: state.month,
                        decoration: const InputDecoration(labelText: 'Month'),
                        items: months
                            .map((m) => DropdownMenuItem(value: m, child: Text(DateFormat('MMMM').format(DateTime(2026, m)))))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            ref.read(reportsProvider.notifier).updatePeriod(v, state.year);
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: state.year,
                        decoration: const InputDecoration(labelText: 'Year'),
                        items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            ref.read(reportsProvider.notifier).updatePeriod(state.month, v);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Financial Summary Card
            Text(
              'Summary Aggregates',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: state.isLoading
                    ? SizedBox(
                        height: 150.h,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : state.summary == null
                        ? Center(child: Text('No data found for this period.', style: TextStyle(fontSize: 13.sp)))
                        : Column(
                            children: [
                              _buildSummaryRow(
                                context,
                                'Expected Interest collections',
                                currencyFormatter.format(state.summary!.expectedInterest),
                                theme.colorScheme.onBackground,
                              ),
                              const Divider(),
                              _buildSummaryRow(
                                context,
                                'Collected Interest',
                                currencyFormatter.format(state.summary!.collectedInterest),
                                Colors.green,
                              ),
                              const Divider(),
                              _buildSummaryRow(
                                context,
                                'Pending Overdue Interest',
                                currencyFormatter.format(state.summary!.pendingInterest),
                                Colors.red,
                              ),
                              const Divider(),
                              _buildSummaryRow(
                                context,
                                'Principal Returned',
                                currencyFormatter.format(state.summary!.principalReturned),
                                Colors.indigo,
                              ),
                            ],
                          ),
              ),
            ),
            SizedBox(height: 24.h),

            // Export Section
            Text(
              'Export Formats',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: state.isDownloading
                          ? null
                          : () async {
                              final path = await ref.read(reportsProvider.notifier).downloadPdfReport();
                              if (path != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('PDF downloaded successfully: $path')),
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to download PDF report')),
                                );
                              }
                            },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export to PDF Document'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton.icon(
                      onPressed: state.isDownloading
                          ? null
                          : () async {
                              final path = await ref.read(reportsProvider.notifier).downloadExcelReport();
                              if (path != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Excel downloaded successfully: $path')),
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to download Excel report')),
                                );
                              }
                            },
                      icon: const Icon(Icons.table_view),
                      label: const Text('Export to Excel Sheet'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.isDownloading) ...[
              SizedBox(height: 16.h),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Downloading file from server...'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
