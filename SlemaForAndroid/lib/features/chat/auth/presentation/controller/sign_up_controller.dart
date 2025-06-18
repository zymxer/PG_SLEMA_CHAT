import 'package:flutter/foundation.dart';
import 'package:pg_slema/features/chat/auth/logic/entity/register_status.dart';
import 'package:pg_slema/features/chat/auth/logic/service/auth_service.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';

class SignUpController extends ChangeNotifier {
  String username = "";
  String password = "";
  String email = "";
  String confirmPassword = "";

  late RegisterStatus registerStatus;
  final AuthService authService;
  final ChatMainScreenController mainScreenController;

  SignUpController(this.authService, this.mainScreenController);

  void register() async {
    try {
      registerStatus =
          await authService.registerUser(username, password, email);
      if (registerStatus.status) {
        mainScreenController.navigateTo(ChatMainScreenType.SIGN_IN_SCREEN);
      }
    } catch (ex) {
      if (kDebugMode) {
        print("Register exception: $ex");
      }
    }
  }
}
