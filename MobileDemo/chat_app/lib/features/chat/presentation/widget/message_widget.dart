
import 'package:chat_app/features/chat/logic/entity/message.dart';
import 'package:chat_app/features/user/logic/entity/user.dart';
import 'package:chat_app/theme/messageStyle.dart';
import 'package:flutter/material.dart';

enum MessageType {
  sent,
  received
}

class MessageWidget extends StatelessWidget {
  late MessageType type;
  late MessageStyle _style;
  late Message message;
  late Size size;

  MessageWidget(this.message, this.size, {super.key}) {

    type = message.senderId == User.currentUser!.id ?
      MessageType.sent : MessageType.received;


    switch (type) {
      case MessageType.received:
        _style = ReceivedMessageStyle();
        break;
      case MessageType.sent:
        _style = SentMessageStyle();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _style.alignment,
      child: Container(
        decoration: _style.decoration,
        constraints: BoxConstraints(
            maxWidth: size.width / 1.7,
            minWidth: 80,
            minHeight: 40
        ),
        child: Text(
          message.content,
          style: TextStyle(
              color: _style.textColor,
              fontSize: 18
          ),
        ),
      ),
    );
  }
}