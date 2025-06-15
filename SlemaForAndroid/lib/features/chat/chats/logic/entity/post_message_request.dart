import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';

class PostMessageRequest {
  final Chat chat;
  final String? text;
  final XFile? file;

  PostMessageRequest(this.chat, this.text, this.file);

  Future<FormData> toFormData() async {
    final formData = FormData();

    // Send message as a separate part using MultipartFile
    formData.files.add(MapEntry(
      'message',
      MultipartFile.fromString(text ?? "Required"),
    ));

    if (file != null) {
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(
          file!.path,
          filename: file!.name.split('/').last,
        ),
      ));
    }

    return formData;
  }
}
