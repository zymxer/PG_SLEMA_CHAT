import 'dart:convert';
import 'package:chat_app/features/chat/logic/entity/chat.dart';
import 'package:chat_app/features/chat/logic/entity/create_chat_request.dart';
import 'package:chat_app/features/chat/logic/entity/get_chat_response.dart';
import 'package:chat_app/features/chat/logic/entity/get_message_response.dart';
import 'package:chat_app/features/chat/logic/entity/message.dart';
import 'package:chat_app/features/chat/logic/entity/post_message_request.dart';
import 'package:chat_app/utils/token/token_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatService {
  late String _baseUrl;

  ChatService() {
    String apiPath = dotenv.env['API_PATH'] ?? "http://localhost:8080";
    _baseUrl = '$apiPath/api/chat';
  }

  //
  Future<List<Chat>> getAllChats() async {

    final String url = _baseUrl;

    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {

        final List<dynamic> jsonResponse = json.decode(response.body);
        List<GetChatResponse> chatDtos = jsonResponse.map((jsonChat) => GetChatResponse.fromJson(jsonChat)).toList();
        List<Chat> chats = chatDtos.map((chatDto) => chatDto.toChat()).toList();
        return chats;
      }
      else {
        throw Exception('Failed to get chats. Status code: ${response.statusCode}');
      }
    }

    catch (e) {
      throw Exception('Error during getting all chats: $e');
    }
  }

  Future<bool> createChat(CreateChatRequest request) async {

    final String url = _baseUrl;

    try {
      print("-----------------------------------------");
      final token = await TokenService.getToken();
      print(token);
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(request.toJson())
      );

      if (response.statusCode == 200) {
        return true;
      }
      else {
        throw Exception('Failed to create chat. Status code: ${response.statusCode}');
      }
    }

    catch (e) {
      throw Exception('Error during creating a chat: $e');
    }
  }

  Future<List<Message>> getChatMessages(String chatId) async {

    final String url = "$_baseUrl/$chatId/messages";

    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {

        final List<dynamic> jsonResponse = json.decode(response.body);
        List<GetMessageResponse> messageDtos = jsonResponse.map((jsonMessage) => GetMessageResponse.fromJson(jsonMessage)).toList();
        List<Message> messages = messageDtos.map((messageDto) => messageDto.toMessage()).toList();
        return messages;
      }
      else {
        throw Exception('Failed to get chats. Status code: ${response.statusCode}');
      }
    }

    catch (e) {
      throw Exception('Error during getting all chats: $e');
    }
  }

  //todo response
  Future<bool> sendMessage(PostMessageRequest request) async{

    final String url = "$_baseUrl/${request.chat.id}/messages";

    try {
      final token = await TokenService.getToken();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(request.toJson())
      );

      if (response.statusCode == 200) {
        return true;
      }
      else {
        throw Exception('Failed to send a message. Status code: ${response.statusCode}');
      }
    }

    catch (e) {
      throw Exception('Error during sending a message: $e');
    }
  }

}