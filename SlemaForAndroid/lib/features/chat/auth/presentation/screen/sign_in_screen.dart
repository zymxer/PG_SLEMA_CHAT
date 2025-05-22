import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/presentation/controller/sign_in_controller.dart';
import 'package:pg_slema/features/chat/auth/presentation/widget/auth_button.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/utils/widgets/appbars/default_appbar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';
import 'package:pg_slema/utils/widgets/forms/text_input.dart';
import 'package:provider/provider.dart';

// TODO: !!! Chat controller, main page - loading, controller with body of screens

class SignInScreen extends StatefulWidget {
  final ChatMainScreenController mainScreenController;  // todo кажется надо просто провайдер в билд

  const SignInScreen({
    super.key,
    required this.mainScreenController
});
  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SignInController>(context);

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
                    initialValue: controller.username,
                    icon: Icons.account_box,
                    onChanged: (value) => controller.username = value,
                  ),
                  const SizedBox(height: 20.0),
                  CustomTextFormField(
                    label: "Hasło",
                    icon: Icons.password,
                    onChanged: (value) => controller.password = value,
                  ),
                  const SizedBox(height: 20.0),
                  AuthButton(
                    formKey: _formKey,
                    mainScreenController: widget.mainScreenController,
                    type: AuthButtonType.SignIn,
                    isMain: true,
                    onPressed: controller.signIn,
                  ),
                  const SizedBox(height: 20.0),
                  AuthButton(
                    type: AuthButtonType.SignUp,
                    mainScreenController: widget.mainScreenController,
                    isMain: false,
                    onPressed: () => {},
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}