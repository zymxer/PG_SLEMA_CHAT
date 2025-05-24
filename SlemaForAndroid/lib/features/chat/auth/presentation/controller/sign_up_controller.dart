import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/logic/entity/register_status.dart';
import 'package:pg_slema/features/chat/auth/logic/service/auth_service.dart';
import 'package:pg_slema/features/chat/auth/presentation/screen/sign_in_screen.dart';

class SignUpController extends ChangeNotifier {
  String username = "";
  String password = "";
  String email = "";

  late RegisterStatus registerStatus;
  final AuthService authService;

  SignUpController(this.authService);

  void register() async{
    registerStatus = await authService.registerUser(username, password, email);
  }
}