import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';

class WebSocketChat {
  final String id;
  final String name;
  final bool isGroup;
  final String createdAt;

  WebSocketChat(
      this.id,
      this.name,
      this.isGroup,
      this.createdAt,
      );

  factory WebSocketChat.fromJson(Map<String, dynamic> json) {
    return WebSocketChat(
      json['id'] as String,
      json['name'] as String,
      json['isGroup'] as bool,
      json['createdAt'] as String,
    );
  }
}


class MessageSender {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final bool isAdmin;

  MessageSender({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.isAdmin,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isAdmin: json['isAdmin'] as bool,
    );
  }
}


class WebSocketMessageResponse {
  final String id;
  final WebSocketChat chat;
  final MessageSender sender;
  final String content;
  final String timestamp;
  final bool isRead;
  final String? fileName;
  final String? fileType;
  final String? fileUrl;

  WebSocketMessageResponse(
      this.id,
      this.chat,
      this.sender,
      this.content,
      this.timestamp,
      this.isRead,
      this.fileName,
      this.fileType,
      this.fileUrl,
      );

  factory WebSocketMessageResponse.fromJson(Map<String, dynamic> json) {
    return WebSocketMessageResponse(
      json['id'] as String,
      WebSocketChat.fromJson(json['chat'] as Map<String, dynamic>),
      MessageSender.fromJson(json['sender'] as Map<String, dynamic>),
      json['content'] as String,
      json['timestamp'] as String,
      json['isRead'] as bool,
      json['fileName'] as String?,
      json['fileType'] as String?,
      json['fileUrl'] as String?,
    );
  }

  Message toMessage() {
    return Message(
      id,
      content,
      sender.id,
      chat.id,
      null,
      fileUrl: fileUrl,
      fileName: fileName,
      fileType: fileType,
      senderUsername: sender.username,
    );
  }
}