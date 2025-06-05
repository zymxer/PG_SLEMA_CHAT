import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/create_chat_request.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/get_chat_response.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/get_message_response.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/post_message_request.dart';
import 'package:pg_slema/utils/token/token_service.dart';
import 'package:web_socket_channel/io.dart';

class ChatService extends ChangeNotifier {

  final Dio dio;
  final TokenService tokenService;
  // todo repository

  final String _baseUrl = '/api/chat';
  late IOWebSocketChannel _webSocketChannel;

  List<Chat> chats = [];

  ChatService(this.dio, this.tokenService);

  int call = 0;
  Future<List<Chat>> getAllChats() async {

    final String endpoint = _baseUrl;
    final token = await tokenService.getToken();
    call = call + 1;
    print("GET ALL CHATS CALL: $call");

    try {
      final response = await dio.get(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        ),
      );
      switch(response.statusCode) {
        case 200:
          final List<dynamic> data = response.data as List<dynamic>;
          final new_chats = data.map(
                  (jsonChat) => GetChatResponse.fromJson(jsonChat).toChat()
          ).toList();
          // TODO add new chats to repository, assign chats to all from repository
          chats = new_chats;
          notifyListeners();
          return chats;

        default:
          throw Exception('Failed to fetch chats. Status code: ${response.statusCode}');
      }
    }
    catch (e) {
      throw Exception('Error during fetching chats: $e');
    }
  }

  Future<bool> createChat(CreateChatRequest request) async {

    final String endpoint = _baseUrl;
    final token = await tokenService.getToken();

    try {
      final response = await dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        ),
      );
      switch(response.statusCode) {
        case 200:
          return true;
        default:
          throw Exception('Failed to fetch chats. Status code: ${response.statusCode}');
      }
    }
    catch (e) {
      throw Exception('Error during creating a chat: $e');
    }
  }

  Future<List<Message>> getChatMessages(String chatId) async {

    final String endpoint = "$_baseUrl/$chatId/messages";
    final token = await tokenService.getToken();

    try {
      final response = await dio.get(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        ),
      );
      switch(response.statusCode) {
        case 200:
          final List<dynamic> data = response.data as List<dynamic>;
          return data.map(
                  (jsonMessage) => GetMessageResponse.fromJson(jsonMessage).toMessage()
          ).toList();

        default:
          throw Exception('Failed to fetch chat messages. Status code: ${response.statusCode}');
      }
    }
    catch (e) {
      throw Exception('Error during fetching chat messages: $e');
    }
  }

  //todo response
  Future<bool> sendMessage(PostMessageRequest request) async{

    final String endpoint = "$_baseUrl/${request.chat.id}/messages";
    final token = await tokenService.getToken();

    try {
      final response = await dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        ),
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