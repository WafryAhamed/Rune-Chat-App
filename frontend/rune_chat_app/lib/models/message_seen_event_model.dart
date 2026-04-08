class MessageSeenEventModel {
  const MessageSeenEventModel({
    required this.messageId,
    required this.conversationId,
    required this.seenByUserId,
    required this.seenAt,
  });

  final String messageId;
  final String conversationId;
  final String seenByUserId;
  final DateTime seenAt;

  factory MessageSeenEventModel.fromJson(Map<String, dynamic> json) {
    return MessageSeenEventModel(
      messageId: json['messageId'].toString(),
      conversationId: json['conversationId'].toString(),
      seenByUserId: json['seenByUserId'].toString(),
      seenAt:
          DateTime.tryParse(json['seenAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
