import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../core/network/api_client.dart';

enum AuthStatus { authenticated, unauthenticated, checking, authenticating }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.checking);
  factory AuthState.authenticating() => AuthState(status: AuthStatus.authenticating);
  factory AuthState.unauthenticated({String? error}) => AuthState(status: AuthStatus.unauthenticated, errorMessage: error);
  factory AuthState.authenticated(UserModel user) => AuthState(status: AuthStatus.authenticated, user: user);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState.initial()) {
    // Register auto-logout hook in ApiClient
    ApiClient().onUnauthorized = logout;
    checkAuthStatus();
  }

  // Auto Login check
  Future<void> checkAuthStatus() async {
    state = AuthState.initial();
    try {
      final user = await _authService.autoLogin();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated(error: e.toString());
    }
  }

  // Login handler
  Future<bool> login(String username, String password) async {
    state = AuthState.authenticating();
    try {
      final user = await _authService.login(username, password);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.unauthenticated(error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // Logout handler
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.unauthenticated();
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
