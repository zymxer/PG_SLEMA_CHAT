import 'package:flutter/cupertino.dart';
import 'package:pg_slema/utils/widgets/default_circular_button.dart';

// From save_button
class SignInButton extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final VoidCallback onPressed;


  const SignInButton({super.key, this.formKey, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DefaultCircularButton(
        onPressed: () => _onSignInButtonPressed(context), label: "Zaloguj się");
  }

  void _onSignInButtonPressed(BuildContext context) {

  }
  
}