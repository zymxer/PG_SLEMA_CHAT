import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum MessageType {
  Received,
  ReceivedGroup,
  Sent
}

class MessageWidget extends StatefulWidget {
  final MessageType type;
  MessageWidget({
    super.key,
    required this.type
  });

  @override
  State<StatefulWidget> createState() => MessageWidgetState();
}

class MessageWidgetState extends State<MessageWidget> {


  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: messageAlignment(widget.type),
        child: Container(
            constraints: const BoxConstraints(maxWidth: 200, minWidth: 100), //todo
            decoration: messageDecoration(widget.type),
            child: Text(
                "weruityweioutyewrioutyweriotuywerotiywerioutyertuioywerioutyerioutyeriotyweiotuyweruiotyweriouty",
           style: Theme.of(context).textTheme.labelSmall,
            ),
        ),
    );
  }

  Alignment messageAlignment(MessageType type) {
    return widget.type == MessageType.Sent ? Alignment.centerRight : Alignment.centerLeft;
  }

  BoxDecoration messageDecoration(MessageType type) {
    switch(type) {
      case MessageType.Received || MessageType.ReceivedGroup:
        return new BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12)
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              offset: const Offset(0.0, 4.0),
              blurRadius: 4.0,
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3.0,
          ),
        );
      case MessageType.Sent:
        return new BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12)
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              offset: const Offset(0.0, 4.0),
              blurRadius: 4.0,
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3.0,
          ),
        );
    }
  }

}