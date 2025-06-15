
// Todo don't send user data in backend???
class MemberUser {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final bool isAdmin;

  MemberUser({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.isAdmin,
  });

  factory MemberUser.fromJson(Map<String, dynamic> json) {
    return MemberUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      isAdmin: json['isAdmin'],
    );
  }
}

class MemberChat {
  final String id;
  final String name;
  final bool isGroup;
  final DateTime createdAt;

  MemberChat({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.createdAt,
  });

  factory MemberChat.fromJson(Map<String, dynamic> json) {
    return MemberChat(
      id: json['id'],
      name: json['name'],
      isGroup: json['isGroup'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ChatMember {
  final MemberChat chat;
  final MemberUser user;
  final String role;
  final DateTime joinedAt;

  ChatMember({
    required this.chat,
    required this.user,
    required this.role,
    required this.joinedAt,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      chat: MemberChat.fromJson(json['chat']),
      user: MemberUser.fromJson(json['user']),
      role: json['role'],
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }
}