import '../../models/conversation_model.dart';
import '../../models/message_model.dart';

class ChatState {
  const ChatState({
    required this.isLoadingConversations,
    required this.conversations,
    required this.messagesByConversation,
    required this.typingConversations,
    this.activeConversationId,
    this.error,
  });

  factory ChatState.initial() {
    return const ChatState(
      isLoadingConversations: false,
      conversations: [],
      messagesByConversation: {},
      typingConversations: {},
    );
  }

  final bool isLoadingConversations;
  final List<ConversationModel> conversations;
  final Map<String, List<MessageModel>> messagesByConversation;
  final Set<String> typingConversations;
  final String? activeConversationId;
  final String? error;

  ChatState copyWith({
    bool? isLoadingConversations,
    List<ConversationModel>? conversations,
    Map<String, List<MessageModel>>? messagesByConversation,
    Set<String>? typingConversations,
    String? activeConversationId,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      isLoadingConversations:
          isLoadingConversations ?? this.isLoadingConversations,
      conversations: conversations ?? this.conversations,
      messagesByConversation:
          messagesByConversation ?? this.messagesByConversation,
      typingConversations: typingConversations ?? this.typingConversations,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
