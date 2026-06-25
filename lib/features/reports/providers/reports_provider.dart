import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class MonthlySummaryModel {
  final double expectedInterest;
  final double collectedInterest;
  final double pendingInterest;
  final double principalReturned;

  MonthlySummaryModel({
    required this.expectedInterest,
    required this.collectedInterest,
    required this.pendingInterest,
    required this.principalReturned,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      expectedInterest: (json['expectedInterest'] as num).toDouble(),
      collectedInterest: (json['collectedInterest'] as num).toDouble(),
      pendingInterest: (json['pendingInterest'] as num).toDouble(),
      principalReturned: (json['principalReturned'] as num).toDouble(),
    );
  }
}

class ReportsState {
  final MonthlySummaryModel? summary;
  final bool isLoading;
  final bool isDownloading;
  final String? error;
  final int month;
  final int year;

  ReportsState({
    this.summary,
    this.isLoading = false,
    this.isDownloading = false,
    this.error,
    required this.month,
    required this.year,
  });

  ReportsState copyWith({
    MonthlySummaryModel? summary,
    bool? isLoading,
    bool? isDownloading,
    String? error,
    int? month,
    int? year,
  }) {
    return ReportsState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isDownloading: isDownloading ?? this.isDownloading,
      error: error ?? this.error,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  final ApiClient _apiClient = ApiClient();

  ReportsNotifier()
      : super(
          ReportsState(
            month: DateTime.now().month,
            year: DateTime.now().year,
          ),
        ) {
    fetchMonthlySummary();
  }

  // Fetch JSON Stats
  Future<void> fetchMonthlySummary() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(
        ApiEndpoints.monthlyReport,
        queryParameters: {
          'month': state.month,
          'year': state.year,
        },
      );
      if (response.statusCode == 200) {
        final summary = MonthlySummaryModel.fromJson(response.data['data']['summary']);
        state = state.copyWith(summary: summary, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updatePeriod(int month, int year) {
    state = state.copyWith(month: month, year: year);
    fetchMonthlySummary();
  }

  // Download PDF Report
  Future<String?> downloadPdfReport() async {
    state = state.copyWith(isDownloading: true);
    try {
      final dio = Dio();
      final token = await _apiClient.dio.options.headers['Authorization']; // extract bearer token
      
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Vattify_Report_${state.month}_${state.year}.pdf';
      
      await dio.download(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.exportPdf}',
        filePath,
        queryParameters: {
          'month': state.month,
          'year': state.year,
        },
        options: Options(
          headers: {
            if (token != null) 'Authorization': token,
          },
          responseType: ResponseType.bytes,
        ),
      );

      state = state.copyWith(isDownloading: false);
      return filePath;
    } catch (e) {
      state = state.copyWith(isDownloading: false);
      return null;
    }
  }

  // Download Excel Report
  Future<String?> downloadExcelReport() async {
    state = state.copyWith(isDownloading: true);
    try {
      final dio = Dio();
      final token = await _apiClient.dio.options.headers['Authorization'];
      
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Vattify_Report_${state.month}_${state.year}.xlsx';
      
      await dio.download(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.exportExcel}',
        filePath,
        queryParameters: {
          'month': state.month,
          'year': state.year,
        },
        options: Options(
          headers: {
            if (token != null) 'Authorization': token,
          },
          responseType: ResponseType.bytes,
        ),
      );

      state = state.copyWith(isDownloading: false);
      return filePath;
    } catch (e) {
      state = state.copyWith(isDownloading: false);
      return null;
    }
  }
}

final reportsProvider = StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier();
});
