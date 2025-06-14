class ChatMember {
  final String username;
  final String role;

  const ChatMember(this.username, this.role);

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(json['username'], json['role']);
  }
}