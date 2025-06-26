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

  WebSocketMessageResponse({
    required this.id,
    required this.chat,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.fileName,
    this.fileType,
    this.fileUrl,
  });

  factory WebSocketMessageResponse.fromJson(Map<String, dynamic> json) {
    return WebSocketMessageResponse(
      id: json['id'] as String,
      chat: WebSocketChat.fromJson(json['chat'] as Map<String, dynamic>),
      sender: MessageSender.fromJson(json['sender'] as Map<String, dynamic>),
      content: json['content'] as String,
      timestamp: json['timestamp'] as String,
      isRead: json['isRead'] as bool,
      fileName: json['fileName'] as String?,
      fileType: json['fileType'] as String?,
      fileUrl: json['fileUrl'] as String?,
    );
  }

  WebSocketMessageResponse copyWith({
    String? id,
    WebSocketChat? chat,
    MessageSender? sender,
    String? content,
    String? timestamp,
    bool? isRead,
    String? fileName,
    String? fileType,
    String? fileUrl,
  }) {
    return WebSocketMessageResponse(
      id: id ?? this.id,
      chat: chat ?? this.chat,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileUrl: fileUrl ?? this.fileUrl,
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