import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/presentation/controller/sign_in_controller.dart';
import 'package:pg_slema/features/chat/auth/presentation/widget/auth_button.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/utils/widgets/appbars/default_appbar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';
import 'package:pg_slema/utils/widgets/forms/text_input.dart';

// TODO: !!! Chat controller, main page - loading, controller with body of screens

class SignInScreenNew extends StatefulWidget {
  final ChatMainScreenController mainScreenController;

  const SignInScreenNew({
    super.key,
    required this.mainScreenController
});
  @override
  State<StatefulWidget> createState() => _SignInScreenNewState();
}

class _SignInScreenNewState extends State<SignInScreenNew> {
  final _formKey = GlobalKey<FormState>();
  final _signInController = SignInController();



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultAppBar(title: "Zaloguj się"),
        DefaultBody(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20.0),
                  CustomTextFormField(
                    label: "Nazwa użytkownika",
                    icon: Icons.account_box,
                    onChanged: _onFieldChangedPlaceholder,
                  ),
                  const SizedBox(height: 20.0),
                  CustomTextFormField(
                    label: "Hasło",
                    icon: Icons.password,
                    onChanged: _onFieldChangedPlaceholder,
                  ),
                  const SizedBox(height: 20.0),
                  AuthButton(
                    formKey: _formKey,
                    mainScreenController: widget.mainScreenController,
                    type: AuthButtonType.SignIn,
                    isMain: true,
                    onPressed: _onButtonPressedPlaceholder,
                  ),
                  const SizedBox(height: 20.0),
                  AuthButton(
                    type: AuthButtonType.SignUp,
                    mainScreenController: widget.mainScreenController,
                    isMain: false,
                    onPressed: _onButtonPressedPlaceholder,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
  void _onFieldChangedPlaceholder(String name) {
    //TODO replace
  }

  void _onButtonPressedPlaceholder() {
    // TODO replace
  }



}