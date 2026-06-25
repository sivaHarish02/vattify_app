import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/notifications_provider.dart';

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
        return Colors.blue;
      case 'UPCOMING_DUE':
        return Colors.orange;
      case 'OVERDUE_COLLECTION':
        return Colors.red;
      case 'PENDING_INTEREST':
        return Colors.amber;
      default:
        return Colors.teal;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'DUE_TODAY':
        return Icons.today;
      case 'UPCOMING_DUE':
        return Icons.calendar_today;
      case 'OVERDUE_COLLECTION':
        return Icons.warning_amber_rounded;
      case 'PENDING_INTEREST':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.unreadCount > 0)
            TextButton.icon(
              onPressed: () async {
                await ref.read(notificationsProvider.notifier).markAllAsRead();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications marked as read')),
                  );
                }
              },
              icon: const Icon(Icons.mark_chat_read_outlined),
              label: const Text('Mark All Read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger server-side checks for any updates, then fetch
          await ref.read(notificationsProvider.notifier).triggerServerChecks();
        },
        child: state.isLoading && state.items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.items.isEmpty
                ? ListView(
                    children: [
                      SizedBox(height: 150.h),
                      Center(
                        child: Text(
                          'No notifications found.',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      final color = _getTypeColor(item.type);
                      final icon = _getTypeIcon(item.type);

                      return Card(
                        color: item.read ? null : color.withOpacity(0.04),
                        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        child: ListTile(
                          onTap: () {
                            if (!item.read) {
                              ref.read(notificationsProvider.notifier).markAsRead(item.id);
                            }
                          },
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.1),
                            child: Icon(icon, color: color, size: 20.r),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: item.read ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (!item.read)
                                Container(
                                  width: 8.w,
                                  height: 8.h,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.message,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: item.read ? Colors.grey : Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt),
                                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
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
