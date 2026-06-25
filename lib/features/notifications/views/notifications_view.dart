import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/notifications_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationsProvider.notifier).fetchNotifications();
    });
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'DUE_TODAY':
        return AppColors.info;
      case 'UPCOMING_DUE':
        return AppColors.warning;
      case 'OVERDUE_COLLECTION':
        return AppColors.danger;
      case 'PENDING_INTEREST':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'DUE_TODAY':
        return Icons.today_rounded;
      case 'UPCOMING_DUE':
        return Icons.event_rounded;
      case 'OVERDUE_COLLECTION':
        return Icons.warning_rounded;
      case 'PENDING_INTEREST':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.richBlack : AppColors.softWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
        ),
        actions: [
          if (state.unreadCount > 0)
            Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: TextButton.icon(
                onPressed: () async {
                  await ref
                      .read(notificationsProvider.notifier)
                      .markAllAsRead();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('All notifications marked as read'),
                        behavior: SnackBarBehavior.floating,
                        shape:
                            RoundedRectangleBorder(borderRadius: AppRadius.md),
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.textDark,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.done_all_rounded,
                    size: 18.sp, color: AppColors.primary),
                label: Text(
                  'Mark All Read',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 0),
                  shape:
                      RoundedRectangleBorder(borderRadius: AppRadius.circular),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await ref.read(notificationsProvider.notifier).triggerServerChecks();
        },
        child: state.isLoading && state.items.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : state.items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 120.h),
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isDark
                                    ? AppColors.darkSurfaceElevated
                                    : AppColors.white)
                                .withOpacity(0.5),
                          ),
                          child: Icon(
                            Icons.notifications_off_rounded,
                            size: 64.sp,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.lightGrey,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Center(
                        child: Text(
                          'You\'re all caught up!',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? AppColors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Center(
                        child: Text(
                          'No new notifications at the moment.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.md),
                    itemCount: state.items.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      final color = _getTypeColor(item.type);
                      final icon = _getTypeIcon(item.type);

                      return GestureDetector(
                        onTap: () {
                          if (!item.read) {
                            ref
                                .read(notificationsProvider.notifier)
                                .markAsRead(item.id);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceElevated
                                : AppColors.white,
                            borderRadius: AppRadius.md,
                            boxShadow: isDark ? [] : AppShadows.premiumSoft,
                            border: item.read
                                ? null
                                : Border.all(
                                    color: color.withOpacity(0.3), width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: AppRadius.md,
                            child: Stack(
                              children: [
                                if (!item.read)
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 4.w,
                                      color: color,
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.r),
                                        decoration: BoxDecoration(
                                          color: color
                                              .withOpacity(isDark ? 0.2 : 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(icon,
                                            color: color, size: 24.r),
                                      ),
                                      SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.title,
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight: item.read
                                                          ? FontWeight.w500
                                                          : FontWeight.w700,
                                                      color: isDark
                                                          ? AppColors.white
                                                          : AppColors.textDark,
                                                    ),
                                                  ),
                                                ),
                                                if (!item.read)
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: AppSpacing.sm),
                                                    width: 8.r,
                                                    height: 8.r,
                                                    decoration: BoxDecoration(
                                                      color: color,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: color
                                                              .withOpacity(0.4),
                                                          blurRadius: 4,
                                                          spreadRadius: 1,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(height: AppSpacing.xs),
                                            Text(
                                              item.message,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: item.read
                                                    ? AppColors.textLight
                                                    : (isDark
                                                        ? AppColors.softWhite
                                                        : AppColors.textDark
                                                            .withOpacity(0.8)),
                                                height: 1.4,
                                              ),
                                            ),
                                            SizedBox(height: AppSpacing.sm),
                                            Text(
                                              DateFormat(
                                                      'dd MMM yyyy • hh:mm a')
                                                  .format(item.createdAt),
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textLight
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
