import 'package:flutter/foundation.dart';
import 'package:pg_slema/features/chat/auth/logic/entity/login_status.dart';
import 'package:pg_slema/features/chat/auth/logic/service/auth_service.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';

class SignInController extends ChangeNotifier {
  String username = "";
  String password = "";

  late LoginStatus loginStatus;

  final AuthService authService;
  final ChatMainScreenController mainScreenController;

  SignInController(this.authService, this.mainScreenController);

  Future<String?> logIn() async {
    try {
      final LoginStatus status = await authService.loginUser(username, password);
      if (status.status) {
        mainScreenController.navigateTo(ChatMainScreenType.CHATS_SCREEN);
        return null;
      } else {
        return "Logowanie nie powiodło się z nieznanego powodu.";
      }
    } catch (ex) {
      if (kDebugMode) {
        print("Wyjątek logowania: $ex");
      }
      return ex.toString().replaceFirst('Wyjątek: ', '');
    }
  }
}