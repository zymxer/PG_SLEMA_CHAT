import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/post_message_request.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';

enum ChatInputState { Message, Attachment }

class ChatController extends ChangeNotifier {
  String _message = "";
  ChatInputState inputState = ChatInputState.Attachment;
  final TextEditingController textEditingController = TextEditingController();
  late Chat _currentChat;
  late Future<List<Message>> messagesFuture;
  Map<Chat, List<Message>> messagesMap = {};
  List<Message> messages = [];

  final ChatService chatService;
  final UserService userService;

  ChatController(this.chatService, this.userService) {
    chatService.addListener(_updateMessageList);
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
  void _updateMessageList() {
    for (var message in chatService.newMessages) {
      messagesMap[message.chatId]!.add(message);
      messages = messagesMap[message.chatId]!;
    }
    notifyListeners();
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
    try {
      final result = await chatService.sendMessage(PostMessageRequest(_currentChat, _message));
      messages.add(Message(result.messageUuid, _message, userService.currentUser!.id, _currentChat.id));
      message = "";
      textEditingController.clear();
      notifyListeners();
    }
    catch (e) {
      throw Exception('Error during sending a message: $e');
    }
  }

  void _sendAttachment() async{

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
