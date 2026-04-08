import '../models/notification_item_model.dart';
import 'api_client.dart';

class NotificationService {
  const NotificationService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<NotificationItemModel>> getNotifications() async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/notifications',
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(NotificationItemModel.fromJson)
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.dio.post<void>('/api/notifications/$id/read');
  }
}
