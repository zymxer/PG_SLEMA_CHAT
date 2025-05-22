import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/presentation/controller/chat_controller.dart';
import 'package:pg_slema/features/chat/chats/presentation/widget/chat_widget.dart';
import 'package:pg_slema/features/chat/chats/presentation/widget/message_widget.dart';
import 'package:pg_slema/utils/widgets/appbars/default_appbar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';
import 'package:pg_slema/utils/widgets/forms/text_input.dart';

class ChatScreen extends StatefulWidget {

  final ChatController controller;

  ChatScreen({
    super.key,
    required this.controller
});

  @override
  State<StatefulWidget> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultAppBar(title: "Chat name todo"),
        DefaultBody(
          child: ListView.separated(
            //itemCount: _controller.chats.length,
            itemCount: 15,
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) => const SizedBox(width: 10, height: 20),
            itemBuilder: (context, index) {
              return MessageWidget(
                  type: MessageType.Received
              );
            },
          ),
        ),
      ],
    );
  }

  void _onMessageTextChangedPlaceholder(String name) {
    //TODO replace
  }

}