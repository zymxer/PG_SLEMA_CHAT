
import 'package:chat_app/features/auth/logic/service/auth_service.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});


  @override
  State<StatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
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
              "Sign up",
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
          email(size, emailController),
          SizedBox(
            height: size.height / 30,
          ),
          field(size, "Password", Icons.password, true, passwordController),
          SizedBox(
            height: size.height / 80,
          ),
          field(size, "Confirm password", Icons.password, true, null), //todo validation
          SizedBox(
            height: size.height / 30,
          ),
          signUpButton(size, context),
          loginButton(size, context)
        ],
      ),
    );
  }

  Widget field(Size size, String hintText, IconData icon, bool obscureText,
      TextEditingController? controller) {
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

  Widget email(Size size, TextEditingController controller) {
    return SizedBox(
      height: size.height / 15,
      width: size.width / 1.2,
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.email),
            hintText: "Email",
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
            )
        ),
      ),
    );
  }

  Widget signUpButton(Size size, BuildContext context) {
    return TextButton(
        onPressed:() => onSignUpPressed(context),
        child: Container(height: size.height / 15,
          width: size.width / 2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue
          ),
          alignment: Alignment.center,
          child: Text(
            "Sign up",

          ),
        )
    );
  }

  Widget loginButton(Size size, BuildContext context) {
    return TextButton(
        onPressed:() => onLoginPressed(context),
        child: Container(
          height: size.height / 20,
          width: size.width / 2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white12
          ),
          alignment: Alignment.center,
          child: Text(
            "Login",
          ),
        )
    );
  }

  void onSignUpPressed(BuildContext context) async {
    String login = loginController.text;
    String password = passwordController.text;
    String email = emailController.text;

    var registerResponce = await authService.registerUser(login, password, email);

    if(registerResponce) {
      print("Registered");
      Navigator.pushNamed(context, "/signIn");
    }
  }

  void onLoginPressed(BuildContext context) {
    Navigator.pushNamed(context, "/signIn");
  }

}
