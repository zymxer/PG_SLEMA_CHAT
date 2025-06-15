import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat_member.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/create_chat_request.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/get_chat_response.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/get_message_response.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/post_message_request.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/post_message_responce.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/webSocket_message.dart';
import 'package:pg_slema/utils/token/token_service.dart';
import 'package:web_socket_channel/io.dart';

enum WebSocketState {
  disconnected,
  connecting,
  connected,
  error,
}

class ChatService extends ChangeNotifier {

  final Dio dio;
  final TokenService tokenService;
  // todo repository

  final String _baseUrl = '/api/chat';  // todo Move to ApplicationInfoRepository

  late IOWebSocketChannel _webSocketChannel;
  late StreamSubscription _socketSubscription;
  final StreamController<Message> _messageStreamController =
  StreamController<Message>.broadcast();
  WebSocketState wsState = WebSocketState.disconnected;

  Stream<Message> get newMessages => _messageStreamController.stream;

  List<Chat> chats = [];

  ChatService(this.dio, this.tokenService);

  Future<List<Chat>> getAllChats() async {

    final String endpoint = _baseUrl;
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

  Future<PostMessageResponse> sendMessage(PostMessageRequest request) async{

    final String endpoint = "$_baseUrl/${request.chat.id}/messages";

    final token = await tokenService.getToken();
    final body = await request.toFormData();
    try {
      final response = await dio.post(
        endpoint,
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PostMessageResponse(response.data, true);
      }
      else {
        throw Exception('Failed to send a message. Status code: ${response.statusCode}');
      }
    }

    catch (e) {
      throw Exception('Error during sending a message: $e');
    }
  }

  Future<List<ChatMember>> getChatMembers(String chatId) async {

    final String endpoint = "$_baseUrl/$chatId/members";
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
                  (jsonMember) => ChatMember.fromJson(jsonMember)
          ).toList();

        default:
          throw Exception('Failed to fetch chat members. Status code: ${response.statusCode}');
      }
    }
    catch (e) {
      throw Exception('Error during fetching chat members: $e');
    }
  }


  Future<void> connectWebSocket() async {
    final token = await tokenService.getToken();
    final uri = Uri.parse('ws://10.0.2.2:8082/ws/chat');

    wsState = WebSocketState.connecting;

    final webSocket = await WebSocket.connect(
      uri.toString(),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _webSocketChannel = IOWebSocketChannel(webSocket);
    wsState = WebSocketState.connected;
    print("WebSocket connected successfully");
    _socketSubscription = _webSocketChannel.stream.listen(
          (dynamic data) => _handleWebSocketMessages(data),
      onError: (error) {
            wsState = WebSocketState.error;
            print("WebSocket error: $error");
            },
      onDone: () {
            wsState = WebSocketState.disconnected;
            print("WebSocket closed");
      },
    );
  }

  void _handleWebSocketMessages(dynamic data) {
    try {

      final jsonData = json.decode(data);

      // print("*"*50);
      // print("TEST RECEIVED WEBSOCKET MESSAGE");
      // print("${jsonData}");
      // print("*"*50);
      // _messageStreamController.add(Message("random", "Pasha loh", "random", "db15d264-11f1-4c80-9906-b220168aa9bf"));
      // return;

      final message = GetMessageResponse.fromJson(jsonData).toMessage(); // Ensure Message has fromJson()

      print("*"*50);
      print("RECEIVED WEBSOCKET MESSAGE");
      print("*"*50);
      _messageStreamController.add(message);

      // final chatIndex = chats.indexWhere((c) => c.id == message.chatId);
      // if (chatIndex != -1) {
      //   // TODO ADD MESSAGE TO CHAT
      //
      //   notifyListeners();
      // }
    } catch (e) {
      print("Error parsing message: $e");
    }
  }

  Future<void> sendWebSocketMessage(String chatId, String text) async{
    final message = WebSocketMessage(text, chatId).toMap();
    _webSocketChannel.sink.add(json.encode(message));
  }




}