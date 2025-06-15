class AddMemberRequest {
  final String username;
  final String role;

  AddMemberRequest(this.username, this.role);

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role': role,
    };
  }
}