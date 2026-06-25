import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/collections_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/providers/notifications_provider.dart';

class CollectionsView extends ConsumerWidget {
  const CollectionsView({super.key});

  void _openPayDialog(BuildContext context, WidgetRef ref, CollectionItemModel item) {
    final remainingDue = item.expectedAmount - item.receivedAmount;
    final amountController = TextEditingController(text: remainingDue.toStringAsFixed(2));
    final remarksController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Record Interest Payment', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Borrower: ${item.borrowerName}',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Expected: ₹${item.expectedAmount.toStringAsFixed(2)}  |  Paid: ₹${item.receivedAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Received Amount (₹)',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || double.tryParse(v) == null) {
                      return 'Enter a valid amount';
                    }
                    final val = double.parse(v);
                    if (val <= 0) return 'Amount must be greater than zero';
                    if (val > remainingDue) {
                      return 'Cannot exceed remaining due of ₹${remainingDue.toStringAsFixed(2)}';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: remarksController,
                  decoration: const InputDecoration(
                    labelText: 'Remarks (Optional)',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final success = await ref.read(collectionsProvider.notifier).recordPayment(
                        collectionId: item.id,
                        amount: double.parse(amountController.text),
                        remarks: remarksController.text.trim(),
                      );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ref.read(notificationsProvider.notifier).fetchUnreadCount();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment recorded successfully')),
                    );
                  }
                }
              },
              child: const Text('Save Payment'),
            ),
          ],
        );
      },
    );
  }

  void _confirmGenerateRun(BuildContext context, WidgetRef ref, int month, int year) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Generate Collections', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          content: Text(
            'Do you want to run the auto-interest calculation and generate invoices for $month/$year? This scans all active loans.',
            style: TextStyle(fontSize: 13.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final res = await ref.read(collectionsProvider.notifier).generateCollectionsRun(month, year);
                if (res != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Calculation run complete. Invoices Created: ${res['generatedCount']}. Skipped: ${res['skippedCount']}.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Generate Run'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectionsProvider);
    final userState = ref.watch(authProvider);
    final isAdmin = userState.user?.isAdmin ?? false;
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    // List of months for dropdown
    final List<int> months = List.generate(12, (i) => i + 1);
    final List<int> years = List.generate(10, (i) => DateTime.now().year - 5 + i);

    return Scaffold(
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: state.month,
                    decoration: const InputDecoration(labelText: 'Month', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                    items: months
                        .map((m) => DropdownMenuItem(value: m, child: Text(DateFormat('MMMM').format(DateTime(2026, m)))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(collectionsProvider.notifier).updatePeriod(v, state.year);
                      }
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: state.year,
                    decoration: const InputDecoration(labelText: 'Year', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                    items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(collectionsProvider.notifier).updatePeriod(state.month, v);
                      }
                    },
                  ),
                ),
                if (isAdmin) ...[
                  SizedBox(width: 8.w),
                  IconButton.filled(
                    onPressed: () => _confirmGenerateRun(context, ref, state.month, state.year),
                    icon: Icon(Icons.flash_on, size: 20.r),
                    tooltip: 'Generate Interest Run',
                  ),
                ]
              ],
            ),
          ),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: state.statusFilter == null,
                  onSelected: (_) => ref.read(collectionsProvider.notifier).updateStatusFilter(null),
                ),
                SizedBox(width: 8.w),
                FilterChip(
                  label: const Text('Pending'),
                  selected: state.statusFilter == 'PENDING',
                  selectedColor: Colors.red.withOpacity(0.2),
                  onSelected: (_) => ref.read(collectionsProvider.notifier).updateStatusFilter('PENDING'),
                ),
                SizedBox(width: 8.w),
                FilterChip(
                  label: const Text('Partial'),
                  selected: state.statusFilter == 'PARTIAL',
                  selectedColor: Colors.orange.withOpacity(0.2),
                  onSelected: (_) => ref.read(collectionsProvider.notifier).updateStatusFilter('PARTIAL'),
                ),
                SizedBox(width: 8.w),
                FilterChip(
                  label: const Text('Paid'),
                  selected: state.statusFilter == 'PAID',
                  selectedColor: Colors.green.withOpacity(0.2),
                  onSelected: (_) => ref.read(collectionsProvider.notifier).updateStatusFilter('PAID'),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // Main List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.items.isEmpty
                    ? Center(
                        child: Text(
                          'No collections for this month.',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          final isPaid = item.status == 'PAID';
                          
                          Color statusColor = Colors.orange;
                          if (item.status == 'PAID') statusColor = Colors.green;
                          if (item.status == 'PENDING') statusColor = Colors.red;

                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.borrowerName,
                                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          item.status,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Expected: ${currencyFormatter.format(item.expectedAmount)}',
                                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                          ),
                                          Text(
                                            'Collected: ${currencyFormatter.format(item.receivedAmount)}',
                                            style: TextStyle(fontSize: 12.sp, color: Colors.green),
                                          ),
                                        ],
                                      ),
                                      if (!isPaid)
                                        ElevatedButton.icon(
                                          onPressed: () => _openPayDialog(context, ref, item),
                                          icon: Icon(Icons.payment, size: 14.r),
                                          label: Text('Collect', style: TextStyle(fontSize: 12.sp)),
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
