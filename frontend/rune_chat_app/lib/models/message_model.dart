enum ChatMessageType { text, image, file, voice, system, ai }

ChatMessageType messageTypeFromInt(int? value) {
  return switch (value ?? 0) {
    1 => ChatMessageType.image,
    2 => ChatMessageType.file,
    3 => ChatMessageType.voice,
    4 => ChatMessageType.system,
    5 => ChatMessageType.ai,
    _ => ChatMessageType.text,
  };
}

int messageTypeToInt(ChatMessageType type) {
  return switch (type) {
    ChatMessageType.text => 0,
    ChatMessageType.image => 1,
    ChatMessageType.file => 2,
    ChatMessageType.voice => 3,
    ChatMessageType.system => 4,
    ChatMessageType.ai => 5,
  };
}

class MessageModel {
  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.sentAt,
    required this.isSeen,
    this.seenAt,
    required this.isMine,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final ChatMessageType type;
  final DateTime sentAt;
  final bool isSeen;
  final DateTime? seenAt;
  final bool isMine;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'].toString(),
      conversationId: json['conversationId'].toString(),
      senderId: json['senderId'].toString(),
      senderName: json['senderName'] as String? ?? 'Unknown',
      content: json['content'] as String? ?? '',
      type: messageTypeFromInt((json['type'] as num?)?.toInt()),
      sentAt:
          DateTime.tryParse(json['sentAt']?.toString() ?? '') ?? DateTime.now(),
      isSeen: json['isSeen'] as bool? ?? false,
      seenAt: json['seenAt'] != null
          ? DateTime.tryParse(json['seenAt'].toString())
          : null,
      isMine: json['isMine'] as bool? ?? false,
    );
  }

  MessageModel copyWith({bool? isSeen, DateTime? seenAt}) {
    return MessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      sentAt: sentAt,
      isSeen: isSeen ?? this.isSeen,
      seenAt: seenAt ?? this.seenAt,
      isMine: isMine,
    );
  }
}
