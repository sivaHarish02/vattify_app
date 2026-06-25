import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../providers/borrowers_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/cards/premium_card.dart';
import '../../../core/widgets/inputs/premium_text_field.dart';
import '../../../core/widgets/buttons/premium_button.dart';

class BorrowersView extends ConsumerStatefulWidget {
  const BorrowersView({super.key});

  @override
  ConsumerState<BorrowersView> createState() => _BorrowersViewState();
}

class _BorrowersViewState extends ConsumerState<BorrowersView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200.h) {
      ref.read(borrowersProvider.notifier).fetchBorrowers();
    }
  }

  void _openAddBorrowerSheet() {
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final addressController = TextEditingController();
    final notesController = TextEditingController();
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
                  Text('Add New Borrower', style: AppTypography.headline),
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
                    label: 'Address (Optional)',
                    controller: addressController,
                    prefixIcon: const Icon(Icons.home_outlined),
                  ),
                  PremiumTextField(
                    label: 'Notes / Remarks (Optional)',
                    controller: notesController,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  PremiumButton(
                    text: 'Save Borrower',
                    icon: Icons.check_circle_outline,
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final success = await ref.read(borrowersProvider.notifier).createBorrower(
                              nameController.text.trim(),
                              mobileController.text.trim(),
                              addressController.text.trim(),
                              notesController.text.trim(),
                            );
                        if (success && mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Borrower added successfully')),
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
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(borrowersProvider);
    final userState = ref.watch(authProvider);
    final isAdmin = userState.user?.isAdmin ?? false;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: TextField(
              controller: _searchController,
              style: AppTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search borrowers by name or mobile...',
                hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textLight),
                prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 20.r),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.textLight, size: 20.r),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(borrowersProvider.notifier).updateSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.softWhite,
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14.h),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.circular,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.circular,
                  borderSide: BorderSide(color: isDark ? AppColors.darkGrey : AppColors.lightGrey.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.circular,
                  borderSide: const BorderSide(color: AppColors.emeraldGreen, width: 2),
                ),
              ),
              onChanged: (v) {
                ref.read(borrowersProvider.notifier).updateSearch(v);
              },
            ),
          ),
          
          // Borrowers List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(borrowersProvider.notifier).fetchBorrowers(refresh: true);
              },
              color: AppColors.emeraldGreen,
              child: Skeletonizer(
                enabled: state.isLoading && state.items.isEmpty,
                child: state.items.isEmpty && !state.isLoading
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 100.h),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Opacity(opacity: 0.5, child: Icon(Icons.people_outline, size: 64.r, color: AppColors.textLight)),
                                SizedBox(height: AppSpacing.md),
                                Text(
                                  'No borrowers found.',
                                  style: AppTypography.titleMedium.copyWith(color: AppColors.textLight),
                                ),
                                SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Try adjusting your search.',
                                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        itemCount: state.items.length + (state.isMoreLoading ? 1 : 0),
                        separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          if (index == state.items.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                              child: const Center(
                                child: CircularProgressIndicator(color: AppColors.emeraldGreen),
                              ),
                            );
                          }

                          final item = state.items[index];
                          final isActive = item.status == 'ACTIVE';

                          return PremiumCard(
                            padding: EdgeInsets.zero,
                            onTap: () => context.push('/borrowers/${item.id}'),
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24.r,
                                    backgroundColor: isActive
                                        ? AppColors.emeraldGreen.withOpacity(0.1)
                                        : AppColors.textLight.withOpacity(0.1),
                                    child: Text(
                                      item.name.substring(0, 1).toUpperCase(),
                                      style: AppTypography.titleLarge.copyWith(
                                        color: isActive ? AppColors.emeraldGreen : AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.name,
                                                style: AppTypography.titleMedium,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                              decoration: BoxDecoration(
                                                color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                                                borderRadius: AppRadius.sm,
                                              ),
                                              child: Text(
                                                item.status,
                                                style: AppTypography.caption.copyWith(
                                                  color: isActive ? AppColors.success : AppColors.warning,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          '${item.mobile} • ${item.loanCount} Loan(s)',
                                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  Icon(Icons.chevron_right, color: AppColors.textLight, size: 20.r),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _openAddBorrowerSheet,
              backgroundColor: AppColors.emeraldGreen,
              foregroundColor: AppColors.white,
              elevation: 4,
              child: const Icon(Icons.person_add_alt_1),
            )
          : null,
    );
  }
}
