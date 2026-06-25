import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class CollectionItemModel {
  final int id;
  final int loanId;
  final int month;
  final int year;
  final double expectedAmount;
  final double receivedAmount;
  final String status; // PENDING, PARTIAL, PAID
  final String borrowerName;
  final String borrowerMobile;
  final double interestRate;
  final String interestType;

  CollectionItemModel({
    required this.id,
    required this.loanId,
    required this.month,
    required this.year,
    required this.expectedAmount,
    required this.receivedAmount,
    required this.status,
    required this.borrowerName,
    required this.borrowerMobile,
    required this.interestRate,
    required this.interestType,
  });

  factory CollectionItemModel.fromJson(Map<String, dynamic> json) {
    return CollectionItemModel(
      id: json['id'] as int,
      loanId: json['loanId'] as int,
      month: json['month'] as int,
      year: json['year'] as int,
      expectedAmount: (json['expectedAmount'] as num).toDouble(),
      receivedAmount: (json['receivedAmount'] as num).toDouble(),
      status: json['status'] as String,
      borrowerName: json['loan']['borrower']['name'] as String,
      borrowerMobile: json['loan']['borrower']['mobile'] as String,
      interestRate: (json['loan']['interestRate'] as num).toDouble(),
      interestType: json['loan']['interestType'] as String,
    );
  }
}

class CollectionsState {
  final List<CollectionItemModel> items;
  final bool isLoading;
  final String? error;
  final int month;
  final int year;
  final String? statusFilter; // PENDING, PARTIAL, PAID, null for ALL

  CollectionsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    required this.month,
    required this.year,
    this.statusFilter,
  });

  CollectionsState copyWith({
    List<CollectionItemModel>? items,
    bool? isLoading,
    String? error,
    int? month,
    int? year,
    String? statusFilter,
  }) {
    return CollectionsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      month: month ?? this.month,
      year: year ?? this.year,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class CollectionsNotifier extends StateNotifier<CollectionsState> {
  final ApiClient _apiClient = ApiClient();

  CollectionsNotifier()
      : super(
          CollectionsState(
            month: DateTime.now().month,
            year: DateTime.now().year,
          ),
        ) {
    fetchCollections();
  }

  // Fetch Collections
  Future<void> fetchCollections() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Map<String, dynamic> queryParams = {
        'month': state.month,
        'year': state.year,
        'limit': 100, // Load up to 100 collections per month
      };
      
      if (state.statusFilter != null) {
        queryParams['status'] = state.statusFilter!;
      }

      final response = await _apiClient.get(
        ApiEndpoints.collections,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List list = response.data['data']['items'] ?? [];
        final items = list.map((j) => CollectionItemModel.fromJson(j)).toList();
        state = state.copyWith(items: items, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Set month/year filter
  void updatePeriod(int month, int year) {
    state = state.copyWith(month: month, year: year);
    fetchCollections();
  }

  // Set status filter
  void updateStatusFilter(String? status) {
    state = state.copyWith(statusFilter: status);
    fetchCollections();
  }

  // Generate Collections Run
  Future<Map<String, dynamic>?> generateCollectionsRun(int month, int year) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.generateCollections,
        data: {'month': month, 'year': year},
      );
      if (response.statusCode == 200) {
        fetchCollections();
        return response.data['data'];
      }
    } catch (_) {}
    return null;
  }

  // Record payment
  Future<bool> recordPayment({
    required int collectionId,
    required double amount,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.payCollection(collectionId),
        data: {
          'receivedAmount': amount,
          'remarks': remarks,
        },
      );
      if (response.statusCode == 200) {
        fetchCollections();
        return true;
      }
    } catch (_) {}
    return false;
  }
}

final collectionsProvider = StateNotifierProvider<CollectionsNotifier, CollectionsState>((ref) {
  return CollectionsNotifier();
});
