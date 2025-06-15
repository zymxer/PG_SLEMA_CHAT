import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/features/chat/chats/presentation/controller/chat_controller.dart';
import 'package:pg_slema/features/chat/chats/presentation/widget/chat_input_field_widget.dart';
import 'package:pg_slema/features/chat/chats/presentation/widget/chat_widget.dart';
import 'package:pg_slema/features/chat/chats/presentation/widget/message_widget.dart';
import 'package:pg_slema/utils/widgets/appbars/default_appbar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';
import 'package:pg_slema/utils/widgets/forms/text_input.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  ChatScreen(this.chat, {super.key});

  @override
  State<StatefulWidget> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ChatController>(context, listen: false).currentChat = widget.chat;
    Provider.of<ChatController>(context, listen: false)
        .fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ChatController>(context, listen: true);
    return Column(children: [
      DefaultAppBar(title: widget.chat.name),
      DefaultBody(
        child: Column(children: [
          const SizedBox(height: 5),
          Expanded(
              child: ListView.separated(
            shrinkWrap: true,
            itemCount: controller.messages.length,
            itemBuilder: (context, index) {
              return MessageWidget(controller.messages[index]);
            },
            // itemCount: 5,
            // itemBuilder: (context, index) {
            //   return MessageWidget(Message("id", "text", "id2"));
            // },
            separatorBuilder: (context, index) =>
                const SizedBox(width: 10, height: 20),
          )),
          const SizedBox(height: 5),
          ChatInputField(
            textEditingController: controller.textEditingController,
            onChanged: (value) {
              controller.message = value;
            },
            label: "Type a message",
            postfixIcon: controller.inputState == ChatInputState.Message
                ? Icons.send_outlined
                : Icons.attachment_outlined, // Attachment icon: Icons.attach_file
            onPostfixPressed: () { controller.onPostfixPressed(); },

          ),
          const SizedBox(height: 20),
        ]),
      ),
    ]);
  }

}
