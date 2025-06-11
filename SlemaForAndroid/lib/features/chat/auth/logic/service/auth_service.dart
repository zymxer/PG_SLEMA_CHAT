import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pg_slema/features/chat/auth/logic/entity/login_request.dart';
import 'package:pg_slema/features/chat/auth/logic/entity/login_status.dart';
import 'package:pg_slema/features/chat/auth/logic/entity/register_request.dart';
import 'package:pg_slema/features/chat/auth/logic/entity/register_status.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';
import 'package:pg_slema/features/settings/logic/application_info_repository.dart';
import 'package:pg_slema/utils/token/token_service.dart';
import 'package:provider/provider.dart';

class AuthService {
  final ApplicationInfoRepository applicationInfoRepository;
  final TokenService tokenService;
  final UserService userService;
  final ChatMainScreenController chatMainScreenController;
  final Dio dio;
  final String _baseUrl = '/auth';

  AuthService(this.applicationInfoRepository, this.dio, this.tokenService, this.userService, this.chatMainScreenController);

  Future<LoginStatus> loginUser(String username, String password) async {

    final String endpoint = "$_baseUrl/login";
    final LoginRequest request = LoginRequest(username, password);

    try {
      final response = await dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      switch(response.statusCode) {
        case 200:
          final data = response.data as Map<String, dynamic>;
          final String token = data['token'];
          await tokenService.saveToken(token);
          await userService.getCurrentUser();
          return LoginStatus(true, token);
        default:
          throw Exception('Failed to log in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  Future<RegisterStatus> registerUser(String username, String password,
      String email) async {

    final String endpoint = "$_baseUrl/register";
    final RegisterRequest request = RegisterRequest(username, password, email);

    try {
      final response = await dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      switch(response.statusCode) {
        case 201:
          return RegisterStatus(true);
        default:
          throw Exception('Failed to register. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  void logOut(BuildContext context) {
    tokenService.deleteToken();
    chatMainScreenController.toDefaultState();
    Navigator.pop(context);
  }
}