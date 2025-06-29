import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/presentation/controller/sign_up_controller.dart';
import 'package:pg_slema/features/chat/auth/presentation/widget/auth_button.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/utils/widgets/appbars/default_appbar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';
import 'package:pg_slema/utils/widgets/forms/text_input.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void _onRegisterButtonPressed(BuildContext context) async {
    final signUpController = Provider.of<SignUpController>(context, listen: false);

    if (_formKey.currentState?.validate() ?? false) {
      String? errorMessage = await signUpController.register();

      if (errorMessage != null) {
        _showSnackBar(errorMessage.replaceFirst('Wyjątek: ', ''));
      } else {
        _showSnackBar('Rejestracja zakończona sukcesem! Możesz się teraz zalogować.', backgroundColor: Colors.green);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signUpController = Provider.of<SignUpController>(context);
    final mainScreenController = Provider.of<ChatMainScreenController>(context);

    return Column(
      children: [
        const DefaultAppBar(title: "Zarejestruj się"),
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
                    onChanged: (value) => signUpController.username = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Proszę podać nazwę użytkownika';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  CustomTextFormField(
                    label: "Email",
                    icon: Icons.email,
                    onChanged: (value) => signUpController.email = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Proszę podać adres email';
                      }
                      if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                        return 'Proszę podać prawidłowy adres email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  CustomTextFormField(
                    label: "Hasło",
                    icon: Icons.password,
                    onChanged: (value) => signUpController.password = value,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Proszę podać hasło';
                      }
                      if (value.length < 6) {
                        return 'Hasło musi mieć co najmniej 6 znaków';
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'Hasło musi zawierać co najmniej jedną dużą literę';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Hasło musi zawierać co najmniej jedną cyfrę';
                      }
                      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                        return 'Hasło musi zawierać co najmniej jeden znak specjalny';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  CustomTextFormField(
                    label: "Powtórz hasło",
                    icon: Icons.password,
                    onChanged: (value) => signUpController.confirmPassword = value,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Proszę powtórzyć hasło';
                      }
                      if (value.length < 6) {
                        return 'Hasło musi mieć co najmniej 6 znaków';
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'Hasło musi zawierać co najmniej jedną dużą literę';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Hasło musi zawierać co najmniej jedną cyfrę';
                      }
                      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                        return 'Hasło musi zawierać co najmniej jeden znak specjalny';
                      }
                      if (value != signUpController.password) {
                        return 'Hasła nie pasują do siebie';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  AuthButton(
                    formKey: _formKey,
                    mainScreenController: mainScreenController,
                    type: AuthButtonType.SignUp,
                    isMain: true,
                    onPressed: () => _onRegisterButtonPressed(context),
                  ),
                  const SizedBox(height: 20.0),
                  AuthButton(
                    mainScreenController: mainScreenController,
                    type: AuthButtonType.SignIn,
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