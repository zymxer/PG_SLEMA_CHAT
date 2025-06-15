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

  @override
  void initState() {
    super.initState();
    Provider.of<AllChatsController>(context, listen: false).fetchChats();
    Provider.of<AllChatsController>(context, listen: false).connectWebSocket();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AllChatsController>(context, listen: true);

    return Column(children: [
      const WhiteAppBar(titleText: "Wiadomości"),
      DefaultBodyWithFloatingActionButton(
        onFloatingButtonPressed: _openAddChatScreen,
        child: Column(children: [
          FutureBuilder<List<Chat>>(
              future: controller.chatsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print("Error while fetching initial chats");
                  return const SizedBox.shrink();
                } else if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: controller.allChats.length,
                      itemBuilder: (context, index) =>
                          ChatWidget(controller.allChats[index]),
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
        ]),
      ),
    ]);
  }

  void _openAddChatScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChatScreen(),
      ),
    );
  }
}
