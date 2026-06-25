import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/borrowers_provider.dart';
import '../../loans/providers/loans_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/widgets/cards/premium_card.dart';
import '../../../core/widgets/inputs/premium_text_field.dart';
import '../../../core/widgets/buttons/premium_button.dart';

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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: AppShadows.premiumHeavy,
              ),
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkGrey : AppColors.lightGrey,
                            borderRadius: AppRadius.circular,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text('Create New Loan', style: AppTypography.headline),
                      SizedBox(height: AppSpacing.xl),
                      
                      PremiumTextField(
                        label: 'Loan Amount (Principal)',
                        controller: amountController,
                        prefixIcon: const Icon(Icons.currency_rupee),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Enter a valid amount' : null,
                      ),
                      PremiumTextField(
                        label: 'Monthly Interest Rate (%)',
                        controller: rateController,
                        prefixIcon: const Icon(Icons.percent),
                        hint: 'e.g. 3',
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Enter a valid rate' : null,
                      ),
                      
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Interest Type', style: AppTypography.titleMedium.copyWith(fontSize: 13.sp)),
                            SizedBox(height: AppSpacing.sm),
                            DropdownButtonFormField<String>(
                              value: interestType,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.calculate_outlined),
                                filled: true,
                                fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.softWhite,
                                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16.h),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.md,
                                  borderSide: BorderSide(color: isDark ? AppColors.darkGrey : AppColors.lightGrey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.md,
                                  borderSide: const BorderSide(color: AppColors.emeraldGreen, width: 2),
                                ),
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
                          ],
                        ),
                      ),
                      
                      PremiumCard(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          leading: Icon(Icons.calendar_today, color: AppColors.textLight, size: 24.r),
                          title: Text('Loan Start Date', style: AppTypography.caption),
                          subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate), style: AppTypography.titleMedium),
                          trailing: PremiumButton(
                            text: 'Change',
                            type: ButtonType.text,
                            isFullWidth: false,
                            onPressed: () async {
                              final pick = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: AppColors.emeraldGreen,
                                        onPrimary: AppColors.white,
                                        onSurface: isDark ? AppColors.white : AppColors.textDark,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pick != null) {
                                setModalState(() {
                                  selectedDate = pick;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      
                      PremiumTextField(
                        label: 'Remarks / Purpose (Optional)',
                        controller: remarksController,
                        prefixIcon: const Icon(Icons.chat_bubble_outline),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      
                      PremiumButton(
                        text: 'Create Loan',
                        icon: Icons.check_circle_outline,
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: AppShadows.premiumHeavy,
              ),
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkGrey : AppColors.lightGrey,
                            borderRadius: AppRadius.circular,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text('Edit Borrower Profile', style: AppTypography.headline),
                      SizedBox(height: AppSpacing.xl),
                      
                      PremiumTextField(
                        label: 'Full Name',
                        controller: nameController,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                      ),
                      PremiumTextField(
                        label: 'Mobile Number',
                        controller: mobileController,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Mobile is required' : null,
                      ),
                      PremiumTextField(
                        label: 'Address',
                        controller: addressController,
                        prefixIcon: const Icon(Icons.home_outlined),
                      ),
                      PremiumTextField(
                        label: 'Notes',
                        controller: notesController,
                        prefixIcon: const Icon(Icons.notes_outlined),
                      ),
                      
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status', style: AppTypography.titleMedium.copyWith(fontSize: 13.sp)),
                            SizedBox(height: AppSpacing.sm),
                            DropdownButtonFormField<String>(
                              value: status,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.info_outline),
                                filled: true,
                                fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.softWhite,
                                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16.h),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.md,
                                  borderSide: BorderSide(color: isDark ? AppColors.darkGrey : AppColors.lightGrey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.md,
                                  borderSide: const BorderSide(color: AppColors.emeraldGreen, width: 2),
                                ),
                              ),
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
                          ],
                        ),
                      ),
                      
                      SizedBox(height: AppSpacing.xl),
                      PremiumButton(
                        text: 'Update Profile',
                        icon: Icons.check_circle_outline,
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
        title: Text('Borrower Profile', style: AppTypography.headline),
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
          SizedBox(width: AppSpacing.sm),
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

          final isActive = data['status'] == 'ACTIVE';

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Details Card
                      PremiumCard(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28.r,
                                      backgroundColor: isActive ? AppColors.emeraldGreen.withOpacity(0.1) : AppColors.textLight.withOpacity(0.1),
                                      child: Text(
                                        data['name'].toString().substring(0, 1).toUpperCase(),
                                        style: AppTypography.headline.copyWith(
                                          color: isActive ? AppColors.emeraldGreen : AppColors.textLight,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.md),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data['name'], style: AppTypography.headline),
                                        SizedBox(height: 4.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                                            borderRadius: AppRadius.sm,
                                          ),
                                          child: Text(
                                            data['status'],
                                            style: AppTypography.caption.copyWith(
                                              color: isActive ? AppColors.success : AppColors.warning,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Icon(Icons.phone_outlined, size: 20.r, color: AppColors.textLight),
                                SizedBox(width: AppSpacing.sm),
                                Text(data['mobile'], style: AppTypography.titleMedium),
                              ],
                            ),
                            if (data['address'] != null && data['address'].toString().isNotEmpty) ...[
                              SizedBox(height: AppSpacing.md),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.home_outlined, size: 20.r, color: AppColors.textLight),
                                  SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      data['address'],
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (data['notes'] != null && data['notes'].toString().isNotEmpty) ...[
                              SizedBox(height: AppSpacing.md),
                              Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                'Notes: ${data['notes']}',
                                style: AppTypography.bodyMedium.copyWith(fontStyle: FontStyle.italic, color: AppColors.textLight),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),

                      // Financial Overview Metrics
                      Text('Financial Overview', style: AppTypography.titleLarge),
                      SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: PremiumCard(
                              padding: EdgeInsets.all(AppSpacing.md),
                              backgroundColor: AppColors.info,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.arrow_upward, color: AppColors.white.withOpacity(0.8), size: 16.r),
                                      SizedBox(width: AppSpacing.xs),
                                      Text('Total Lent', style: AppTypography.caption.copyWith(color: AppColors.white.withOpacity(0.8))),
                                    ],
                                  ),
                                  SizedBox(height: AppSpacing.sm),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      currencyFormatter.format(totalLent),
                                      style: AppTypography.headline.copyWith(color: AppColors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: PremiumCard(
                              padding: EdgeInsets.all(AppSpacing.md),
                              backgroundColor: AppColors.emeraldGreen,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet, color: AppColors.white.withOpacity(0.8), size: 16.r),
                                      SizedBox(width: AppSpacing.xs),
                                      Text('Outstanding', style: AppTypography.caption.copyWith(color: AppColors.white.withOpacity(0.8))),
                                    ],
                                  ),
                                  SizedBox(height: AppSpacing.sm),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      currencyFormatter.format(activeBalance),
                                      style: AppTypography.headline.copyWith(color: AppColors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl),

                      // Loans Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Loans (${loans.length})',
                            style: AppTypography.titleLarge,
                          ),
                          if (isAdmin)
                            PremiumButton(
                              text: 'Add Loan',
                              type: ButtonType.text,
                              isFullWidth: false,
                              onPressed: () => _openAddLoanSheet(context, ref),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm),

                      if (loans.isEmpty)
                        PremiumCard(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                            child: Center(
                              child: Column(
                                children: [
                                  Opacity(opacity: 0.5, child: Icon(Icons.request_page_outlined, size: 48.r, color: AppColors.textLight)),
                                  SizedBox(height: AppSpacing.md),
                                  Text('No active loans for this borrower.', style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight)),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: loans.length,
                          separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final loan = loans[index];
                            final isLoanActive = loan.status == 'ACTIVE';

                            return PremiumCard(
                              padding: EdgeInsets.zero,
                              onTap: () => context.push('/loans/${loan.id}'),
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: isLoanActive ? AppColors.info.withOpacity(0.1) : AppColors.textLight.withOpacity(0.1),
                                        borderRadius: AppRadius.md,
                                      ),
                                      child: Icon(
                                        isLoanActive ? Icons.trending_up : Icons.check_circle_outline,
                                        color: isLoanActive ? AppColors.info : AppColors.textLight,
                                        size: 24.r,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                currencyFormatter.format(loan.loanAmount),
                                                style: AppTypography.titleMedium,
                                              ),
                                              Text(
                                                '${loan.interestRate}% (${loan.interestType == 'FIXED' ? 'Fixed' : 'Reducing'})',
                                                style: AppTypography.caption,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4.h),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Balance: ${currencyFormatter.format(loan.currentBalance)}',
                                                style: AppTypography.bodyMedium.copyWith(
                                                  color: isLoanActive ? AppColors.emeraldGreen : AppColors.textLight,
                                                  fontWeight: isLoanActive ? FontWeight.w600 : FontWeight.normal,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('dd MMM yy').format(loan.loanDate),
                                                style: AppTypography.caption,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Icon(Icons.chevron_right, size: 20.r, color: AppColors.textLight),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (err, _) => Center(child: Text('Error loading borrower: $err', style: AppTypography.bodyLarge.copyWith(color: AppColors.danger))),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.emeraldGreen)),
      ),
    );
  }
}
