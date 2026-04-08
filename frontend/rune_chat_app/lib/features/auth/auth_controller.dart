import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/auth_response_model.dart';
import '../../models/user_model.dart';
import '../../services/service_providers.dart';
import '../chat/chat_controller.dart';
import 'auth_state.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref);
  },
);

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(AuthState.initial());

  final Ref _ref;

  Future<void> bootstrap() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final storage = _ref.read(secureStorageServiceProvider);
    final apiClient = _ref.read(apiClientProvider);
    final authService = _ref.read(authServiceProvider);
    final userService = _ref.read(userServiceProvider);

    final accessToken = await storage.getAccessToken();
    final refreshToken = await storage.getRefreshToken();

    if (accessToken == null || refreshToken == null) {
      state = const AuthState(isInitialized: true, isLoading: false);
      return;
    }

    try {
      apiClient.setAccessToken(accessToken);
      final user = await userService.getMe();
      state = AuthState(
        isInitialized: true,
        isLoading: false,
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );

      await _ref
          .read(chatControllerProvider.notifier)
          .initializeRealtime(accessToken);
    } catch (_) {
      try {
        final refreshed = await authService.refresh(refreshToken: refreshToken);
        await _persistAuth(refreshed);
        state = AuthState(
          isInitialized: true,
          isLoading: false,
          accessToken: refreshed.accessToken,
          refreshToken: refreshed.refreshToken,
          user: refreshed.user,
        );

        await _ref
            .read(chatControllerProvider.notifier)
            .initializeRealtime(refreshed.accessToken);
      } catch (_) {
        await storage.clearTokens();
        apiClient.setAccessToken(null);
        state = const AuthState(isInitialized: true, isLoading: false);
      }
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _ref
          .read(authServiceProvider)
          .login(email: email, password: password);

      await _persistAuth(response);
      state = AuthState(
        isInitialized: true,
        isLoading: false,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user,
      );

      await _ref
          .read(chatControllerProvider.notifier)
          .initializeRealtime(response.accessToken);
      return true;
    } on DioException catch (error) {
      state = state.copyWith(isLoading: false, error: _extractError(error));
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _ref
          .read(authServiceProvider)
          .register(username: username, email: email, password: password);

      await _persistAuth(response);
      state = AuthState(
        isInitialized: true,
        isLoading: false,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user,
      );

      await _ref
          .read(chatControllerProvider.notifier)
          .initializeRealtime(response.accessToken);
      return true;
    } on DioException catch (error) {
      state = state.copyWith(isLoading: false, error: _extractError(error));
      return false;
    }
  }

  Future<void> forgotPassword(String email) {
    return _ref.read(authServiceProvider).forgotPassword(email);
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) {
    return _ref
        .read(authServiceProvider)
        .resetPassword(token: token, newPassword: newPassword);
  }

  Future<void> logout() async {
    final refreshToken = state.refreshToken;
    if (refreshToken != null) {
      await _ref.read(authServiceProvider).logout(refreshToken);
    }

    await _ref.read(chatControllerProvider.notifier).disconnectRealtime();

    await _ref.read(secureStorageServiceProvider).clearTokens();
    _ref.read(apiClientProvider).setAccessToken(null);

    state = const AuthState(isInitialized: true, isLoading: false);
  }

  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  Future<void> _persistAuth(AuthResponseModel auth) async {
    _ref.read(apiClientProvider).setAccessToken(auth.accessToken);
    await _ref
        .read(secureStorageServiceProvider)
        .saveTokens(
          accessToken: auth.accessToken,
          refreshToken: auth.refreshToken,
        );
  }

  String _extractError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }

    return error.message ?? 'Unexpected error occurred';
  }
}
