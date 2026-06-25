import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class LoanModel {
  final int id;
  final int borrowerId;
  final double loanAmount;
  final double currentBalance;
  final double interestRate;
  final String interestType; // FIXED or REDUCING
  final DateTime loanDate;
  final String status; // ACTIVE or SETTLED
  final String? borrowerName;

  LoanModel({
    required this.id,
    required this.borrowerId,
    required this.loanAmount,
    required this.currentBalance,
    required this.interestRate,
    required this.interestType,
    required this.loanDate,
    required this.status,
    this.borrowerName,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as int,
      borrowerId: json['borrowerId'] as int,
      loanAmount: double.tryParse(json['loanAmount'].toString()) ?? 0.0,
      currentBalance: double.tryParse(json['currentBalance'].toString()) ?? 0.0,
      interestRate: double.tryParse(json['interestRate'].toString()) ?? 0.0,
      interestType: json['interestType'] as String,
      loanDate: DateTime.parse(json['loanDate'] as String),
      status: json['status'] as String,
      borrowerName: json['borrower'] != null ? json['borrower']['name'] as String? : null,
    );
  }
}

class TransactionModel {
  final int id;
  final int loanId;
  final double amount;
  final String type; // GIVEN or RETURNED
  final DateTime date;
  final String? remarks;

  TransactionModel({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.type,
    required this.date,
    this.remarks,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      loanId: json['loanId'] as int,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      remarks: json['remarks'] as String?,
    );
  }
}

class LoansState {
  final List<LoanModel> items;
  final bool isLoading;
  final String? error;

  LoansState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });
}

class LoansNotifier extends StateNotifier<LoansState> {
  final ApiClient _apiClient = ApiClient();

  LoansNotifier() : super(LoansState());

  // Create new Loan
  Future<bool> createLoan({
    required int borrowerId,
    required double loanAmount,
    required double interestRate,
    required String interestType,
    required String loanDate,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.loans,
        data: {
          'borrowerId': borrowerId,
          'loanAmount': loanAmount,
          'interestRate': interestRate,
          'interestType': interestType,
          'loanDate': loanDate,
          'remarks': remarks,
        },
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // Create Transaction (GIVEN/RETURNED)
  Future<bool> createTransaction({
    required int loanId,
    required double amount,
    required String type,
    required String date,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.transactions,
        data: {
          'loanId': loanId,
          'amount': amount,
          'type': type,
          'date': date,
          'remarks': remarks,
        },
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}

// Global Providers
final loansProvider = StateNotifierProvider<LoansNotifier, LoansState>((ref) {
  return LoansNotifier();
});

final loanDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, loanId) async {
  final response = await ApiClient().get(ApiEndpoints.loanDetail(loanId));
  return response.data['data'] as Map<String, dynamic>;
});

final borrowerDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, borrowerId) async {
  final response = await ApiClient().get(ApiEndpoints.borrowerDetail(borrowerId));
  return response.data['data'] as Map<String, dynamic>;
});
