import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/features/chat/user/logic/entity/user.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';
import 'package:pg_slema/utils/token/token_service.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';
import 'package:provider/provider.dart';

class ChatMainLoadingScreen extends StatefulWidget {


  const ChatMainLoadingScreen({
    super.key,
  });
  @override
  State<StatefulWidget> createState() => _ChatMainLoadingScreenState();
}

class _ChatMainLoadingScreenState extends State<ChatMainLoadingScreen> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ChatMainScreenController>(context);

    return Column(
      children: [
        DefaultBody(
          child: FutureBuilder<String?>(
            future: Provider.of<TokenService>(context, listen: false).getToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              else if (snapshot.hasError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.navigateTo(ChatMainScreenType.SIGN_IN_SCREEN);
                });
                return SizedBox();
              }
              else {
                return FutureBuilder<User?>(
                    future: Provider.of<UserService>(context, listen: false).getCurrentUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      else if (snapshot.hasError) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          controller.navigateTo(
                              ChatMainScreenType.SIGN_IN_SCREEN);
                        });
                        return SizedBox();
                      }
                      else if (snapshot.hasData) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          controller.navigateTo(
                              ChatMainScreenType.CHATS_SCREEN);
                        });
                        return SizedBox();
                      }
                      else {
                        return SizedBox();
                      }
                    }
                );
              }
            },
          ),
        )
      ],
    );
  }
}