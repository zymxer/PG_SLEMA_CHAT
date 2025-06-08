import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';

class AllChatsController extends ChangeNotifier{
  String _search = "";
  late Future<List<Chat>> chatsFuture;
  late List<Chat> allChats;
  List<Chat> filteredChats = [];

  final ChatService service;

  AllChatsController(this.service);

  void fetchChats() async{
    chatsFuture = service.getAllChats().then((chats) {
      allChats = chats;
      return chats;
    });
  }
}
