import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';

class PostMessageResponse {
  final String id;
  final String content;
  final String senderId;
  final String chatId;
  final String timestamp;
  final bool isRead;
  final String? fileName;
  final String? fileType;
  final String? fileUrl;

  PostMessageResponse({
    required this.id,
    required this.content,
    required this.senderId,
    required this.chatId,
    required this.timestamp,
    required this.isRead,
    this.fileName,
    this.fileType,
    this.fileUrl,
  });

  factory PostMessageResponse.fromJson(Map<String, dynamic> json) {
    return PostMessageResponse(
      id: json['id'] as String,
      content: json['content'] as String,
      senderId: json['sender']['id'] as String,
      chatId: json['chat']['id'] as String,
      timestamp: json['timestamp'] as String,
      isRead: json['isRead'] as bool,
      fileName: json['fileName'] as String?,
      fileType: json['fileType'] as String?,
      fileUrl: json['fileUrl'] as String?,
    );
  }

  Message toMessage() {
    return Message(
      id,
      content,
      senderId,
      chatId,
      null,
      fileUrl: fileUrl,
      fileName: fileName,
      fileType: fileType,
    );
  }
}