import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/presentation/controller/sign_in_controller.dart';
import 'package:pg_slema/features/chat/auth/presentation/controller/sign_up_controller.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/utils/widgets/default_circular_button.dart';
import 'package:provider/provider.dart';

enum AuthButtonType {
  SignIn,
  SignUp
}

class AuthButton extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final ChatMainScreenController mainScreenController;
  final AuthButtonType type;
  final bool isMain;
  final VoidCallback? onPressed;
  final String label;

  AuthButton({
    super.key,
    required this.mainScreenController,
    this.formKey,
    required this.type,
    required this.isMain,
    this.onPressed,
  }) : label = _labelFromType(type);

  static String _labelFromType(AuthButtonType type) {
    switch (type) {
      case AuthButtonType.SignIn:
        return "Zaloguj się";
      case AuthButtonType.SignUp:
        return "Zarejestruj się";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultCircularButton(
        onPressed: onPressed ?? _onDefaultPressed(context), 
        label: label
    );
  }

  void Function() _onDefaultPressed(BuildContext context) {
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
      if (formKey?.currentState?.validate() ?? false) {
        Provider.of<SignUpController>(context, listen: false).register();
      }
    }
    else {
      mainScreenController.navigateTo(ChatMainScreenType.SIGN_UP_SCREEN);
    }
  }
}