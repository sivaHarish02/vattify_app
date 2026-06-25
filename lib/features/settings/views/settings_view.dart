import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    final user = authState.user;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User profile card
            if (user != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30.r,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.person, size: 36.r, color: theme.colorScheme.primary),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '@${user.username}',
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: user.isAdmin
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                user.isAdmin ? 'ADMINISTRATOR' : 'FAMILY MEMBER',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: user.isAdmin ? Colors.red : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 24.h),

            // Settings Group
            Text(
              'Preferences',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 8.h),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode Display'),
                    subtitle: const Text('Enable midnight slate colors'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    value: themeMode == ThemeMode.dark,
                    onChanged: (_) {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Session Group
            Text(
              'Session Management',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 8.h),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Sign out of your active Vattify session'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirm Sign Out'),
                        content: const Text('Are you sure you want to sign out? Your credentials cached locally will be cleared.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    await ref.read(authProvider.notifier).logout();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
