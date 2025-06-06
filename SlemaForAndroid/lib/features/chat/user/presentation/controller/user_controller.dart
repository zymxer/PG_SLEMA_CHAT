import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pg_slema/features/chat/auth/logic/entity/login_status.dart';
import 'package:pg_slema/features/chat/auth/logic/service/auth_service.dart';
import 'package:pg_slema/features/chat/auth/presentation/screen/sign_up_screen.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';
import 'package:provider/provider.dart';

class UserController {

  final UserService userService;  // todo repository
  late String name;

  UserController(this.userService);

}