import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/conversation_model.dart';
import '../../models/message_model.dart';
import '../../models/message_seen_event_model.dart';
import '../../models/typing_event_model.dart';
import '../../services/chat_service.dart';
import '../../services/service_providers.dart';
import '../../services/signalr_service.dart';
import 'chat_state.dart';

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>(
  (ref) {
    return ChatController(ref);
  },
);

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._ref) : super(ChatState.initial()) {
    _signalR = _ref.read(signalRServiceProvider);
    _chatService = _ref.read(chatServiceProvider);
  }

  final Ref _ref;
  late final SignalRService _signalR;
  late final ChatService _chatService;
  bool _realtimeInitialized = false;

  Future<void> initializeRealtime(String accessToken) async {
    if (_realtimeInitialized) {
      return;
    }

    _signalR.onReceiveMessage = _onReceiveMessage;
    _signalR.onTyping = _onTyping;
    _signalR.onMessageSeen = _onMessageSeen;
    _signalR.onPresenceChanged = (_, isOnline) {
      unawaited(loadConversations());
    };

    await _signalR.connect(accessToken);
    _realtimeInitialized = true;

    await loadConversations();
  }

  Future<void> disconnectRealtime() async {
    await _signalR.disconnect();
    _realtimeInitialized = false;
    state = ChatState.initial();
  }

  Future<void> loadConversations() async {
    state = state.copyWith(isLoadingConversations: true, clearError: true);

    try {
      final conversations = await _chatService.getConversations();
      state = state.copyWith(
        isLoadingConversations: false,
        conversations: conversations,
      );
    } on DioException catch (error) {
      state = state.copyWith(
        isLoadingConversations: false,
        error: _extractError(error),
      );
    }
  }

  Future<ConversationModel?> startConversation(String targetUserId) async {
    try {
      final conversation = await _chatService.createConversation(targetUserId);

      final updated = [conversation, ...state.conversations]
          .fold<List<ConversationModel>>([], (list, item) {
            if (list.any((c) => c.id == item.id)) {
              return list;
            }
            list.add(item);
            return list;
          });

      state = state.copyWith(conversations: updated);
      await openConversation(conversation.id);
      return conversation;
    } on DioException catch (error) {
      state = state.copyWith(error: _extractError(error));
      return null;
    }
  }

  Future<void> openConversation(String conversationId) async {
    state = state.copyWith(activeConversationId: conversationId);
    await _signalR.joinConversation(conversationId);

    if (!state.messagesByConversation.containsKey(conversationId)) {
      await loadMessages(conversationId);
    }
  }

  Future<void> leaveConversation(String conversationId) async {
    await _signalR.leaveConversation(conversationId);
    if (state.activeConversationId == conversationId) {
      state = state.copyWith(activeConversationId: '');
    }
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      final messages = await _chatService.getMessages(conversationId);
      final map = Map<String, List<MessageModel>>.from(
        state.messagesByConversation,
      )..[conversationId] = messages;

      state = state.copyWith(messagesByConversation: map);
    } on DioException catch (error) {
      state = state.copyWith(error: _extractError(error));
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    ChatMessageType type = ChatMessageType.text,
  }) async {
    if (content.trim().isEmpty) {
      return;
    }

    if (_signalR.isConnected) {
      await _signalR.sendMessage(
        conversationId: conversationId,
        content: content.trim(),
        type: type,
      );
      return;
    }

    final message = await _chatService.sendMessage(
      conversationId: conversationId,
      content: content.trim(),
      type: type,
    );

    _onReceiveMessage(message);
  }

  Future<void> sendTyping({
    required String conversationId,
    required bool isTyping,
  }) async {
    await _signalR.sendTyping(
      conversationId: conversationId,
      isTyping: isTyping,
    );
  }

  Future<void> markSeen(String messageId) async {
    if (_signalR.isConnected) {
      await _signalR.markSeen(messageId);
      return;
    }

    await _chatService.markSeen(messageId);
  }

  List<MessageModel> messagesForConversation(String conversationId) {
    return state.messagesByConversation[conversationId] ?? const [];
  }

  bool isTypingInConversation(String conversationId) {
    return state.typingConversations.contains(conversationId);
  }

  void _onReceiveMessage(MessageModel message) {
    final existing = List<MessageModel>.from(
      state.messagesByConversation[message.conversationId] ?? const [],
    );

    final alreadyExists = existing.any((item) => item.id == message.id);
    if (!alreadyExists) {
      existing.add(message);
    }

    final updatedMessages =
        Map<String, List<MessageModel>>.from(state.messagesByConversation)
          ..[message.conversationId] = (existing
            ..sort((a, b) => a.sentAt.compareTo(b.sentAt)));

    final conversationIndex = state.conversations.indexWhere(
      (c) => c.id == message.conversationId,
    );

    final conversations = [...state.conversations];
    if (conversationIndex >= 0) {
      final current = conversations[conversationIndex];
      conversations[conversationIndex] = current.copyWith(
        lastMessage: message.content,
        lastMessageAt: message.sentAt,
      );
      conversations.sort(
        (a, b) => (b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(
              a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0),
            ),
      );
    }

    state = state.copyWith(
      messagesByConversation: updatedMessages,
      conversations: conversations,
    );
  }

  void _onTyping(TypingEventModel event) {
    final typing = Set<String>.from(state.typingConversations);
    if (event.isTyping) {
      typing.add(event.conversationId);
    } else {
      typing.remove(event.conversationId);
    }

    state = state.copyWith(typingConversations: typing);
  }

  void _onMessageSeen(MessageSeenEventModel event) {
    final messages = List<MessageModel>.from(
      state.messagesByConversation[event.conversationId] ?? const [],
    );

    final updated = messages
        .map(
          (message) => message.id == event.messageId
              ? message.copyWith(isSeen: true, seenAt: event.seenAt)
              : message,
        )
        .toList();

    final map = Map<String, List<MessageModel>>.from(
      state.messagesByConversation,
    )..[event.conversationId] = updated;

    state = state.copyWith(messagesByConversation: map);
  }

  String _extractError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }

    return error.message ?? 'Unexpected chat error';
  }
}
