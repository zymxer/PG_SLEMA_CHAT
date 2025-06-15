import 'package:pg_slema/features/gallery/logic/entity/image_metadata.dart';

class Message {
  final String id;
  final String content;
  final String senderId;
  final String chatId;
  late ImageMetadata? imageMetadata;

  Message(this.id, this.content, this.senderId, this.chatId, this.imageMetadata);
}