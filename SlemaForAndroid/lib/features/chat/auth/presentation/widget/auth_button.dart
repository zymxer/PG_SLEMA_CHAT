import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/logic/service/auth_service.dart';
import 'package:pg_slema/features/chat/auth/presentation/controller/sign_in_controller.dart';
import 'package:pg_slema/features/chat/auth/presentation/controller/sign_up_controller.dart';
import 'package:pg_slema/features/chat/auth/presentation/screen/sign_up_screen.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/utils/widgets/default_circular_button.dart';
import 'package:provider/provider.dart';

enum AuthButtonType {
  SignIn,
  SignUp
}
// From save_button
class AuthButton extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final ChatMainScreenController mainScreenController;
  final AuthButtonType type;
  final bool isMain;
  final VoidCallback? onPressed;

  late String label;

  AuthButton({super.key, required this.mainScreenController, this.formKey,
    required this.type, required this.isMain, this.onPressed}) : super() {
    label = _labelFromType();

  }

  @override
  Widget build(BuildContext context) {
    return DefaultCircularButton(
        onPressed: _onPressed(context),
        label: label
    );
  }

  String _labelFromType() {
    switch (type) {
      case AuthButtonType.SignIn:
        return "Zaloguj się";
      case AuthButtonType.SignUp:
        return "Zarejestruj się";
    }
  }

  void Function() _onPressed(BuildContext context) {
    // if(onPressed != null) {
    //   onPressed!; // todo validate form
    // }
    switch (type) {
      case AuthButtonType.SignIn:
        return () => _onSignInButtonPressed(context);
      case AuthButtonType.SignUp:
        return () => _onSignUpButtonPressed(context);
    }
  }

  void _onSignInButtonPressed(BuildContext context) {
    if(isMain) {
      Provider.of<SignInController>(context, listen: false).logIn();
    }
    else {
      mainScreenController.navigateTo(ChatMainScreenType.SIGN_IN_SCREEN);
    }
  }

  void _onSignUpButtonPressed(BuildContext context) {
    if(isMain) {
      Provider.of<SignUpController>(context, listen: false).register();
    }
    else {
      mainScreenController.navigateTo(ChatMainScreenType.SIGN_UP_SCREEN);
    }

  }
}