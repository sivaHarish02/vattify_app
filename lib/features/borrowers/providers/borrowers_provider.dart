import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class BorrowerModel {
  final int id;
  final String name;
  final String mobile;
  final String? address;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final int loanCount;

  BorrowerModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.address,
    this.notes,
    required this.status,
    required this.createdAt,
    this.loanCount = 0,
  });

  factory BorrowerModel.fromJson(Map<String, dynamic> json) {
    return BorrowerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      loanCount: json['_count'] != null ? json['_count']['loans'] as int : 0,
    );
  }
}

class BorrowersState {
  final List<BorrowerModel> items;
  final int total;
  final int page;
  final bool isLoading;
  final bool isMoreLoading;
  final String search;
  final String? error;

  BorrowersState({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.isLoading = false,
    this.isMoreLoading = false,
    this.search = '',
    this.error,
  });

  BorrowersState copyWith({
    List<BorrowerModel>? items,
    int? total,
    int? page,
    bool? isLoading,
    bool? isMoreLoading,
    String? search,
    String? error,
  }) {
    return BorrowersState(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      search: search ?? this.search,
      error: error ?? this.error,
    );
  }
}

class BorrowersNotifier extends StateNotifier<BorrowersState> {
  final ApiClient _apiClient = ApiClient();
  static const int _limit = 10;

  BorrowersNotifier() : super(BorrowersState()) {
    fetchBorrowers(refresh: true);
  }

  Future<void> fetchBorrowers({bool refresh = false}) async {
    if (state.isLoading || state.isMoreLoading) return;

    if (refresh) {
      state = state.copyWith(isLoading: true, page: 1, error: null);
    } else {
      // Check if we reached the end
      if (state.items.length >= state.total) return;
      state = state.copyWith(isMoreLoading: true, error: null);
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.borrowers,
        queryParameters: {
          'search': state.search,
          'page': state.page,
          'limit': _limit,
        },
      );

      if (response.statusCode == 200) {
        final List list = response.data['data']['items'];
        final totalCount = response.data['data']['total'] as int;
        final loadedItems = list.map((json) => BorrowerModel.fromJson(json)).toList();

        state = state.copyWith(
          items: refresh ? loadedItems : [...state.items, ...loadedItems],
          total: totalCount,
          page: state.page + 1,
          isLoading: false,
          isMoreLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, isMoreLoading: false, error: e.toString());
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(search: query);
    fetchBorrowers(refresh: true);
  }

  // Create Borrower
  Future<bool> createBorrower(String name, String mobile, String address, String notes) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.borrowers,
        data: {
          'name': name,
          'mobile': mobile,
          'address': address,
          'notes': notes,
        },
      );
      if (response.statusCode == 201) {
        fetchBorrowers(refresh: true);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Update Borrower
  Future<bool> updateBorrower(int id, String name, String mobile, String address, String notes, String status) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.borrowerDetail(id),
        data: {
          'name': name,
          'mobile': mobile,
          'address': address,
          'notes': notes,
          'status': status,
        },
      );
      if (response.statusCode == 200) {
        fetchBorrowers(refresh: true);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Delete Borrower
  Future<String?> deleteBorrower(int id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.borrowerDetail(id));
      if (response.statusCode == 200) {
        fetchBorrowers(refresh: true);
        return null;
      }
    } on DioException catch (e) {
      return e.response?.data['message'] ?? 'Failed to delete borrower';
    } catch (e) {
      return e.toString();
    }
    return 'An unknown error occurred';
  }
}

final borrowersProvider = StateNotifierProvider<BorrowersNotifier, BorrowersState>((ref) {
  return BorrowersNotifier();
});
