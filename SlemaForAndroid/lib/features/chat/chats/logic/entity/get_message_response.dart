import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/web_socket_message_response.dart';

class GetMessageResponse {
  final String messageUuid;
  final String chatUuid;
  final String authorUuid;
  final String text;
  final String timestamp;
  final String? fileName;
  final String? fileType;
  final String? fileUrl;
  GetMessageResponse({
    required this.messageUuid,
    required this.chatUuid,
    required this.authorUuid,
    required this.text,
    required this.timestamp,
    this.fileName,
    this.fileType,
    this.fileUrl,
  });

  factory GetMessageResponse.fromJson(Map<String, dynamic> json) {
    return GetMessageResponse(
      messageUuid: json['messageUuid'] as String,
      chatUuid: json['chatUuid'] as String,
      authorUuid: json['authorUuid'] as String,
      text: json['text'] as String,
      timestamp: json['timestamp'] as String,
      fileName: json['fileName'] as String?,
      fileType: json['fileType'] as String?,
      fileUrl: json['fileUrl'] as String?,
    );
  }

  GetMessageResponse copyWith({
    String? messageUuid,
    String? chatUuid,
    String? authorUuid,
    String? text,
    String? timestamp,
    String? fileName,
    String? fileType,
    String? fileUrl,
  }) {
    return GetMessageResponse(
      messageUuid: messageUuid ?? this.messageUuid,
      chatUuid: chatUuid ?? this.chatUuid,
      authorUuid: authorUuid ?? this.authorUuid,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileUrl: fileUrl ?? this.fileUrl,
    );
  }

  Message toMessage(String senderUsername) {
    return Message(
      messageUuid,
      text,
      authorUuid,
      chatUuid,
      null,
      fileUrl: fileUrl,
      fileName: fileName,
      fileType: fileType,
      senderUsername: senderUsername,
    );
  }
}