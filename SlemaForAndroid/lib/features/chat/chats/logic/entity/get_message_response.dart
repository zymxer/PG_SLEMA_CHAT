import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';

class GetMessageResponse {

  final String text;
  final String authorUuid;
  final String chatUuid;
  final String messageUuid;
  final String timestamp;

  GetMessageResponse(this.text, this.authorUuid, this.chatUuid,
      this.messageUuid, this.timestamp);

  factory GetMessageResponse.fromJson(Map<String, dynamic> json) {
    return GetMessageResponse(json['text'], json['authorUuid'], json['chatUuid'],
        json['messageUuid'], json['timestamp']);
  }

  Message toMessage() {
    return Message(messageUuid, text, authorUuid, chatUuid);
  }

}
