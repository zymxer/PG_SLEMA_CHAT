import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/presentation/screen/sign_in_screen_new.dart';
import 'package:pg_slema/features/chat/auth/presentation/screen/sign_up_screen_new.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/features/chat/main/widget/chat_navigation_destination_widget.dart';
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
      bottomNavigationBar: !controller.hasBottomBar?
        null : BottomAppBar(
        padding: const EdgeInsets.all(0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ChatNavigationDestination(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Home',
              onPressed: controller.navigateTo,
              currentSelectedScreen: ChatMainScreenType.SIGN_IN_SCREEN, // TODO fix
              destinationScreen: ChatMainScreenType.SIGN_IN_SCREEN, // TODO case to navigate back to main
            ),
            ChatNavigationDestination(
              icon: Icons.chat_outlined,
              selectedIcon: Icons.chat,
              label: 'Chats',
              onPressed: controller.navigateTo,
              currentSelectedScreen: ChatMainScreenType.SIGN_IN_SCREEN, // TODO fix
              destinationScreen: ChatMainScreenType.CHATS_SCREEN,
            ),
            ChatNavigationDestination(
              icon: Icons.account_box_outlined,
              selectedIcon: Icons.account_box,
              label: 'User',
              onPressed: controller.navigateTo,
              currentSelectedScreen: ChatMainScreenType.SIGN_IN_SCREEN, // TODO fix
              destinationScreen: ChatMainScreenType.USER_SCREEN,
            ),
          ],
        ),
      ),
      body: <Widget>[
        SignInScreenNew(mainScreenController: controller),
        SignUpScreenNew(mainScreenController: controller),

      ][controller.currentIndex],
    );
  }
}