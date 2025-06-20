import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/add_member_request.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat_member.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/create_chat_request.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/create_chat_response.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/get_chat_response.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/get_message_response.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/post_message_request.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/post_message_responce.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/webSocket_message.dart';
import 'package:pg_slema/features/gallery/logic/entity/image_metadata.dart';
import 'package:pg_slema/features/gallery/logic/service/image_service_chat_impl.dart';
import 'package:pg_slema/utils/token/token_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:collection/collection.dart';

enum WebSocketState {
  disconnected,
  connecting,
  connected,
  error,
}

class ChatService extends ChangeNotifier {
  final Dio dio;
  final TokenService tokenService;
  final ImageServiceChatImpl chatImageService;

  final String _backendBaseUrl = 'http://10.0.2.2:8082';
  final String _chatApiBaseUrl = '/api/chat';

  late IOWebSocketChannel _webSocketChannel;
  StreamSubscription? _socketSubscription;
  final StreamController<Message> _messageStreamController =
  StreamController<Message>.broadcast();

  WebSocketState _wsState = WebSocketState.disconnected;

  WebSocketState get wsState => _wsState;
  void setWsState(WebSocketState newState) {
    if (_wsState != newState) {
      _wsState = newState;
      notifyListeners();
    }
  }

  Stream<Message> get newMessages => _messageStreamController.stream;

  List<Chat> chats = [];

  ChatService(this.dio, this.tokenService, this.chatImageService) {
    // Optionally: Add LogInterceptor for Dio to see all HTTP requests
    // dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  Future<List<Chat>> getAllChats() async {
    final String endpoint = _backendBaseUrl + _chatApiBaseUrl;
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
      switch (response.statusCode) {
        case 200:
          final List<dynamic> data = response.data as List<dynamic>;
          final new_chats = data
              .map((jsonChat) => GetChatResponse.fromJson(jsonChat).toChat())
              .toList();
          chats = new_chats;
          notifyListeners();
          return chats;

        default:
          throw Exception(
              'Failed to fetch chats. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during fetching chats: $e');
    }
  }

  Chat getChat(String chatId) {
    final chat = chats.where((chat) => chat.id == chatId).singleOrNull;
    if (chat == null) {
      print("ChatService: getChat - Chat with ID $chatId not found in local list!");
    }
    return chat!;
  }

  Future<CreateChatResponse> createChat(CreateChatRequest request) async {
    final String endpoint = _backendBaseUrl + _chatApiBaseUrl;
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
      switch (response.statusCode) {
        case 200:
          return CreateChatResponse.fromJson(response.data);
        default:
          throw Exception(
              'Failed to create chat. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during creating a chat: $e');
    }
  }

  Future<List<Message>> getChatMessages(String chatId) async {
    final String endpoint = "$_backendBaseUrl$_chatApiBaseUrl/$chatId/messages";
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
      switch (response.statusCode) {
        case 200:
          final List<dynamic> data = response.data as List<dynamic>;

          List<GetMessageResponse> dtos = data
              .map((jsonMessage) => GetMessageResponse.fromJson(jsonMessage))
              .toList();
          List<Message> messages = [];
          // Load savedImages asynchronously first
          final savedImages = (await chatImageService.loadImageData()).toList();

          for (int i = 0; i < dtos.length; i++) {
            GetMessageResponse currentDto = dtos[i];

            // Prepend base URL for network file URLs if they are relative
            if (currentDto.fileUrl != null && !currentDto.fileUrl!.startsWith('http')) {
              currentDto = currentDto.copyWith(fileUrl: _backendBaseUrl + currentDto.fileUrl!);
            }

            Message message = currentDto.toMessage();

            // If it's an image message, check if it's already downloaded
            if (message.fileUrl != null) {
              final filenameFromUrl = message.fileUrl!.split('/').last;

              final existingMetadata = savedImages.firstWhereOrNull((entry) => entry.filename == filenameFromUrl);

              if (existingMetadata != null) {
                message = message.copyWith(imageMetadata: existingMetadata);
              } else {
                final downloadedMetadata = await downloadAndSaveFile(currentDto);
                message = message.copyWith(imageMetadata: downloadedMetadata);
              }
            }
            messages.add(message);
          }
          return messages;

        default:
          throw Exception(
              'Failed to fetch chat messages. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during fetching chat messages: $e');
    }
  }

