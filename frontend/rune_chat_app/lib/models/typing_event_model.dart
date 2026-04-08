class TypingEventModel {
  const TypingEventModel({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
  });

  final String conversationId;
  final String userId;
  final bool isTyping;

  factory TypingEventModel.fromJson(Map<String, dynamic> json) {
    return TypingEventModel(
      conversationId: json['conversationId'].toString(),
      userId: json['userId'].toString(),
      isTyping: json['isTyping'] as bool? ?? false,
    );
  }
}
