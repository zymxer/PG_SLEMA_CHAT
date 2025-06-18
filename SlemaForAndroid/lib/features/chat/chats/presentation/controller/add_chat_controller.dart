import 'package:flutter/cupertino.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/add_member_request.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/create_chat_request.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/features/chat/user/logic/entity/user.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';
import 'package:provider/provider.dart';

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
        .where(
            (user) => user.name.toLowerCase().startsWith(search.toLowerCase()))
        .take(shownCount)
        .toList();
    notifyListeners();
  }

  void createChat() async {
    final interlocutor = selected[0];
    // todo chat name
    final chat = await chatService.createChat(CreateChatRequest(
        selected.length == 1 ? interlocutor.name : "Group chat",
        selected.length > 1? 1: 0,
        interlocutor.name)
    );
    if(selected.length > 1) {
      final members = await chatService.getChatMembers(chat.id);
      for(int i = 0; i < selected.length; i++) {
        //todo role selection
        await chatService.addChatMember(chat.id, AddMemberRequest(selected[i].name, "interlocutor"));
      }
    }
    selected = [];
    final members2 = await chatService.getChatMembers(chat.id);
    print(members2);
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
    });
  }
}
