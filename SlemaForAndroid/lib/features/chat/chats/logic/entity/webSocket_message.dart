class WebSocketMessage {
  final String content;
  final String chatId;

  WebSocketMessage(this.content, this.chatId);

  Map<dynamic, dynamic> toMap() {
    return {
      'chatUuid': chatId,
      'text': content,
    };
  }
}