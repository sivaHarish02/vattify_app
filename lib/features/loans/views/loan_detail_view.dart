import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/loans_provider.dart';
import '../../auth/providers/auth_provider.dart';

class LoanDetailView extends ConsumerWidget {
  final int loanId;

  const LoanDetailView({
    super.key,
    required this.loanId,
  });

  void _openAddTransactionSheet(BuildContext context, WidgetRef ref, double currentBalance) {
    final amountController = TextEditingController();
    final remarksController = TextEditingController();
    String type = 'RETURNED'; // Default to receiving principal back
    DateTime selectedDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Record Principal Transaction',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.h),
                      DropdownButtonFormField<String>(
                        value: type,
                        decoration: const InputDecoration(
                          labelText: 'Transaction Type',
                          prefixIcon: Icon(Icons.swap_horiz),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'RETURNED', child: Text('Principal Returned (Receive Cash)')),
                          DropdownMenuItem(value: 'GIVEN', child: Text('Principal Given (Lend More)')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() {
                              type = v;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || double.tryParse(v) == null) {
                            return 'Enter a valid amount';
                          }
                          final amt = double.parse(v);
                          if (type == 'RETURNED' && amt > currentBalance) {
                            return 'Returned amount cannot exceed current balance (₹${currentBalance.toStringAsFixed(0)})';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text('Transaction Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}'),
                        trailing: TextButton(
                          onPressed: () async {
                            final pick = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pick != null) {
                              setModalState(() {
                                selectedDate = pick;
                              });
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: remarksController,
                        decoration: const InputDecoration(
                          labelText: 'Remarks / Remarks',
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final success = await ref.read(loansProvider.notifier).createTransaction(
                                  loanId: loanId,
                                  amount: double.parse(amountController.text),
                                  type: type,
                                  date: selectedDate.toIso8601String(),
                                  remarks: remarksController.text.trim(),
                                );
                            if (success && context.mounted) {
                              Navigator.pop(context);
                              ref.invalidate(loanDetailProvider(loanId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Transaction recorded successfully')),
                              );
                            }
                          }
                        },
                        child: const Text('Record Transaction'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAsync = ref.watch(loanDetailProvider(loanId));
    final userState = ref.watch(authProvider);
    final isAdmin = userState.user?.isAdmin ?? false;
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Account Details'),
      ),
      body: loanAsync.when(
        data: (data) {
          final double loanAmount = double.parse(data['loanAmount']);
          final double currentBalance = double.parse(data['currentBalance']);
          final double interestRate = double.parse(data['interestRate']);
          final String interestType = data['interestType'];
          final DateTime loanDate = DateTime.parse(data['loanDate']);
          final String status = data['status'];
          final String borrowerName = data['borrower']['name'];

          final List transactionsList = data['transactions'] ?? [];
          final transactions = transactionsList.map((j) => TransactionModel.fromJson(j)).toList();

          final List collectionsList = data['collections'] ?? [];

          return DefaultTabController(
            length: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Info Summary Card
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Card(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            borrowerName,
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Loan Amount: ${currencyFormatter.format(loanAmount)}', style: TextStyle(fontSize: 13.sp)),
                              Text(
                                'Rate: $interestRate% (${interestType == 'FIXED' ? 'Fixed' : 'Reducing'})',
                                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current Balance: ${currencyFormatter.format(currentBalance)}',
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: status == 'ACTIVE' ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: status == 'ACTIVE' ? Colors.blue : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Start Date: ${DateFormat('dd MMMM yyyy').format(loanDate)}',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tab Bar
                TabBar(
                  tabs: const [
                    Tab(text: 'Principal Log'),
                    Tab(text: 'Interest Log'),
                  ],
                  labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    children: [
                      // 1. Transactions List
                      transactions.isEmpty
                          ? Center(child: Text('No transactions recorded.', style: TextStyle(fontSize: 13.sp)))
                          : ListView.builder(
                              itemCount: transactions.length,
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                final isGiven = tx.type == 'GIVEN';
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isGiven ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                      child: Icon(
                                        isGiven ? Icons.arrow_upward : Icons.arrow_downward,
                                        color: isGiven ? Colors.red : Colors.green,
                                        size: 18.r,
                                      ),
                                    ),
                                    title: Text(
                                      '${isGiven ? 'Cash Given' : 'Cash Returned'}: ${currencyFormatter.format(tx.amount)}',
                                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      '${DateFormat('dd MMM yyyy').format(tx.date)} ${tx.remarks != null ? '• ${tx.remarks}' : ''}',
                                      style: TextStyle(fontSize: 11.sp),
                                    ),
                                  ),
                                );
                              },
                            ),

                      // 2. Collections List
                      collectionsList.isEmpty
                          ? Center(child: Text('No interest collections generated.', style: TextStyle(fontSize: 13.sp)))
                          : ListView.builder(
                              itemCount: collectionsList.length,
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              itemBuilder: (context, index) {
                                final col = collectionsList[index];
                                final expected = double.parse(col['expectedAmount']);
                                final received = double.parse(col['receivedAmount']);
                                final status = col['status'];
                                final month = col['month'];
                                final year = col['year'];

                                Color statusColor = Colors.orange;
                                if (status == 'PAID') statusColor = Colors.green;
                                if (status == 'PENDING') statusColor = Colors.red;

                                return Card(
                                  child: ListTile(
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Period: $month/$year',
                                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(fontSize: 10.sp, color: statusColor, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: EdgeInsets.only(top: 4.h),
                                      child: Text(
                                        'Expected: ${currencyFormatter.format(expected)} • Received: ${currencyFormatter.format(received)}',
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: (err, _) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: loanAsync.when(
        data: (data) => isAdmin && data['status'] == 'ACTIVE'
            ? FloatingActionButton.extended(
                onPressed: () => _openAddTransactionSheet(context, ref, double.parse(data['currentBalance'])),
                icon: const Icon(Icons.add_card),
                label: const Text('Add Transaction'),
              )
            : null,
        error: (_, __) => null,
        loading: () => null,
      ),
    );
  }
}
