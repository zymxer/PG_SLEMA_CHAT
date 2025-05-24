import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/logic/entity/login_status.dart';
import 'package:pg_slema/features/chat/auth/logic/service/auth_service.dart';
import 'package:pg_slema/features/chat/auth/presentation/screen/sign_up_screen.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:provider/provider.dart';

class SignInController extends ChangeNotifier {
  String username = "";
  String password = "";

  late LoginStatus loginStatus;

  final AuthService authService;
  final ChatMainScreenController mainScreenController;

  SignInController(this.authService, this.mainScreenController);

  void logIn() async{
    try {
      loginStatus = await authService.loginUser(username, password);
      if(true && loginStatus.status) {
        mainScreenController.navigateTo(ChatMainScreenType.CHATS_SCREEN);
      }
    }
    catch (ex){
      print("Login exception: $ex");    // TODO NEXT - забилдить
    }
  }
}