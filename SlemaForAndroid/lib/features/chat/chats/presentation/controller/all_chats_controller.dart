import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';

class AllChatsController extends ChangeNotifier{
  final String _search = "";
  late Future<List<Chat>> chatsFuture;
  late List<Chat> allChats;
  List<Chat> filteredChats = [];

  final ChatService chatService;
  final UserService userService;

  AllChatsController(this.chatService, this.userService);

  void fetchChats() async {
    chatsFuture = chatService.getAllChats();
    allChats = await chatsFuture;
    for(var chat in allChats) {
      if(chat.isGroup) {
        continue;
      }
      final members = await chatService.getChatMembers(chat.id);
      for(var member in members) {
        if(member.user.id != userService.currentUser!.id) {
          chat.name = member.user.username;
          break;
        }
      }
    }
    notifyListeners();
  }

  void connectWebSocket() async {

    if(chatService.wsState == WebSocketState.connected ||
        chatService.wsState == WebSocketState.connecting) {
      return;
    }

    try {
      await chatService.connectWebSocket();

    } catch (e) {

    }
  }


  @override
  void dispose() {
    chatService.disconnectWebSocket();
    super.dispose();
  }
}