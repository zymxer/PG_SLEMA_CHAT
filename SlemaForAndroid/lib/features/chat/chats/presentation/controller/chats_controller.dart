import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';

class AllChatsController extends ChangeNotifier{
  String _search = "";
  late Future<List<Chat>> chatsFuture;
  late List<Chat> allChats;
  List<Chat> filteredChats = [];

  final ChatService chatService;
  final UserService userService;

  AllChatsController(this.chatService, this.userService);

  void fetchChats() async{
    chatsFuture = chatService.getAllChats();
    allChats = await chatsFuture;
    for(var chat in allChats) {
      if(chat.isGroup) {
        continue;
      }
      final members = await chatService.getChatMembers(chat.id);
      for(var member in members) {
        if(member.username != userService.currentUser!.name) {
          chat.name = member.username;
          break;
        }
      }
    }
    // chatsFuture = service.getAllChats().then((chats){
    //   allChats = chats;
    //   for(var chat in allChats) {
    //     if(chat.isGroup) {
    //       continue;
    //     }
    //     final members = await service.getChatMembers(chat.id);
    //   }
    //   return chats;
    // });
  }
}
