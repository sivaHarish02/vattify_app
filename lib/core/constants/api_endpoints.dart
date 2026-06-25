import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  // If running on Android emulator, use 10.0.2.2. If iOS or desktop/web, use localhost.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://192.168.1.7:3000/api';
      }
    } catch (_) {
      // Fallback
    }
    return 'http://192.168.1.7:3000/api';
  }

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  // Dashboard endpoints
  static const String dashboard = '/dashboard';

  // Borrowers endpoints
  static const String borrowers = '/borrowers';
  static String borrowerDetail(int id) => '/borrowers/$id';

  // Loans endpoints
  static const String loans = '/loans';
  static String loanDetail(int id) => '/loans/$id';

  // Transactions endpoints
  static const String transactions = '/transactions';

  // Collections endpoints
  static const String collections = '/collections';
  static const String generateCollections = '/collections/generate';
  static String payCollection(int id) => '/collections/$id/pay';

  // Reports endpoints
  static const String monthlyReport = '/reports/monthly';
  static String borrowerReport(int id) => '/reports/borrower/$id';
  static const String exportPdf = '/reports/export/pdf';
  static const String exportExcel = '/reports/export/excel';

  // Notifications endpoints
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';
  static const String triggerNotificationChecks =
      '/notifications/trigger-checks';
  static const String readAllNotifications = '/notifications/read-all';
  static String readNotification(int id) => '/notifications/$id/read';
}
