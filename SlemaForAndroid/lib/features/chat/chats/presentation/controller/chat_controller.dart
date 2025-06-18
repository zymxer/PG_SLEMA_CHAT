import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/post_message_request.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/post_message_responce.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';
import 'package:pg_slema/features/gallery/logic/service/image_service.dart';
import 'package:pg_slema/features/gallery/logic/service/image_service_chat_impl.dart';

enum ChatInputState { Message, Attachment }

class ChatController extends ChangeNotifier {
  String _message = "";
  ChatInputState inputState = ChatInputState.Attachment;
  final TextEditingController textEditingController = TextEditingController();
  late Chat _currentChat;
  late Future<List<Message>> messagesFuture;
  Map<Chat, List<Message>> messagesMap = {};
  List<Message> messages = [];
  late StreamSubscription<Message> _messageSubscription;

  final picker = ImagePicker();


  final ChatService chatService;
  final UserService userService;
  final ImageServiceChatImpl chatImageService;

  ChatController(this.chatService, this.userService, this.chatImageService) {
    _messageSubscription = chatService.newMessages.listen(_updateMessageList);
  }

  set message(String value) {
    _message = value;
    inputState =
        _message.isEmpty ? ChatInputState.Attachment : ChatInputState.Message;
    notifyListeners();
  }

  set currentChat(Chat value) {
    _currentChat = value;
    messagesMap.putIfAbsent(_currentChat, () => []);
    messages = messagesMap[_currentChat]!;
  }

  // Todo
  void _updateMessageList(Message message) {
    final chat = chatService.getChat(message.chatId);

    print("*"*50);
    print("HANDLING WEBSOCKET MESSAGE");
    print("*"*50);
    messagesMap.putIfAbsent(chat, () => []);
    messagesMap[chat]!.add(message);

    if (_currentChat.id == chat.id) {
      messages = messagesMap[chat]!;
      notifyListeners();
    }
  }

  void fetchMessages() async {
    messagesFuture = chatService.getChatMessages(_currentChat.id).then((messagesList) {
      messagesMap[_currentChat] = messagesList;
      messages = messagesMap[_currentChat]!;
      notifyListeners();
      return messagesList;
    });
  }

  void _sendMessage() async{
    if(_message.isEmpty) {
      return;
    }
    // try {
    //   final result = await chatService.sendMessage(PostMessageRequest(_currentChat, _message, null));
    //   messages.add(Message(result.messageUuid, _message, userService.currentUser!.id, _currentChat.id, null));
    //   message = "";
    //   textEditingController.clear();
    //   notifyListeners();
    // }
    // todo use when WebSocket works
    try {
      await chatService.sendWebSocketMessage(_currentChat.id, _message);
      messages.add(Message("messageIdUnused", _message, userService.currentUser!.id, _currentChat.id, null));
      message = "";
      textEditingController.clear();
      notifyListeners();
    }
    catch (e) {
      throw Exception('Error during sending a message: $e');
    }
  }

  void _sendAttachment() async{
    final (filesMetadata, pickedFiles) = await chatImageService.selectAndAddImagesFromGallery();
    final List<PostMessageResponse> responses = [];
    for(var file in pickedFiles) {
      responses.add(await chatService.sendMessage(PostMessageRequest(_currentChat, null, file)));
    }
    for (int i = 0; i < responses.length; i++) {
      final response = responses[i];
      final metadata = filesMetadata[i];
      messages.add(Message(response.messageUuid, "", userService.currentUser!.id, _currentChat.id, metadata));
      message = "";
      textEditingController.clear();
      notifyListeners();
    }
  }

  void onPostfixPressed() {
    switch(inputState) {
      case ChatInputState.Message:
        _sendMessage();
        break;
      case ChatInputState.Attachment:
        _sendAttachment();
        break;
    }
  }
}