  Future<PostMessageResponse> sendMessage(PostMessageRequest request) async {
    final String endpoint = "$_backendBaseUrl$_chatApiBaseUrl/${request.chat.id}/messages";

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
        return PostMessageResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(
            'Failed to send a message. Status code: ${response.statusCode}, Body: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error during sending a message: $e');
    }
  }

  Future<bool> addChatMember(String chatId, AddMemberRequest request) async{
    final String endpoint = "$_backendBaseUrl$_chatApiBaseUrl/$chatId/members";
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
      switch (response.statusCode) {
        case 201:
          return true;

        default:
          throw Exception(
              'Failed to add chat member. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during adding chat member: $e');
    }
  }

  Future<List<ChatMember>> getChatMembers(String chatId) async {
    final String endpoint = "$_backendBaseUrl$_chatApiBaseUrl/$chatId/members";
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
      switch (response.statusCode) {
        case 200:
          final List<dynamic> data = response.data as List<dynamic>;
          return data
              .map((jsonMember) => ChatMember.fromJson(jsonMember))
              .toList();

        default:
          throw Exception(
              'Failed to fetch chat members. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during fetching chat members: $e');
    }
  }

  Future<void> connectWebSocket() async {
    setWsState(WebSocketState.connecting);

    final token = await tokenService.getToken();
    if (token == null) {
      setWsState(WebSocketState.error);
      return;
    }

    final wsUri = Uri.parse('ws://10.0.2.2:8082/ws/chat'); // WebSocket URI is often different from HTTP API base URL

    try {
      final webSocket = await WebSocket.connect(
        wsUri.toString(),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      _webSocketChannel = IOWebSocketChannel(webSocket);
      setWsState(WebSocketState.connected);

      _socketSubscription?.cancel();
      _socketSubscription = _webSocketChannel.stream.listen(
            (dynamic data) => _handleWebSocketMessages(data),
        onError: (error) {
          setWsState(WebSocketState.error);
          _socketSubscription?.cancel();
        },
        onDone: () {
          setWsState(WebSocketState.disconnected);
          _socketSubscription?.cancel();
        },
      );
    } on WebSocketException catch (e) {
      setWsState(WebSocketState.error);
    } on TimeoutException {
      setWsState(WebSocketState.error);
    } catch (e) {
      setWsState(WebSocketState.error);
    }
  }

  Future<void> disconnectWebSocket() async {
    if (_webSocketChannel != null && _wsState == WebSocketState.connected) {
      await _socketSubscription?.cancel();
      await _webSocketChannel.sink.close(1000, 'Client disconnected');
      setWsState(WebSocketState.disconnected);
    } else {
    }
  }


  void _handleWebSocketMessages(dynamic data) {
    try {
      final jsonData = json.decode(data);

      print("FLUTTER: Received raw WebSocket data: $data");
      print("FLUTTER: Decoded JSON data: $jsonData");

      GetMessageResponse dto = GetMessageResponse.fromJson(jsonData);

      // Prepend base URL for network file URLs if they are relative
      if (dto.fileUrl != null && !dto.fileUrl!.startsWith('http')) {
        dto = dto.copyWith(fileUrl: _backendBaseUrl + dto.fileUrl!);
      }

      Message message = dto.toMessage();

      // If it's an image message, download and attach ImageMetadata
      if (message.fileUrl != null) {
        _loadImageMetadataAndAddMessage(message, dto);
        return;
      }

      _messageStreamController.add(message); // Add non-image message directly
    } catch (e) {
    }
  }

  Future<void> _loadImageMetadataAndAddMessage(Message initialMessage, GetMessageResponse dto) async {
    try {
      final filenameFromUrl = initialMessage.fileUrl!.split('/').last;

      // This is inefficient, consider optimizing by checking a local cache without reloading all
      final savedImages = await chatImageService.loadImageData();

      final existingMetadata = savedImages.firstWhereOrNull((entry) => entry.filename == filenameFromUrl);

      ImageMetadata finalMetadata;

      if (existingMetadata != null) {
        finalMetadata = existingMetadata;
      } else {
        // Download and save it if not existing
        finalMetadata = await downloadAndSaveFile(dto);
      }

      // Update the message with the final metadata and add to stream
      final updatedMessage = initialMessage.copyWith(imageMetadata: finalMetadata);
      _messageStreamController.add(updatedMessage);
    } catch (e) {
      print("FLUTTER ERROR: Failed to load/download image metadata for WS message: $e");
      _messageStreamController.add(initialMessage);
    }
  }

  Future<void> sendWebSocketMessage(String chatId, String text) async {
    if (_wsState != WebSocketState.connected) {
      throw Exception('WebSocket is not connected.');
    }
    final message = WebSocketMessage(text, chatId).toMap();
    _webSocketChannel.sink.add(json.encode(message));
  }

  Future<ImageMetadata> downloadAndSaveFile(GetMessageResponse dto) async {
    final token = await tokenService.getToken();
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String filenameFromUrl = dto.fileUrl!.split('/').last;
    final String savePath = '${appDocDir.path}/app_images/$filenameFromUrl';

    await Directory('${appDocDir.path}/app_images').create(recursive: true);

    print("ChatService: Downloading file from: ${dto.fileUrl!} to $savePath");

    await dio.download(
      dto.fileUrl!,
      savePath,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    return chatImageService.saveImage(XFile(
      savePath,
      name: filenameFromUrl,
      mimeType: dto.fileType,
    ));
  }

  @override
  void dispose() {
    _messageStreamController.close();
    disconnectWebSocket();
    super.dispose();
  }
}