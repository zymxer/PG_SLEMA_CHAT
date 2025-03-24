
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/logic/service/auth_service.dart';

class SignInScreen extends StatefulWidget {

  //todo change other screens
  static const routeName = '/';

  const SignInScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: size.height / 15,
          ),
          Container(
            width: size.width / 1.1,
            height: size.height / 10,
            alignment: Alignment.center,
            child: Text(
              "Sign in",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          field(size, "Login", Icons.account_box, false, loginController),
          SizedBox(
            height: size.height / 30,
          ),
          field(size, "Password", Icons.password, true, passwordController),
          SizedBox(
            height: size.height / 30,
          ),
          logInButton(size, context),
          signUpButton(size, context)
        ],
      ),
    );
  }


  Widget field(Size size, String hintText, IconData icon, bool obscureText,
      TextEditingController controller) {
    return SizedBox(
      height: size.height / 15,
      width: size.width / 1.2,
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
            )
        ),
      ),
    );
  }

  Widget logInButton(Size size, BuildContext context) {
    return TextButton(
        onPressed:() => onLoginPressed(context),
        child: Container(height: size.height / 15,
          width: size.width / 2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue
          ),
          alignment: Alignment.center,
          child: Text(
            "Log in",

          ),
        )
    );
  }

  Widget signUpButton(Size size, BuildContext context) {
    return TextButton(
        onPressed:() => onSignUpPressed(context),
        child: Container(
          height: size.height / 20,
          width: size.width / 2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white12
          ),
          alignment: Alignment.center,
          child: Text(
            "Sign up",
          ),
        )
    );
  }

  void onSignUpPressed(BuildContext context) {
    Navigator.pushNamed(context, "/signUp");
  }

  void onLoginPressed(BuildContext context) async{
    String login = loginController.text;
    String password = passwordController.text;

    var loginResponse = await authService.loginUser(login, password);

    if(loginResponse.status == true) {
      Navigator.pushNamed(context, "/inbox");
    }


  }

}

