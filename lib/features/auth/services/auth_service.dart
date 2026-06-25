import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // Login Service
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final String token = data['token'];
        final Map<String, dynamic> userJson = data['user'];

        // Save token and user details in secure storage
        await SecureStorage.instance.saveToken(token);
        await SecureStorage.instance.saveUser(userJson);

        return UserModel.fromJson(userJson).copyWith(token: token);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    }
  }

  // Auto Login Check
  Future<UserModel?> autoLogin() async {
    final token = await SecureStorage.instance.getToken();
    final cachedUser = await SecureStorage.instance.getUser();

    if (token == null || cachedUser == null) {
      return null;
    }

    try {
      // Validate session against backend /auth/me
      final response = await _apiClient.get(ApiEndpoints.me);
      if (response.statusCode == 200) {
        final userJson = response.data['data']['user'];
        await SecureStorage.instance.saveUser(userJson);
        return UserModel.fromJson(userJson).copyWith(token: token);
      }
    } catch (_) {
      // If validation fails (e.g. server offline), fallback to cached user offline
      return UserModel.fromJson(cachedUser).copyWith(token: token);
    }
    return null;
  }

  // Logout Service
  Future<void> logout() async {
    await SecureStorage.instance.clearAll();
  }
}
