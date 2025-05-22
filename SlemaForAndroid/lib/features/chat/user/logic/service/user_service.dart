import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pg_slema/features/chat/user/logic/entity/user.dart';
import 'package:pg_slema/features/chat/user/logic/entity/userDto.dart';
import 'package:pg_slema/utils/token/token_service.dart';

class UserService {
  late String _baseUrl;

  UserService() {
    String apiPath = dotenv.env['API_PATH'] ?? "http://localhost:8080";
    _baseUrl = '$apiPath/api/user';
  }

  //
  Future<List<User>> getAllUsers() async {

    final String url = _baseUrl;

    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        List<UserDto> usersDtos = jsonResponse.map((jsonUser) => UserDto.fromJson(jsonUser)).toList();
        List<User> users = usersDtos.map((userDto) => userDto.toUser()).toList();
        return users;
      }
      else {
        throw Exception('Failed to get users. Status code: ${response.statusCode}');
      }
    }

    catch (e) {
      throw Exception('Error during getting all chats: $e');
    }
  }

  //todo implement in backend
  Future<User> getById(String id) async {
    var list = await getAllUsers();
    return list.firstWhere( (user) => user.id == id);
  }

  Future<User?> getCurrentUser() async {
    final String url = "$_baseUrl/of-request";

    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        UserDto userDto = UserDto.fromJson(jsonResponse);
        return userDto.toUser();
      }
      else {
        return null;
        //throw Exception('Failed to get current user. Status code: ${response.statusCode}');
      }
    }

    catch (e) {
      throw Exception('Error during getting current user $e');
    }
  }
}
