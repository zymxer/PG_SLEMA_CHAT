class ChatMember {
  final String chat;
  final String user;
  final String role;
  final String joinedAt;

  const ChatMember(this.chat, this.user, this.role, this.joinedAt);

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(json['chat'], json['user'], json['role'], json['joinedAt']);
  }
}