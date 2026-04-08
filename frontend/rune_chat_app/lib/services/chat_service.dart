import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'api_client.dart';

class ChatInfoModel {
  const ChatInfoModel({
    required this.conversationId,
    required this.isGroup,
    required this.title,
    required this.members,
    required this.totalMessages,
  });

  final String conversationId;
  final bool isGroup;
  final String title;
  final List<String> members;
  final int totalMessages;

  factory ChatInfoModel.fromJson(Map<String, dynamic> json) {
    return ChatInfoModel(
      conversationId: json['conversationId'].toString(),
      isGroup: json['isGroup'] as bool? ?? false,
      title: json['title'] as String? ?? 'Chat',
      members: (json['members'] as List<dynamic>? ?? const [])
          .map((m) => m.toString())
          .toList(),
      totalMessages: (json['totalMessages'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChatService {
  const ChatService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ConversationModel>> getConversations() async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/conversations',
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ConversationModel.fromJson)
        .toList();
  }

  Future<ConversationModel> createConversation(String targetUserId) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/conversations',
      data: {'targetUserId': targetUserId},
    );

    return ConversationModel.fromJson(response.data ?? {});
  }

  Future<List<MessageModel>> getMessages(
    String conversationId, {
    int page = 1,
    int pageSize = 40,
  }) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/conversations/$conversationId/messages',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );

    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MessageModel.fromJson)
        .toList();
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    required ChatMessageType type,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/conversations/send',
      data: {
        'conversationId': conversationId,
        'content': content,
        'type': messageTypeToInt(type),
      },
    );

    return MessageModel.fromJson(response.data ?? {});
  }

  Future<void> markSeen(String messageId) async {
    await _apiClient.dio.post<void>('/api/conversations/seen/$messageId');
  }

  Future<ChatInfoModel> getChatInfo(String conversationId) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/conversations/$conversationId/info',
    );

    return ChatInfoModel.fromJson(response.data ?? {});
  }

  Future<List<ConversationModel>> searchConversations(String query) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/conversations/search',
      queryParameters: {'query': query},
    );

    final data = response.data ?? {};
    final conversations = (data['conversations'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ConversationModel.fromJson)
        .toList();

    return conversations;
  }
}
