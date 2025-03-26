import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/presentation/screen/sign_up_screen_new.dart';
import 'package:pg_slema/utils/widgets/default_circular_button.dart';

enum AuthButtonType {
  SignIn,
  SignUp
}
// From save_button
class AuthButton extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final AuthButtonType type;
  final bool isMain;
  final VoidCallback onPressed;

  // Todo final
  late String label;

  AuthButton({super.key, this.formKey, required this.type,
    required this.isMain, required this.onPressed}) : super() {
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
    switch (type) {
      case AuthButtonType.SignIn:
        return () => _onSignInButtonPressed(context);
      case AuthButtonType.SignUp:
        return () => _onSignUpButtonPressed(context);
    }
  }

  void _onSignInButtonPressed(BuildContext context) {

  }

  void _onSignUpButtonPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpScreenNew(),
      ),
    );
  }


}