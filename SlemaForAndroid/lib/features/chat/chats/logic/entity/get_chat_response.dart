import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';

class GetChatResponse {
  final String id;
  final String name;
  final bool isGroup;
  final String createdAt;

  GetChatResponse(this.id, this.name, this.isGroup, this.createdAt);

  factory GetChatResponse.fromJson(Map<String, dynamic> json) {
    return GetChatResponse(json['id'], json['name'], json['isGroup'], json['createdAt']);
  }

  Chat toChat() {
    return Chat(id, name, isGroup);
  }

}
