class CreateChatRequest {
  final String name;
  final int isGroup;
  final String interlocutorUsername;
  CreateChatRequest(this.name, this.isGroup, this.interlocutorUsername);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isGroup': isGroup,
      'interlocutorUsername': interlocutorUsername
    };
  }

}