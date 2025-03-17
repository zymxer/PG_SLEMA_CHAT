import 'dart:convert';
import 'package:chat_app/features/auth/logic/entity/login_status.dart';
import 'package:chat_app/features/auth/logic/entity/login_request.dart';
import 'package:chat_app/features/auth/logic/entity/register_request.dart';
import 'package:chat_app/features/user/logic/service/user_service.dart';
import 'package:chat_app/utils/token/token_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthService {
  late String _baseUrl;

  AuthService() {
    String apiPath = dotenv.env['API_PATH'] ?? "http://localhost:8080";
    _baseUrl = '$apiPath/auth';
  }

  // Login
  Future<LoginStatus> loginUser(String username, String password) async {
    final String url = "$_baseUrl/login";

    final LoginRequest request = LoginRequest(username, password);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String token = responseBody['token'];

        print("-------------------------------------------------------------------------");
        var savedToken = await TokenService.getToken();
        var usr = await UserService().getCurrentUser();
        print("CURRENT TOKEN: $savedToken");
        print("CURRENT OF TOKEN: ${usr?.name ?? "NONE"}");
        await TokenService.saveToken(token);
        savedToken = await TokenService.getToken();
        usr = await UserService().getCurrentUser();
        print("NEW TOKEN: $savedToken");
        print("CURRENT OF TOKEN: ${usr?.name ?? "NONE"}");
        print("-------------------------------------------------------------------------");

        return LoginStatus(true, token);
      } else {
        throw Exception('Failed to login. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  // todo RegisterStatus
  Future<bool> registerUser(String username, String password,
      String email) async {
    final String url = "$_baseUrl/register";

    final RegisterRequest request = RegisterRequest(username, password, email);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
            'Failed to sign up. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during sign up: $e');
    }
  }
}