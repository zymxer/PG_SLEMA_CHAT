import 'package:chat_app/features/chat/logic/entity/chat.dart';

class PostMessageRequest {
  final Chat chat;
  final String text;

  PostMessageRequest(this.chat, this.text);

  Map<String, String> toJson() {
    return {
      'text': text,
    };
  }
}