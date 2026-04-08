class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.bio,
    this.avatarUrl,
    this.isOnline = false,
  });

  final String id;
  final String username;
  final String email;
  final String? bio;
  final String? avatarUrl;
  final bool isOnline;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'bio': bio,
    'avatarUrl': avatarUrl,
    'isOnline': isOnline,
  };

  UserModel copyWith({
    String? username,
    String? email,
    String? bio,
    String? avatarUrl,
    bool? isOnline,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
