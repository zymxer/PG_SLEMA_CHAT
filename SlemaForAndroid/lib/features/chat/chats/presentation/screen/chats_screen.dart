import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/features/chat/chats/presentation/controller/chats_controller.dart';
import 'package:pg_slema/features/chat/chats/presentation/screen/add_chat_screen.dart';
import 'package:pg_slema/features/chat/chats/presentation/widget/chat_widget.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body_with_floating_action_button.dart';
import 'package:pg_slema/utils/widgets/appbars/white_app_bar.dart';
import 'package:provider/provider.dart';

class ChatsScreen extends StatefulWidget {

  const ChatsScreen({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => ChatsScreenState();
}

class ChatsScreenState extends State<ChatsScreen> {

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    //_controller.fetchChats
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context, listen: true);
    return Column(children: [
      const WhiteAppBar(titleText: "Wiadomości"),
      DefaultBodyWithFloatingActionButton(
        onFloatingButtonPressed: _openAddExerciseScreen,  // TODO
        child: Column(
            children: [
              FutureBuilder<List<Chat>>(  // TODO init chatService data
                  future: _initialized? chatService.getAllChats() : Future.value([]),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if(snapshot.hasError) {
                      print("Error while fetching initial chats");
                      return const SizedBox.shrink();
                    }
                    _initialized = true;
                    return const SizedBox.shrink();
                  }
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: chatService.chats.length,
                  itemBuilder: (context, index) => ChatWidget(chatService.chats[index]),
                  ),
                ),
            ]
        ),
        // child: ListView.builder(
        //   //itemCount: _controller.chats.length,
        //   itemCount: 15,
        //   padding: EdgeInsets.zero,
        //   itemBuilder: (context, index) {
        //     return ChatWidget(
        //       chat: Chat("id", "Chat name"),
        //     );
        //   },
        // ),
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
