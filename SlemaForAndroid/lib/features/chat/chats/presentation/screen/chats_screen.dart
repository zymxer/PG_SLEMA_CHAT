import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/features/chat/chats/presentation/controller/chats_controller.dart';
import 'package:pg_slema/features/chat/chats/presentation/screen/add_chat_screen.dart';
import 'package:pg_slema/features/chat/chats/presentation/widget/chat_widget.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body_with_floating_action_button.dart';
import 'package:pg_slema/utils/widgets/appbars/white_app_bar.dart';

class ChatsScreen extends StatefulWidget {

  final ChatService service;

  const ChatsScreen({
    super.key,
    required this.service,
  });

  @override
  State<StatefulWidget> createState() => ChatsScreenState();
}

class ChatsScreenState extends State<ChatsScreen> {
  late AllChatsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AllChatsController(
      service: widget.service,
    );

    //_controller.fetchChats
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const WhiteAppBar(titleText: "Wiadomości"),
      DefaultBodyWithFloatingActionButton(
        onFloatingButtonPressed: _openAddExerciseScreen,
        child: ListView.builder(
          //itemCount: _controller.chats.length,
          itemCount: 15,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return ChatWidget(
              chat: Chat("id", "Chat name"),
            );
          },
        ),
      ),
    ]);
  }

  void _openAddExerciseScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChatScreen(),
      ),
    );
  }
}
