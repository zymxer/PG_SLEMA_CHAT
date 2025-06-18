import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';

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
      json['id'],
      json['name'] as String,
      json['isGroup'] as bool,
      json['createdAt'] as String,
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
      json['id'],
      WebSocketChat.fromJson(json['chat'] as Map<String, dynamic>),
      MessageSender.fromJson(json['sender'] as Map<String, dynamic>),
      json['content'],
      json['timestamp'],
      json['isRead'] as bool,
      json['fileName'] as String?,
      json['fileType'] as String?,
      json['fileUrl'] as String?,
    );
  }

  Message toMessage() {
    return Message(id, content, sender.id, chat.id, null);
  }
}

// {
// "id" : "8998ea23-0ea0-4d3b-bb22-bd8d275a92b0",
// "chat" : {
// "id" : "9a576ac9-4fa4-46fd-9d93-dfe116375e57",
// "name" : "Karol",
// "isGroup" : false,
// "createdAt" : "2025-06-16T11:40:02.010045"
// },
// "sender" : {
// "id" : "defff06a-01ea-4f98-9125-8abcd7391456",
// "username" : "Aleksandra",
// "password" : "$2a$10$vfB9RybLix1.mSsCg9/tgu21MKI8pfV6vkr8JEyNpoTiMuRHXbl.i",
// "email" : "aleksandra@gmail.com",
// "created_at" : "2025-06-16T11:39:31.387141",
// "isAdmin" : false
// },
// "content" : "handle message",
// "timestamp" : "2025-06-16T11:46:17.463935362",
// "isRead" : false,
// "fileName" : null,
// "fileType" : null,
// "fileUrl" : null
// }
