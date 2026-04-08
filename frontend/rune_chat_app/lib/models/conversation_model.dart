class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.isGroup,
    required this.isOnline,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isGroup;
  final bool isOnline;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'].toString(),
      displayName: json['displayName'] as String? ?? 'Chat',
      avatarUrl: json['avatarUrl'] as String?,
      isGroup: json['isGroup'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'].toString())
          : null,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  ConversationModel copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ConversationModel(
      id: id,
      displayName: displayName,
      avatarUrl: avatarUrl,
      isGroup: isGroup,
      isOnline: isOnline ?? this.isOnline,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
