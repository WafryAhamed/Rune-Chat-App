import 'package:dio/dio.dart';

import '../models/auth_response_model.dart';
import 'api_client.dart';

class AuthService {
  const AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    return AuthResponseModel.fromJson(response.data ?? {});
  }

  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/auth/register',
      data: {'username': username, 'email': email, 'password': password},
    );

    return AuthResponseModel.fromJson(response.data ?? {});
  }

  Future<AuthResponseModel> refresh({required String refreshToken}) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    return AuthResponseModel.fromJson(response.data ?? {});
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.dio.post<void>(
      '/api/auth/forgot-password',
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _apiClient.dio.post<void>(
      '/api/auth/reset-password',
      data: {'token': token, 'newPassword': newPassword},
    );
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _apiClient.dio.post<void>(
        '/api/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException {
      // Ignore network failures during logout to avoid blocking local session cleanup.
    }
  }
}
