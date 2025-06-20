import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/web_socket_message_response.dart';

class GetMessageResponse {
  final String id;
  final WebSocketChat chat;
  final MessageSender sender;
  final String content;
  final String timestamp;
  final bool isRead;
  final String? fileName;
  final String? fileType;
  final String? fileUrl;
  GetMessageResponse({
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

  factory GetMessageResponse.fromJson(Map<String, dynamic> json) {
    return GetMessageResponse(
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

  GetMessageResponse copyWith({
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
    return GetMessageResponse(
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
    );
  }
}