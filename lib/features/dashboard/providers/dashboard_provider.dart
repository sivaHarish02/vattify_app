import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class DashboardKpis {
  final double totalPrincipalGiven;
  final double totalActiveBalance;
  final double monthlyExpectedInterest;
  final double monthlyCollectedInterest;
  final double monthlyPendingInterest;
  final double totalPendingInterest;
  final int activeBorrowers;

  DashboardKpis({
    required this.totalPrincipalGiven,
    required this.totalActiveBalance,
    required this.monthlyExpectedInterest,
    required this.monthlyCollectedInterest,
    required this.monthlyPendingInterest,
    required this.totalPendingInterest,
    required this.activeBorrowers,
  });

  factory DashboardKpis.fromJson(Map<String, dynamic> json) {
    return DashboardKpis(
      totalPrincipalGiven: (json['totalPrincipalGiven'] as num).toDouble(),
      totalActiveBalance: (json['totalActiveBalance'] as num).toDouble(),
      monthlyExpectedInterest: (json['monthlyExpectedInterest'] as num).toDouble(),
      monthlyCollectedInterest: (json['monthlyCollectedInterest'] as num).toDouble(),
      monthlyPendingInterest: (json['monthlyPendingInterest'] as num).toDouble(),
      totalPendingInterest: (json['totalPendingInterest'] as num).toDouble(),
      activeBorrowers: json['activeBorrowers'] as int,
    );
  }
}

class DashboardRecentCollection {
  final int id;
  final String borrowerName;
  final double amount;
  final DateTime date;
  final int month;
  final int year;

  DashboardRecentCollection({
    required this.id,
    required this.borrowerName,
    required this.amount,
    required this.date,
    required this.month,
    required this.year,
  });

  factory DashboardRecentCollection.fromJson(Map<String, dynamic> json) {
    return DashboardRecentCollection(
      id: json['id'] as int,
      borrowerName: json['borrowerName'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      month: json['month'] as int,
      year: json['year'] as int,
    );
  }
}

class DashboardRecentReturn {
  final int id;
  final String borrowerName;
  final double amount;
  final DateTime date;
  final String remarks;

  DashboardRecentReturn({
    required this.id,
    required this.borrowerName,
    required this.amount,
    required this.date,
    required this.remarks,
  });

  factory DashboardRecentReturn.fromJson(Map<String, dynamic> json) {
    return DashboardRecentReturn(
      id: json['id'] as int,
      borrowerName: json['borrowerName'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      remarks: json['remarks'] ?? '',
    );
  }
}

class DashboardState {
  final DashboardKpis? kpis;
  final List<DashboardRecentCollection> recentCollections;
  final List<DashboardRecentReturn> recentPrincipalReturns;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.kpis,
    this.recentCollections = const [],
    this.recentPrincipalReturns = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    DashboardKpis? kpis,
    List<DashboardRecentCollection>? recentCollections,
    List<DashboardRecentReturn>? recentPrincipalReturns,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      kpis: kpis ?? this.kpis,
      recentCollections: recentCollections ?? this.recentCollections,
      recentPrincipalReturns: recentPrincipalReturns ?? this.recentPrincipalReturns,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ApiClient _apiClient = ApiClient();

  DashboardNotifier() : super(DashboardState()) {
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(ApiEndpoints.dashboard);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final kpis = DashboardKpis.fromJson(data['kpis']);
        
        final List collectionsList = data['recentCollections'] ?? [];
        final collections = collectionsList
            .map((json) => DashboardRecentCollection.fromJson(json))
            .toList();

        final List returnsList = data['recentPrincipalReturns'] ?? [];
        final returns = returnsList
            .map((json) => DashboardRecentReturn.fromJson(json))
            .toList();

        state = DashboardState(
          kpis: kpis,
          recentCollections: collections,
          recentPrincipalReturns: returns,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
