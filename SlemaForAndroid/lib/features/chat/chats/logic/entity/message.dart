import 'package:pg_slema/features/gallery/logic/entity/image_metadata.dart';

class Message {
  final String id;
  final String content;
  final String senderId;
  final String chatId;
  ImageMetadata? imageMetadata;
  final String? fileUrl;
  final String? fileName;
  final String? fileType;

  Message(
      this.id,
      this.content,
      this.senderId,
      this.chatId,
      this.imageMetadata,
          {
        this.fileUrl,
        this.fileName,
        this.fileType,
      }
      );

  Message copyWith({
    String? id,
    String? content,
    String? senderId,
    String? chatId,
    ImageMetadata? imageMetadata,
    String? fileUrl,
    String? fileName,
    String? fileType,
  }) {
    return Message(
      id ?? this.id,
      content ?? this.content,
      senderId ?? this.senderId,
      chatId ?? this.chatId,
      imageMetadata ?? this.imageMetadata,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
    );
  }
}