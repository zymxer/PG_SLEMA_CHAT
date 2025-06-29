import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/presentation/controller/sign_in_controller.dart';
import 'package:pg_slema/features/chat/auth/presentation/widget/auth_button.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/utils/widgets/appbars/default_appbar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';
import 'package:pg_slema/utils/widgets/forms/text_input.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onLoginButtonPressed(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final signInController = Provider.of<SignInController>(context, listen: false);
      String? errorMessage = await signInController.logIn();

      if (errorMessage != null) {
        _showSnackBar(errorMessage.replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainScreenController = Provider.of<ChatMainScreenController>(context);
    final controller = Provider.of<SignInController>(context);

    return Column(
      children: [
        const DefaultAppBar(title: "Zaloguj się"),
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
                    obscureText: true,
                  ),
                  const SizedBox(height: 20.0),
                  AuthButton(
                    formKey: _formKey,
                    mainScreenController: mainScreenController,
                    type: AuthButtonType.SignIn,
                    isMain: true,
                    onPressed: () => _onLoginButtonPressed(context),
                  ),
                  const SizedBox(height: 20.0),
                  AuthButton(
                    type: AuthButtonType.SignUp,
                    mainScreenController: mainScreenController,
                    isMain: false,
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