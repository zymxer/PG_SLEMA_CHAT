import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/create_chat_request.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/create_chat_response.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/features/chat/user/logic/entity/user.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';

class AddChatController extends ChangeNotifier {
  String _search = "";
  int shownCount = 15;
  List<User> selected = [];
  late Future<List<User>> usersFuture;
  late List<User> allUsers;
  List<User> filteredUsers = [];

  final ChatService chatService;
  final UserService userService;

  AddChatController(this.chatService, this.userService);

  String get search => _search;
  set search(String value) {
    _search = value;
    if (allUsers.isEmpty) {
      return;
    }
    filteredUsers = allUsers
        .where((user) => user.name.toLowerCase().startsWith(search.toLowerCase()))
        .take(shownCount)
        .toList();
    notifyListeners();
  }

  void createChat() async {
    if (selected.isEmpty) {
      return;
    }

    String chatName;
    bool isGroup;
    String? interlocutorUsername;
    List<String>? memberIds;

    if (selected.length == 1) {
      final interlocutor = selected[0];
      chatName = interlocutor.name;
      isGroup = false;
      print('Interlocutor username: ${interlocutor.name}');
      interlocutorUsername = interlocutor.name;
      memberIds = null;
    } else {
      chatName = "Group chat";
      isGroup = true;
      interlocutorUsername = null;

      memberIds = selected.map((user) => user.id).toList();

      memberIds.remove(userService.currentUser!.id);
    }

    try {
      final CreateChatRequest request = CreateChatRequest(
        chatName,
        isGroup,
        interlocutorUsername,
        memberIds: memberIds,
      );

      final CreateChatResponse response = await chatService.createChat(request);

      selected = [];
      notifyListeners();


    } catch (e) {

    }
  }

  void onUserTap(User user) {
    if (!selected.contains(user)) {
      selected.add(user);
    } else {
      selected.remove(user);
    }
    notifyListeners();
  }

  bool isUserSelected(User user) {
    return selected.contains(user);
  }

  void fetchUsers() async {
    usersFuture = userService.getAllUsers().then((users) {
      allUsers = users;
      allUsers.remove(userService.currentUser!);
      filteredUsers = allUsers.take(shownCount).toList();
      notifyListeners();
      return users;
    }).catchError((e) {

      return <User>[];
    });
  }
}