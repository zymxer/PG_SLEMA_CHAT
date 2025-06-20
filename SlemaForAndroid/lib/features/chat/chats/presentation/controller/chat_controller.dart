import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/chat.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/message.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/post_message_request.dart';
import 'package:pg_slema/features/chat/chats/logic/entity/post_message_responce.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';

import 'package:pg_slema/features/gallery/logic/service/image_service_chat_impl.dart';
import 'package:uuid/uuid.dart';

enum ChatInputState { Message, Attachment }

class ChatController extends ChangeNotifier {
  String _message = "";
  ChatInputState inputState = ChatInputState.Attachment;
  final TextEditingController textEditingController = TextEditingController();

  Chat? _currentChat;
  late Future<List<Message>> messagesFuture;
  Map<Chat, List<Message>> messagesMap = {};
  List<Message> messages = [];
  late StreamSubscription<Message> _messageSubscription;

  final picker = ImagePicker();
  final _uuid = const Uuid();

  final ChatService chatService;
  final UserService userService;
  final ImageServiceChatImpl chatImageService;

  ChatController(this.chatService, this.userService, this.chatImageService) {
    _messageSubscription = chatService.newMessages.listen(_updateMessageList);
  }

  set message(String value) {
    _message = value;
    inputState =
    _message.isEmpty ? ChatInputState.Attachment : ChatInputState.Message;
    notifyListeners();
  }

  set currentChat(Chat value) {
    _currentChat = value;
    messagesMap.putIfAbsent(_currentChat!, () => []);
    messages = messagesMap[_currentChat]!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _message = "";
      textEditingController.clear();
      inputState = ChatInputState.Attachment;
      notifyListeners();
    });
  }

  void _updateMessageList(Message message) {
    final incomingMessageChat = chatService.getChat(message.chatId);

    print("*" * 50);
    print("HANDLING WEBSOCKET MESSAGE");
    print("Message for chat ID: ${message.chatId}. Current chat ID: ${_currentChat?.id}");
    print("Content: ${message.content}");
    print("File URL: ${message.fileUrl}");
    print("File Name: ${message.fileName}");
    print("File Type: ${message.fileType}");
    print("*" * 50);

    final String displayContent = (message.content == "Required") ? "" : message.content;
    final Message correctedMessage = message.copyWith(content: displayContent);

    messagesMap.putIfAbsent(incomingMessageChat, () => []);
    messagesMap[incomingMessageChat]!.add(correctedMessage);

    if (_currentChat != null && _currentChat!.id == incomingMessageChat.id) {
      messages = messagesMap[incomingMessageChat]!;
      notifyListeners();
    } else {
      print("Message received for a chat not currently open: ${incomingMessageChat.name}");
    }
  }

  void fetchMessages() async {
    if (_currentChat == null) {
      print("ChatController: _currentChat is null. Cannot fetch messages.");
      messagesFuture = Future.value([]);
      return;
    }
    messagesFuture = chatService.getChatMessages(_currentChat!.id).then((messagesList) {
      messagesMap[_currentChat!] = messagesList;
      messages = messagesMap[_currentChat]!;
      notifyListeners();
      return messagesList;
    });
  }

  void _sendMessage() async {
    if (_currentChat == null) {
      print("ChatController: Cannot send message. No chat is currently selected.");
      return;
    }
    if (_message.isEmpty) {
      return;
    }

    final String tempMessageId = DateTime.now().microsecondsSinceEpoch.toString();
    final Message newMessage = Message(
      tempMessageId,
      _message,
      userService.currentUser!.id,
      _currentChat!.id,
      null,
      fileUrl: null, fileName: null, fileType: null,
    );

    messagesMap.putIfAbsent(_currentChat!, () => []);
    messagesMap[_currentChat]!.add(newMessage);
    messages = messagesMap[_currentChat]!;
    notifyListeners();

    final String sentText = _message;

    this.message = "";
    textEditingController.clear();

    try {
      final PostMessageResponse response = await chatService.sendMessage(
          PostMessageRequest(_currentChat!, sentText, null)
      );

      final Message sentMessageFromBackend = response.toMessage();


      int index = messagesMap[_currentChat!]!.indexWhere((msg) => msg.id == tempMessageId);
      if (index != -1) {
        messagesMap[_currentChat!]![index] = sentMessageFromBackend;
      }


      print("FLUTTER: Text message successfully sent to backend.");

    } catch (e) {
      print('FLUTTER ERROR: Error sending text message: $e');
      messagesMap[_currentChat!]!.remove(newMessage);
      messages = messagesMap[_currentChat]!;
      notifyListeners();
    }
  }

  void _sendAttachment() async {
    if (_currentChat == null) {
      print("ChatController: Cannot send attachment. No chat is currently selected.");
      return;
    }

    final (filesMetadata, pickedFiles) = await chatImageService.selectAndAddImagesFromGallery();

    if (pickedFiles.isEmpty) {
      print("FLUTTER: No files picked for attachment.");
      return;
    }

    List<Message> tempMessages = [];
    for(var metadataItem in filesMetadata) {
      final String tempMessageId = _uuid.v4();
      final Message tempAttachmentMessage = Message(
        tempMessageId,
        "",
        userService.currentUser!.id,
        _currentChat!.id,
        metadataItem,
        fileUrl: metadataItem.path,
        fileName: metadataItem.filename,
        fileType: metadataItem.fileType,
      );
      messagesMap[_currentChat!]!.add(tempAttachmentMessage);
      tempMessages.add(tempAttachmentMessage);
    }
    messages = messagesMap[_currentChat]!;
    notifyListeners();

    for (int i = 0; i < pickedFiles.length; i++) {
      final file = pickedFiles[i];
      final tempMessage = tempMessages[i];
      try {
        final PostMessageResponse response = await chatService.sendMessage(PostMessageRequest(_currentChat!, null, file));


        final Message sentMessageFromBackend = response.toMessage();


        int index = messagesMap[_currentChat!]!.indexOf(tempMessage);
        if (index != -1) {
          messagesMap[_currentChat!]![index] = sentMessageFromBackend.copyWith(
            imageMetadata: tempMessage.imageMetadata,

          );
        }


        print("FLUTTER: Attachment ${file.name} successfully sent to backend.");
      } catch (e) {
        print('FLUTTER ERROR: Failed to send attachment file ${file.name}: $e');
        messagesMap[_currentChat!]!.remove(tempMessage);
        messages = messagesMap[_currentChat]!;
        notifyListeners();
      }
    }

    messages = messagesMap[_currentChat]!;
    notifyListeners();

    this.message = "";
    textEditingController.clear();
  }

  void onPostfixPressed() {
    switch(inputState) {
      case ChatInputState.Message:
        _sendMessage();
        break;
      case ChatInputState.Attachment:
        _sendAttachment();
        break;
    }
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    textEditingController.dispose();
    super.dispose();
  }
}