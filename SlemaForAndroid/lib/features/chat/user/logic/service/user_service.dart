import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pg_slema/features/chat/user/logic/entity/user.dart';
import 'package:pg_slema/features/chat/user/logic/entity/userDto.dart';
import 'package:pg_slema/utils/token/token_service.dart';

class UserService extends ChangeNotifier {
  final Dio dio;
  final TokenService tokenService;
  final String _baseUrl = '/api/user';
  User? currentUser;

  UserService(this.dio, this.tokenService);


  Future<List<User>> getAllUsers() async {

    final endpoint = _baseUrl;
    String? token = await tokenService.getToken();
    if(token == null) {
      throw TokenServiceException('Unable to retrieve a token');
    }

    try {
      final response = await dio.get(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        ),
      );
      switch(response.statusCode) {
        case 200:
          final List<dynamic> data = response.data as List<dynamic>;
          return data.map(
                  (jsonUser) => UserDto.fromJson(jsonUser).toUser()
          ).toList();

        default:
          throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during fetching users: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    final String endpoint = "$_baseUrl/of-request";
    String? token = await tokenService.getToken();

    if(token == null) {
      throw TokenServiceException('Unable to retrieve a token');
    }

    try {
      final response = await dio.get(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        ),
      );
      switch(response.statusCode) {
        case 200:
          final data = response.data;
          User user = UserDto.fromJson(data).toUser();
          currentUser = user;
          return user;

        default:
          throw Exception('Failed to get current user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during getting current user: $e');
    }
  }

  //todo implement in backend
  Future<User> getById(String id) async {
    var list = await getAllUsers();
    return list.firstWhere( (user) => user.id == id);
  }
}
