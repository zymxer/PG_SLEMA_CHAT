class CreateChatResponse {
  final String id;
  final String name;
  final bool isGroup;
  final String createdAt;

  CreateChatResponse(this.id, this.name, this.isGroup, this.createdAt);

  factory CreateChatResponse.fromJson(Map<String, dynamic> json) {
    return CreateChatResponse(json['id'], json['name'], json['isGroup'], json['createdAt']);
  }
}