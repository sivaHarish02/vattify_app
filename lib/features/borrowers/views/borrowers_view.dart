import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/borrowers_provider.dart';
import '../../auth/providers/auth_provider.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
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
                    'Add New Borrower',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: mobileController,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Mobile is required' : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address (Optional)',
                      prefixIcon: Icon(Icons.home),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes / Remarks (Optional)',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
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
                    child: const Text('Save Borrower'),
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

    return Scaffold(
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: EdgeInsets.all(12.r),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search borrowers by name or mobile...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(borrowersProvider.notifier).updateSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
              child: state.items.isEmpty && !state.isLoading
                  ? Center(
                      child: Text(
                        'No borrowers found.',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: state.items.length + (state.isMoreLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.items.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }

                        final item = state.items[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          child: ListTile(
                            onTap: () {
                              context.push('/borrowers/${item.id}');
                            },
                            leading: CircleAvatar(
                              backgroundColor: item.status == 'ACTIVE'
                                  ? theme.colorScheme.primary.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              child: Text(
                                item.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: item.status == 'ACTIVE' ? theme.colorScheme.primary : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: item.status == 'ACTIVE' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    item.status,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: item.status == 'ACTIVE' ? Colors.green : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                '${item.mobile} • ${item.loanCount} Loan(s)',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                            trailing: Icon(Icons.chevron_right, size: 20.r),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _openAddBorrowerSheet,
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }
}
