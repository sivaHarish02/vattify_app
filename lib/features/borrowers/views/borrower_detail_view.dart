import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/borrowers_provider.dart';
import '../../loans/providers/loans_provider.dart';
import '../../auth/providers/auth_provider.dart';

class BorrowerDetailView extends ConsumerWidget {
  final int borrowerId;

  const BorrowerDetailView({
    super.key,
    required this.borrowerId,
  });

  void _openAddLoanSheet(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final rateController = TextEditingController();
    final remarksController = TextEditingController();
    String interestType = 'FIXED';
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
                        'Create New Loan',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: amountController,
                        decoration: const InputDecoration(
                          labelText: 'Loan Amount (Principal)',
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Enter a valid amount' : null,
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: rateController,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Interest Rate (%)',
                          prefixIcon: Icon(Icons.percent),
                          hintText: 'e.g. 3',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Enter a valid rate' : null,
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        value: interestType,
                        decoration: const InputDecoration(
                          labelText: 'Interest Type',
                          prefixIcon: Icon(Icons.calculate),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'FIXED', child: Text('Fixed Rate')),
                          DropdownMenuItem(value: 'REDUCING', child: Text('Reducing Balance')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() {
                              interestType = v;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12.h),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text('Loan Start Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}'),
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
                          labelText: 'Remarks / Purpose (Optional)',
                          prefixIcon: Icon(Icons.chat_bubble_outline),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final success = await ref.read(loansProvider.notifier).createLoan(
                                  borrowerId: borrowerId,
                                  loanAmount: double.parse(amountController.text),
                                  interestRate: double.parse(rateController.text),
                                  interestType: interestType,
                                  loanDate: selectedDate.toIso8601String(),
                                  remarks: remarksController.text.trim(),
                                );
                            if (success && context.mounted) {
                              Navigator.pop(context);
                              ref.invalidate(borrowerDetailProvider(borrowerId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Loan created successfully')),
                              );
                            }
                          }
                        },
                        child: const Text('Create Loan'),
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

  void _openEditBorrowerSheet(BuildContext context, WidgetRef ref, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final mobileController = TextEditingController(text: data['mobile']);
    final addressController = TextEditingController(text: data['address']);
    final notesController = TextEditingController(text: data['notes']);
    String status = data['status'];
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
                        'Edit Borrower Profile',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: mobileController,
                        decoration: const InputDecoration(labelText: 'Mobile Number'),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Mobile is required' : null,
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        maxLines: 2,
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(labelText: 'Notes'),
                        maxLines: 2,
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                          DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() {
                              status = v;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final success = await ref.read(borrowersProvider.notifier).updateBorrower(
                                  borrowerId,
                                  nameController.text.trim(),
                                  mobileController.text.trim(),
                                  addressController.text.trim(),
                                  notesController.text.trim(),
                                  status,
                                );
                            if (success && context.mounted) {
                              Navigator.pop(context);
                              ref.invalidate(borrowerDetailProvider(borrowerId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Borrower profile updated')),
                              );
                            }
                          }
                        },
                        child: const Text('Update Profile'),
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
    final detailAsync = ref.watch(borrowerDetailProvider(borrowerId));
    final userState = ref.watch(authProvider);
    final isAdmin = userState.user?.isAdmin ?? false;
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrower Profile'),
        actions: [
          detailAsync.when(
            data: (data) => isAdmin
                ? IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _openEditBorrowerSheet(context, ref, data),
                  )
                : const SizedBox(),
            error: (_, __) => const SizedBox(),
            loading: () => const SizedBox(),
          ),
        ],
      ),
      body: detailAsync.when(
        data: (data) {
          final List loansList = data['loans'] ?? [];
          final loans = loansList.map((j) => LoanModel.fromJson(j)).toList();

          double totalLent = 0.0;
          double activeBalance = 0.0;
          for (var l in loans) {
            totalLent += l.loanAmount;
            if (l.status == 'ACTIVE') {
              activeBalance += l.currentBalance;
            }
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Details Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['name'],
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: data['status'] == 'ACTIVE' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                data['status'],
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: data['status'] == 'ACTIVE' ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16),
                            SizedBox(width: 8.w),
                            Text(data['mobile'], style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                        if (data['address'] != null && data['address'].toString().isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.home_outlined, size: 16),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  data['address'],
                                  style: TextStyle(fontSize: 13.sp),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (data['notes'] != null && data['notes'].toString().isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          const Divider(),
                          Text(
                            'Notes: ${data['notes']}',
                            style: TextStyle(fontSize: 12.sp, fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Financial Overview Metrics
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Principal Lent', style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                              SizedBox(height: 4.h),
                              Text(currencyFormatter.format(totalLent), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Outstanding Balance', style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                              SizedBox(height: 4.h),
                              Text(
                                currencyFormatter.format(activeBalance),
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.indigo),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Loans Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Loans List (${loans.length})',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    if (isAdmin)
                      TextButton.icon(
                        onPressed: () => _openAddLoanSheet(context, ref),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Loan'),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),

                if (loans.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: Text('No loans active for this borrower.', style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: loans.length,
                    itemBuilder: (context, index) {
                      final loan = loans[index];
                      return Card(
                        child: ListTile(
                          onTap: () {
                            context.push('/loans/${loan.id}');
                          },
                          leading: CircleAvatar(
                            backgroundColor: loan.status == 'ACTIVE' ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            child: Icon(
                              loan.status == 'ACTIVE' ? Icons.trending_up : Icons.check_circle_outline,
                              color: loan.status == 'ACTIVE' ? Colors.blue : Colors.grey,
                              size: 20.r,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currencyFormatter.format(loan.loanAmount),
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${loan.interestRate}% (${loan.interestType == 'FIXED' ? 'Fixed' : 'Reducing'})',
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              'Balance: ${currencyFormatter.format(loan.currentBalance)} • Start: ${DateFormat('dd MMM yyyy').format(loan.loanDate)}',
                              style: TextStyle(fontSize: 11.sp),
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18.r),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
        error: (err, _) => Center(child: Text('Error loading borrower: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
