import 'package:chat_app/features/chat/logic/entity/chat.dart';
import 'package:flutter/material.dart';

class ChatWidget extends StatefulWidget {
  final Chat chat;

  const ChatWidget({
    super.key,
    required this.chat,
  });

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.chat), // Profile pic icon
      title: Text(widget.chat.name), // Chat name (e.g., "Chat 1")
      subtitle: Text("Preview"), // todo Message preview
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("hh:mm"), // todo Time of last message
        ],
      ),
      onTap: () {
        Navigator.pushNamed(context, "/conversation", arguments: widget.chat);
      },
    );
  }
}