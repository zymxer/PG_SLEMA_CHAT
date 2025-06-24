

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
import 'package:pg_slema/features/chat/chats/logic/entity/web_socket_message_response.dart'; 
import 'package:pg_slema/features/gallery/logic/entity/image_metadata.dart';
import 'package:pg_slema/features/gallery/logic/service/image_service_chat_impl.dart';
import 'package:pg_slema/features/settings/logic/application_info_repository.dart';
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
  final ApplicationInfoRepository applicationInfoRepository;

  late String _backendBaseUrl;// = 'http://10.0.2.2:8082';
  final String _chatApiBaseUrl = '/api/chat';

  late IOWebSocketChannel _webSocketChannel;
  StreamSubscription? _socketSubscription;
  final StreamController<Message> _messageStreamController =
  StreamController<Message>.broadcast();

  
  final StreamController<void> _requestChatListUpdateController = StreamController<void>.broadcast();
  Stream<void> get requestChatListUpdateStream => _requestChatListUpdateController.stream;

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

  ChatService(this.dio, this.tokenService, this.chatImageService, this.applicationInfoRepository) {
    _backendBaseUrl = applicationInfoRepository.getChatServiceAddress();
    _backendBaseUrl = "http://$_backendBaseUrl";
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
          _triggerChatListUpdate(); 
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
          final savedImages = (await chatImageService.loadImageData()).toList();

          for (int i = 0; i < dtos.length; i++) {
            GetMessageResponse currentDto = dtos[i];

            if (currentDto.fileUrl != null && !currentDto.fileUrl!.startsWith('http')) {
              currentDto = currentDto.copyWith(fileUrl: _backendBaseUrl + currentDto.fileUrl!);
            }

            Message message = currentDto.toMessage();

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

    final wsUri = Uri.parse('ws://10.0.2.2:8082/ws/chat');

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

      
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('type') && jsonData['type'] is String) {
        String notificationType = jsonData['type'] as String;
        if (notificationType == 'CHAT_CREATED' || notificationType == 'CHAT_UPDATED' || notificationType == 'CHAT_DELETED') {
          _triggerChatListUpdate(); 
          return; 
        }
      }

      GetMessageResponse dto = GetMessageResponse.fromJson(jsonData);

      if (dto.fileUrl != null && !dto.fileUrl!.startsWith('http')) {
        dto = dto.copyWith(fileUrl: _backendBaseUrl + dto.fileUrl!);
      }

      Message message = dto.toMessage();

      
      if (message.fileUrl != null) {
        _loadImageMetadataAndAddMessage(message, dto);
        return;
      }

      _internalUpdateMessageListFromStream(message);

    } catch (e) {
    }
  }

  Future<void> _loadImageMetadataAndAddMessage(Message initialMessage, GetMessageResponse dto) async {
    try {
      final filenameFromUrl = initialMessage.fileUrl!.split('/').last;

      
      final savedImages = await chatImageService.loadImageData();

      final existingMetadata = savedImages.firstWhereOrNull((entry) => entry.filename == filenameFromUrl);

      ImageMetadata finalMetadata;

      if (existingMetadata != null) {
        finalMetadata = existingMetadata;
      } else {
        
        finalMetadata = await downloadAndSaveFile(dto);
      }

      
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

  
  
  
  Future<void> deleteChat(String chatId, String token) async { 
    final String endpoint = "$_backendBaseUrl$_chatApiBaseUrl/$chatId";
    
    

    
    print("ChatService: Attempting to delete chat $chatId");
    print("ChatService: Sending token: $token"); 

    try {
      final response = await dio.delete(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', 
          },
        ),
      );
      if (response.statusCode == 200) {
        print("ChatService: Chat $chatId deleted successfully on backend.");
        _triggerChatListUpdate(); 
      } else {
        
        throw Exception('Failed to delete chat. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) { 
      if (e.response != null) {
        print('ChatService: DioError response data: ${e.response?.data}');
        print('ChatService: DioError response headers: ${e.response?.headers}');
        print('ChatService: DioError response status code: ${e.response?.statusCode}');
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          throw Exception('AuthenticationException: У вас нет прав для выполнения этого действия. Status: ${e.response?.statusCode}');
        }
      }
      throw Exception('Error during chat deletion: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred during chat deletion: $e');
    }
  }
  


  
  void _internalUpdateMessageListFromStream(Message message) async {
    final bool chatExistsLocally = chats.any((chat) => chat.id == message.chatId);

    if (!chatExistsLocally) {
      print("ChatService: Received message for unknown chat ID ${message.chatId}. Triggering chat list update.");
      _triggerChatListUpdate(); 
    }

    final String displayContent = (message.content == "Required") ? "" : message.content;
    final Message correctedMessage = message.copyWith(content: displayContent);

    _messageStreamController.add(correctedMessage);
  }
  

  void _triggerChatListUpdate() {
    _requestChatListUpdateController.add(null);
  }

  void removeChatLocally(String chatId) {
    
    final initialLength = chats.length;
    chats.removeWhere((c) => c.id == chatId);
    if (chats.length < initialLength) {
      
      notifyListeners(); 
    }
    print("ChatService: Chat $chatId removed locally. New chat count: ${chats.length}");
  }

  @override
  void dispose() {
    _messageStreamController.close();
    _requestChatListUpdateController.close(); 
    disconnectWebSocket();
    super.dispose();
  }
}