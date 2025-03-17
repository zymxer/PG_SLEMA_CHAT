import 'package:flutter/material.dart';

abstract class MessageStyle {
  final Alignment alignment;
  final Decoration? decoration;
  final Color? textColor;

  const MessageStyle({
    required this.alignment,
    this.decoration,
    this.textColor
  });
}

class SentMessageStyle extends MessageStyle {

  const SentMessageStyle() : super(
    alignment: Alignment.centerRight,
    decoration: const BoxDecoration(
      color: Colors.black,
    ),
    textColor: Colors.white,
  );
}


class ReceivedMessageStyle extends MessageStyle {

  const ReceivedMessageStyle() : super(
    alignment: Alignment.centerLeft,
    decoration: const BoxDecoration(
      color: Colors.grey,
    ),
  );
}