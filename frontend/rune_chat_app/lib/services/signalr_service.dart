import 'dart:developer';

import 'package:signalr_netcore/signalr_client.dart';

import '../core/constants/app_constants.dart';
import '../models/message_model.dart';
import '../models/message_seen_event_model.dart';
import '../models/typing_event_model.dart';

class SignalRService {
  HubConnection? _connection;

  void Function(MessageModel message)? onReceiveMessage;
  void Function(TypingEventModel event)? onTyping;
  void Function(MessageSeenEventModel event)? onMessageSeen;
  void Function(String userId, bool isOnline)? onPresenceChanged;

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  Future<void> connect(String accessToken) async {
    if (isConnected) {
      return;
    }

    _connection = HubConnectionBuilder()
        .withUrl(
          AppConstants.signalRHubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => accessToken,
            transport: HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('ReceiveMessage', (arguments) {
      final raw = _firstMap(arguments);
      if (raw != null) {
        onReceiveMessage?.call(MessageModel.fromJson(raw));
      }
    });

    _connection!.on('Typing', (arguments) {
      final raw = _firstMap(arguments);
      if (raw != null) {
        onTyping?.call(TypingEventModel.fromJson(raw));
      }
    });

    _connection!.on('MessageSeen', (arguments) {
      final raw = _firstMap(arguments);
      if (raw != null) {
        onMessageSeen?.call(MessageSeenEventModel.fromJson(raw));
      }
    });

    _connection!.on('PresenceChanged', (arguments) {
      if (arguments == null || arguments.length < 2) {
        return;
      }

      final userId = arguments[0].toString();
      final isOnline = arguments[1] == true;
      onPresenceChanged?.call(userId, isOnline);
    });

    _connection!.onclose(({error}) {
      log('SignalR closed: ${error?.toString() ?? 'unknown'}');
    });

    await _connection!.start();
  }

  Future<void> disconnect() async {
    if (_connection == null) {
      return;
    }

    await _connection!.stop();
    _connection = null;
  }

  Future<void> joinConversation(String conversationId) async {
    if (!isConnected) {
      return;
    }

    await _connection!.invoke('JoinConversation', args: [conversationId]);
  }

  Future<void> leaveConversation(String conversationId) async {
    if (!isConnected) {
      return;
    }

    await _connection!.invoke('LeaveConversation', args: [conversationId]);
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    required ChatMessageType type,
  }) async {
    if (!isConnected) {
      return;
    }

    await _connection!.invoke(
      'SendMessage',
      args: [
        {
          'conversationId': conversationId,
          'content': content,
          'type': messageTypeToInt(type),
        },
      ],
    );
  }

  Future<void> sendTyping({
    required String conversationId,
    required bool isTyping,
  }) async {
    if (!isConnected) {
      return;
    }

    await _connection!.invoke('Typing', args: [conversationId, isTyping]);
  }

  Future<void> markSeen(String messageId) async {
    if (!isConnected) {
      return;
    }

    await _connection!.invoke('MarkSeen', args: [messageId]);
  }

  Map<String, dynamic>? _firstMap(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) {
      return null;
    }

    final first = arguments.first;
    if (first is Map<String, dynamic>) {
      return first;
    }

    if (first is Map) {
      return first.map((key, value) => MapEntry(key.toString(), value));
    }

    return null;
  }
}
