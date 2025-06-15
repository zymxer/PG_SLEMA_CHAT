import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';
import 'package:pg_slema/features/gallery/logic/entity/image_metadata.dart';
import 'package:pg_slema/features/gallery/logic/service/thumbnail_service_impl.dart';
import 'package:pg_slema/features/gallery/presentation/widget/single_image_widget.dart';
import 'package:provider/provider.dart';

enum MessageType { Received, ReceivedGroup, Sent }

class MessageWidget extends StatefulWidget {
  final Message message;
  const MessageWidget(
    this.message, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => MessageWidgetState();
}

class MessageWidgetState extends State<MessageWidget> {
  late MessageType type;

  @override
  void initState() {
    super.initState();
    type = widget.message.senderId ==
            Provider.of<UserService>(context, listen: false).currentUser!.id
        ? MessageType.Sent
        : MessageType.Received;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: messageAlignment(type),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200, minWidth: 100), //todo
        decoration: messageDecoration(type),
        child: _messageContent()
      ),
    );
  }

  Widget _messageContent() {
    if (widget.message.imageMetadata == null) {
      return SingleImageWidget(
        metadata: widget.message.imageMetadata!,
        thumbnailService: ThumbnailServiceImpl(),
      );
    } else {
      return Text(
        widget.message.content,
        style: Theme.of(context).textTheme.labelSmall,
      );
    }
  }

  Alignment messageAlignment(MessageType type) {
    return type == MessageType.Sent
        ? Alignment.centerRight
        : Alignment.centerLeft;
  }

  BoxDecoration messageDecoration(MessageType type) {
    switch (type) {
      case MessageType.Received || MessageType.ReceivedGroup:
        return new BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12)),
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
              bottomLeft: Radius.circular(12)),
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
