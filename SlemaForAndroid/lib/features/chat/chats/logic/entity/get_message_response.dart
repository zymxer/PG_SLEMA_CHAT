import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';

class GetMessageResponse {

  final String text;
  final String authorUuid;
  final String chatUuid;
  final String messageUuid;
  final String timestamp;
  final String fileName;
  final String fileType;
  final String fileUrl;

  GetMessageResponse(this.text, this.authorUuid, this.chatUuid,
      this.messageUuid, this.timestamp, this.fileName, this.fileType, this.fileUrl);

  factory GetMessageResponse.fromJson(Map<String, dynamic> json) {
    return GetMessageResponse(json['text'], json['authorUuid'], json['chatUuid'],
        json['messageUuid'], json['timestamp'], json['fileName'],json['fileType'],json['fileUrl'],);
  }
  // TODO GET FILE
  Message toMessage() {
    return Message(messageUuid, text, authorUuid, chatUuid, null);
  }

}
