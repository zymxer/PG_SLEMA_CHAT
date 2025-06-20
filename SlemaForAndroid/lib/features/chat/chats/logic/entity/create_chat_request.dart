class CreateChatRequest {
  final String name;
  final bool isGroup;
  final String? interlocutorUsername;
  final List<String>? memberIds;

  CreateChatRequest(
      this.name,
      this.isGroup,
      this.interlocutorUsername,
      {this.memberIds}
      );

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isGroup': isGroup,
      if (interlocutorUsername != null) 'interlocutorUsername': interlocutorUsername,
      if (memberIds != null && memberIds!.isNotEmpty) 'memberIds': memberIds,
    };
  }
}