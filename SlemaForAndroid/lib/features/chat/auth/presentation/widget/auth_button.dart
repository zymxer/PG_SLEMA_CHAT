import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/presentation/screen/sign_up_screen_new.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/utils/widgets/default_circular_button.dart';

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
  final VoidCallback onPressed;

  // Todo final
  late String label;

  AuthButton({super.key, required this.mainScreenController, this.formKey,
    required this.type, required this.isMain, required this.onPressed}) : super() {
    label = _labelFromType();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultCircularButton(
        onPressed: _onPressedFromType(context),
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

  void Function() _onPressedFromType(BuildContext context) {
    onPressed();
    switch (type) {
      case AuthButtonType.SignIn:
        return () => _onSignInButtonPressed(context);
      case AuthButtonType.SignUp:
        return () => _onSignUpButtonPressed(context);
    }
  }

  void _onSignInButtonPressed(BuildContext context) {
    if(isMain) {
      // TODO sign in logic
    }
    else {
      mainScreenController.navigateTo(ChatMainScreenType.SIGN_IN_SCREEN);
    }
  }

  void _onSignUpButtonPressed(BuildContext context) {
    if(isMain) {
      // TODO sign up logic
    }
    else {
      mainScreenController.navigateTo(ChatMainScreenType.SIGN_UP_SCREEN);
    }

  }


}