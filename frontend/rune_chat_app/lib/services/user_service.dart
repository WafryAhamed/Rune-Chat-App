import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  const UserService(this._apiClient);

  final ApiClient _apiClient;

  Future<UserModel> getMe() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/users/me',
    );
    return UserModel.fromJson(response.data ?? {});
  }

  Future<List<UserModel>> searchUsers([String? query]) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/users',
      queryParameters: query == null || query.isEmpty ? null : {'query': query},
    );

    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .toList();
  }

  Future<UserModel> updateProfile({
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/users/me',
      data: {'username': username, 'bio': bio, 'avatarUrl': avatarUrl},
    );

    return UserModel.fromJson(response.data ?? {});
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.dio.post<void>(
      '/api/users/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  Future<void> blockUser(String userId) async {
    await _apiClient.dio.post<void>('/api/users/block/$userId');
  }

  Future<void> unblockUser(String userId) async {
    await _apiClient.dio.delete<void>('/api/users/block/$userId');
  }

  Future<List<UserModel>> blockedUsers() async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/users/blocked',
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .toList();
  }
}
