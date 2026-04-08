import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'auth_service.dart';
import 'chat_service.dart';
import 'notification_service.dart';
import 'secure_storage_service.dart';
import 'signalr_service.dart';
import 'user_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider));
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.read(apiClientProvider));
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ref.read(apiClientProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.read(apiClientProvider));
});

final signalRServiceProvider = Provider<SignalRService>((ref) {
  final service = SignalRService();
  ref.onDispose(service.disconnect);
  return service;
});
