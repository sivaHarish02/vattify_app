import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/collections_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/widgets/cards/premium_card.dart';
import '../../../core/widgets/inputs/premium_text_field.dart';
import '../../../core/widgets/buttons/premium_button.dart';
import '../../../core/widgets/dialogs/premium_dialog.dart';

class CollectionsView extends ConsumerWidget {
  const CollectionsView({super.key});

  void _openPayDialog(BuildContext context, WidgetRef ref, CollectionItemModel item) {
    final remainingDue = item.expectedAmount - item.receivedAmount;
    final amountController = TextEditingController(text: remainingDue.toStringAsFixed(2));
    final remarksController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                  Text('Record Interest Payment', style: AppTypography.headline),
                  SizedBox(height: AppSpacing.sm),
                  
                  PremiumCard(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 16.r, color: AppColors.textLight),
                            SizedBox(width: AppSpacing.sm),
                            Text(item.borrowerName, style: AppTypography.titleMedium),
                          ],
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Expected', style: AppTypography.caption),
                                Text('₹${item.expectedAmount.toStringAsFixed(2)}', style: AppTypography.titleMedium.copyWith(color: AppColors.info)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Paid', style: AppTypography.caption),
                                Text('₹${item.receivedAmount.toStringAsFixed(2)}', style: AppTypography.titleMedium.copyWith(color: AppColors.success)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  
                  PremiumTextField(
                    label: 'Received Amount (₹)',
                    controller: amountController,
                    prefixIcon: const Icon(Icons.currency_rupee),
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
                  PremiumTextField(
                    label: 'Remarks (Optional)',
                    controller: remarksController,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  
                  Row(
                    children: [
                      Expanded(
                        child: PremiumButton(
                          text: 'Cancel',
                          type: ButtonType.secondary,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: PremiumButton(
                          text: 'Save Payment',
                          icon: Icons.check_circle_outline,
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmGenerateRun(BuildContext context, WidgetRef ref, int month, int year) {
    PremiumDialog.show(
      context: context,
      title: 'Generate Collections',
      message: 'Do you want to run the auto-interest calculation and generate invoices for $month/$year? This scans all active loans.',
      primaryActionText: 'Generate Run',
      secondaryActionText: 'Cancel',
      icon: Icons.flash_on,
      onPrimaryAction: () async {
        Navigator.pop(context);
        final res = await ref.read(collectionsProvider.notifier).generateCollectionsRun(month, year);
        if (res != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Calculation run complete. Invoices Created: ${res['generatedCount']}. Skipped: ${res['skippedCount']}.'),
              backgroundColor: AppColors.emeraldGreen,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectionsProvider);
    final userState = ref.watch(authProvider);
    final isAdmin = userState.user?.isAdmin ?? false;
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<int> months = List.generate(12, (i) => i + 1);
    final List<int> years = List.generate(10, (i) => DateTime.now().year - 5 + i);

    return Scaffold(
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Row(
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
                    items: months.map((m) => DropdownMenuItem(value: m, child: Text(DateFormat('MMM').format(DateTime(2026, m))))).toList(),
                    onChanged: (v) {
                      if (v != null) ref.read(collectionsProvider.notifier).updatePeriod(v, state.year);
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
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
                      if (v != null) ref.read(collectionsProvider.notifier).updatePeriod(state.month, v);
                    },
                  ),
                ),
                if (isAdmin) ...[
                  SizedBox(width: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.emeraldGreen,
                      borderRadius: AppRadius.md,
                      boxShadow: AppShadows.premiumSoft,
                    ),
                    child: IconButton(
                      onPressed: () => _confirmGenerateRun(context, ref, state.month, state.year),
                      icon: Icon(Icons.flash_on, color: AppColors.white, size: 24.r),
                      tooltip: 'Generate Interest Run',
                    ),
                  ),
                ]
              ],
            ),
          ),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _buildFilterChip('All', null, state.statusFilter, ref, isDark),
                SizedBox(width: AppSpacing.sm),
                _buildFilterChip('Pending', 'PENDING', state.statusFilter, ref, isDark, activeColor: AppColors.danger),
                SizedBox(width: AppSpacing.sm),
                _buildFilterChip('Partial', 'PARTIAL', state.statusFilter, ref, isDark, activeColor: AppColors.warning),
                SizedBox(width: AppSpacing.sm),
                _buildFilterChip('Paid', 'PAID', state.statusFilter, ref, isDark, activeColor: AppColors.success),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Main List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.emeraldGreen))
                : state.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(opacity: 0.5, child: Icon(Icons.receipt_long_outlined, size: 64.r, color: AppColors.textLight)),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'No collections for this month.',
                              style: AppTypography.titleMedium.copyWith(color: AppColors.textLight),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, bottom: 100.h),
                        itemCount: state.items.length,
                        separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          final isPaid = item.status == 'PAID';
                          
                          Color statusColor = AppColors.warning;
                          if (item.status == 'PAID') statusColor = AppColors.success;
                          if (item.status == 'PENDING') statusColor = AppColors.danger;

                          return PremiumCard(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20.r,
                                          backgroundColor: statusColor.withOpacity(0.1),
                                          child: Icon(Icons.person_outline, color: statusColor, size: 20.r),
                                        ),
                                        SizedBox(width: AppSpacing.md),
                                        Text(
                                          item.borrowerName,
                                          style: AppTypography.titleMedium,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: AppRadius.sm,
                                      ),
                                      child: Text(
                                        item.status,
                                        style: AppTypography.caption.copyWith(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppSpacing.md),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Expected: ${currencyFormatter.format(item.expectedAmount)}',
                                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          'Collected: ${currencyFormatter.format(item.receivedAmount)}',
                                          style: AppTypography.titleMedium.copyWith(color: AppColors.success),
                                        ),
                                      ],
                                    ),
                                    if (!isPaid)
                                      PremiumButton(
                                        text: 'Collect',
                                        icon: Icons.payment,
                                        isFullWidth: false,
                                        onPressed: () => _openPayDialog(context, ref, item),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, String? currentValue, WidgetRef ref, bool isDark, {Color activeColor = AppColors.emeraldGreen}) {
    final isSelected = value == currentValue;
    return FilterChip(
      label: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: isSelected ? (isDark ? AppColors.white : AppColors.white) : AppColors.textLight,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      showCheckmark: false,
      backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.softWhite,
      selectedColor: activeColor,
      side: BorderSide(
        color: isSelected ? Colors.transparent : (isDark ? AppColors.darkGrey : AppColors.lightGrey),
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.circular),
      onSelected: (_) => ref.read(collectionsProvider.notifier).updateStatusFilter(value),
    );
  }
}
