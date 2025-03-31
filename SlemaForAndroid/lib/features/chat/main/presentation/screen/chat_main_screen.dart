import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/presentation/screen/sign_in_screen_new.dart';
import 'package:pg_slema/features/chat/auth/presentation/screen/sign_up_screen_new.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:provider/provider.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({
    super.key,
  });

  @override
  ChatMainScreenState createState() => ChatMainScreenState();
}

class ChatMainScreenState extends State<ChatMainScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ChatMainScreenController>(context);
    // services

    //TODO initState to get current index based on token status

    return Scaffold(
      body: <Widget>[
        SignInScreenNew(mainScreenController: controller),
        SignUpScreenNew(mainScreenController: controller),

      ][controller.currentIndex],
    );
  }
}