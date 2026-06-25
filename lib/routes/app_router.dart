import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

// Import Views
import '../features/auth/views/login_view.dart';
import '../features/dashboard/views/dashboard_view.dart';
import '../features/borrowers/views/borrowers_view.dart';
import '../features/borrowers/views/borrower_detail_view.dart';
import '../features/loans/views/loan_detail_view.dart';
import '../features/collections/views/collections_view.dart';
import '../features/reports/views/reports_view.dart';
import '../features/notifications/views/notifications_view.dart';
import '../features/settings/views/settings_view.dart';

// Import Core Layout Shell
import '../core/widgets/main_layout.dart';

// Import Auth Provider
import '../features/auth/providers/auth_provider.dart';

// Helper Stream to force GoRouter refresh on auth status updates
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.dashboard,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggingIn = state.matchedLocation == RouteNames.login;

      // While checking session credentials or logging in, don't perform redirects
      if (authState.status == AuthStatus.checking ||
          authState.status == AuthStatus.authenticating) {
        return null;
      }

      // If user is logged out, restrict to Login screen
      if (authState.status == AuthStatus.unauthenticated) {
        return isLoggingIn ? null : RouteNames.login;
      }

      // If user is logged in, redirect away from Login screen to Dashboard
      if (authState.status == AuthStatus.authenticated) {
        if (isLoggingIn) {
          return RouteNames.dashboard;
        }
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(ref.read(authProvider.notifier).stream),
    routes: [
      // 1. Authentication Route (Outside Shell)
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginView(),
      ),

      // 2. Notification Center (Outside Shell)
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsView(),
      ),

      // 3. Borrower Profile Detail screen (Outside Shell)
      GoRoute(
        path: RouteNames.borrowerDetail,
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '') ?? 0;
          return BorrowerDetailView(borrowerId: id);
        },
      ),

      // 4. Loan Account Detail Ledger screen (Outside Shell)
      GoRoute(
        path: RouteNames.loanDetail,
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '') ?? 0;
          return LoanDetailView(loanId: id);
        },
      ),

      // 5. Main Nested Bottom Tabs Layout Shell
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (context, state) => const DashboardView(),
          ),
          GoRoute(
            path: RouteNames.borrowers,
            builder: (context, state) => const BorrowersView(),
          ),
          GoRoute(
            path: RouteNames.collections,
            builder: (context, state) => const CollectionsView(),
          ),
          GoRoute(
            path: RouteNames.reports,
            builder: (context, state) => const ReportsView(),
          ),
          GoRoute(
            path: RouteNames.settings,
            builder: (context, state) => const SettingsView(),
          ),
        ],
      ),
    ],
  );
});
