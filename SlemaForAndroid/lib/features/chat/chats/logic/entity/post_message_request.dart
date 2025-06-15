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
    formData.fields.add(MapEntry('message', text ?? ""));
    if (file != null) {
      formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(file!.path,
              filename: file!.name.split('/').last)));
    }
    return formData;
  }
}
